%{
    #include <stdio.h>
    #include "scanner.h"

    #define OTHER           0 
    #define NEWLINE         1
    #define SPACE           2
    #define TAB             3

    #define IDENTIFIER      4
    #define INTLITERAL      5
    #define FLOATLITERAL    6
    #define STRINGLITERAL   7
    #define KEYWORD         8
    #define OPERATOR        9
    #define COMMENT         10
%}
%option nounput yylineno

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

const char* tokenType[13] = {
    "OTHER",     
    "NEWLINE",   
    "SPACE",     
    "TAB",       
    "IDENTIFIER",
    "INTLITERAL",
    "FLOATLITERAL",
    "STRINGLITERAL",
    "KEYWORD",   
    "OPERATOR",  
    "COMMENT",   
};

FILE *yyin;

int main(int argc, char** argv) {
    if(argc != 2) {
        printf("[-] Expected two arguments : $ ./compiler {filename}");
        return 0;
    }

    yyin = fopen(argv[1], "r");

    int ntoken, vtoken;
    ntoken = yylex();
    while(ntoken) {
        if(ntoken > 3 && ntoken != 10)
            printf("Token Type: %s\nValue: %s\n", tokenType[ntoken], yytext);
        ntoken = yylex();
    }
    fclose(yyin);
    return 0;
}


