%{
let system = {
  values: {},
  isFunctionPresent: false,
  isFunctionCalled: false,
  currentFunction: ""
};

%}

%lex
%%

\s+                   /* skip whitespace */
"let"                 /* skip whitespace */
"fn"                  return "FUNCTION"
"print"               return "CONSOLE"
"return"              return "RETURN"
\([a-zA-Z\b]*\)       return "FUNCTION-ARGUMENT"
"}"                   return "}"
\"[a-zA-Z]+\b\"       return "STRING"
[a-zA-Z]+\b           return 'VARIABLE'
[0-9]+("."[0-9]+)?\b  return 'NUMBER'
"+"                   return '+'
"-"                   return '-'
"="                   return '='
<<EOF>>               return 'EOF'
"{"                   return "{"
';'                   return ';'

/lex

%left RETURN "}"
%left '{'
%left ';'
%left RETURN
%left CONSOLE
%left STRING
%left VARIABLE
%left '='
%left '+' '-'
%left FUNCTION

%%

expressions
  : e EOF
      {return $1;}
  ;

e

  : e '+' e
      {if(system.currentFunction) {
        const currentFunctionDetails = system.functionDetail[system.currentFunction].values;
        const val1 =  !currentFunctionDetails[$1] ? $1 : currentFunctionDetails[$1];
        const val2 =  !currentFunctionDetails[$3] ? $3 : currentFunctionDetails[$3];
         $$ = val1+val2;
        }
        else
        $$ = $1+$3
      }

  | e '-' e
      {if(system.currentFunction) {
        const currentFunctionDetails = system.functionDetail[system.currentFunction].values;
        const val1 =  currentFunctionDetails[$1];
        const val2 =  currentFunctionDetails[$3];
         $$ = val1-val2;
        }
        else
        $$ = $1-$3
      }

  |FUNCTION VARIABLE FUNCTION-ARGUMENT 
    {
      system.functionDetail = {...system.functionDetail, [$2]: {}}
      system.currentFunction = $2;
      system.isFunctionPresent = true;
    }

  | e '}'
    {}

  | NUMBER
    {$$ = Number(yytext)}
  
  | VARIABLE
    {if(system.values[$1]) $$ = system.values[$1]}

  | e ';' e
    {}    

  | e '{' e
    {}    

  | e '=' e

    {if(system.currentFunction)
    {
      const {currentFunction} = system;
      system.functionDetail[currentFunction].values = {...system.functionDetail[currentFunction].values, [$1]  : $3}
    }
    else
      system.values[$1] = $3; $$ = $3 }

  | STRING
    {$$ = $1;}
  
  | CONSOLE e 
    {
      const {isFunctionPresent, isFunctionCalled} = system;
      if((!isFunctionPresent) || (isFunctionPresent && isFunctionCalled)) 
      console.log($2)
    }

  | VARIABLE FUNCTION-ARGUMENT
    {
      system.isFunctionCalled = true;
      $$ = system.functionDetail[$1].result;

    }

  | RETURN e ';'
    { 
      const {currentFunction} = system;
      system.functionDetail[currentFunction].result = $2;
      system.currentFunction = "";
      }

  ;