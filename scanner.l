%{
    #include "microParser.tab.h"
%}


IDENTIFIER          [a-zA-Z][a-zA-Z0-9]*
INTLITERAL          [0-9]+
STRINGLITERAL       \"(\\.|[^"\\])*\"
FLOATLITERAL        [0-9]*\.[0-9]+
ASSIGNMENT          :=
ADD                 \+
SUB                 -
MULT                \*
DIV                 \/
EQUAL               = 
NEQUAL              != 
LESSTHAN            < 
GREATERTHAN         >
BRACKET_OPEN        \(
BRACKET_CLOSE       \)
SEMICOLON           ;
COLON               ,
LESSTHANEQ          <=
GREATERTHANEQ       >=
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
{PROGRAM}            return PROGRAM;
{BEGIN}              return _BEGIN;
{END}                return END;
{FUNCTION}           return FUNCTION;
{READ}               return READ;
{WRITE}              return WRITE;
{IF}                 return IF;
{ELSE}               return ELSE;
{FI}                 return FI;
{FOR}                return FOR;
{ROF}                return ROF;
{RETURN}             return RETURN;
{INT}                return INT;
{VOID}               return VOID;
{STRING}             return STRING;
{FLOAT}              return FLOAT;

{IDENTIFIER}        return IDENTIFIER;
{INTLITERAL}        return INTLITERAL;
{FLOATLITERAL}      return FLOATLITERAL;

{ASSIGNMENT}        return ASSIGNMENT;
{ADD}               return ADD;          
{SUB}               return SUB;          
{MULT}              return MULT;         
{DIV}               return DIV;          
{EQUAL}             return EQUAL;        
{NEQUAL}            return NEQUAL;       
{LESSTHAN}          return LESSTHAN;     
{GREATERTHAN}       return GREATERTHAN;  
{BRACKET_OPEN}      return BRACKET_OPEN; 
{BRACKET_CLOSE}     return BRACKET_CLOSE;
{SEMICOLON}         return SEMICOLON;    
{COLON}             return COLON;        
{LESSTHANEQ}        return LESSTHANEQ;   
{GREATERTHANEQ}     return GREATERTHANEQ;

{STRINGLITERAL}     return STRINGLITERAL;

{COMMENT}           {};
{NEWLINE}           {};
{TAB}               {};
{SPACE}             {};
{OTHER}             {};

%%
int yywrap(){
    return 1;
}

