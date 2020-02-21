%{
let system = {
  values: {},
  isFunctionPresent: false,
  isFunctionCalled: false
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
\"[a-zA-Z]+\b\"        return "STRING"
[a-zA-Z]+\b           return 'VARIABLE'
[0-9]+("."[0-9]+)?\b  return 'NUMBER'
"+"                   return '+'
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
%left '+'
%left FUNCTION

%%

expressions
  : e EOF
      {return $1;}
  ;

e

  : e '+' e
      {$$ = $1 + $3}

  |FUNCTION VARIABLE FUNCTION-ARGUMENT 
    {
      system.functionDetail = {name: $2}
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
    { system.values[$1] = $3; $$ = $3 }

  |STRING
  {$$ = $1;}
  
  | CONSOLE e 
    {if((!system.isFunctionPresent) ||  (system.isFunctionPresent && system.isFunctionCalled)) 
      {
        console.log($2)
      }
    }

  | VARIABLE FUNCTION-ARGUMENT
    { 
      $$ = system.functionDetail.result;
      system.isFunctionCalled = true;
    }

  | RETURN e ';'
    { system.functionDetail.result = $2}

  ;