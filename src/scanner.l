%{
    #include "scanner.h"
%}

%option nounput yylineno

IDENTIFIER          [a-zA-Z][a-zA-Z0-9]*
INTLITERAL          [0-9]+
STRINGLITERAL       \"(\\.|[^"\\])*\"
FLOATLITERAL        [0-9]*\.[0-9]+
ASSIGNMENT          ":="
ADD                 "+"
SUB                 "-"
MULT                "*"
DIV                 "/"
EQUAL               "="
NEQUAL              "!="
LESSTHAN            "<"
GREATERTHAN         ">"
BRACKET_OPEN        "("
BRACKET_CLOSE       ")"
SEMICOLON           ";"
COLON               ","
LESSTHANEQ          "<="
GREATERTHANEQ       ">="
PROGRAM             PROGRAM
BEGIN               BEGIN
END                 END
FUNCTION            FUNCTION
READ                READ
WRITE               WRITE
IF                  IF
ELSE                ELSE
FI                  FI
FOR                 FOR
ROF                 ROF
RETURN              RETURN
INT                 INT
VOID                VOID
STRING              STRING
FLOAT               FLOAT
COMMENT             #.*\n
NEWLINE             "\n"
TAB                 "\t"
SPACE               " "
OTHER               .

%%
{PROGRAM}            return KEYWORD;
{BEGIN}              return KEYWORD;
{END}                return KEYWORD;
{FUNCTION}           return KEYWORD;
{READ}               return KEYWORD;
{WRITE}              return KEYWORD;
{IF}                 return KEYWORD;
{ELSE}               return KEYWORD;
{FI}                 return KEYWORD;
{FOR}                return KEYWORD;
{ROF}                return KEYWORD;
{RETURN}             return KEYWORD;
{INT}                return KEYWORD;
{VOID}               return KEYWORD;
{STRING}             return KEYWORD;
{FLOAT}              return KEYWORD;

{IDENTIFIER}        return IDENTIFIER;
{INTLITERAL}        return INTLITERAL;
{FLOATLITERAL}      return FLOATLITERAL;

{ASSIGNMENT}        return OPERATOR;
{ADD}               return OPERATOR;          
{SUB}               return OPERATOR;          
{MULT}              return OPERATOR;         
{DIV}               return OPERATOR;          
{EQUAL}             return OPERATOR;        
{NEQUAL}            return OPERATOR;       
{LESSTHAN}          return OPERATOR;     
{GREATERTHAN}       return OPERATOR;  
{BRACKET_OPEN}      return OPERATOR; 
{BRACKET_CLOSE}     return OPERATOR;
{SEMICOLON}         return OPERATOR;    
{COLON}             return OPERATOR;        
{LESSTHANEQ}        return OPERATOR;   
{GREATERTHANEQ}     return OPERATOR;

{STRINGLITERAL}     return STRINGLITERAL;
{COMMENT}           return COMMENT;
{NEWLINE}           return NEWLINE;
{TAB}               return TAB;
{SPACE}             return SPACE;
{OTHER}             return OTHER;

%%

int yywrap(void) {
    return 1;
}
