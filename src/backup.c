#include <stdio.h>
#include "scanner.h"


extern int yylex();
extern int yylineno;
extern char* yytext;

const char* tokenType[13] = {
    "OTHER",     
    "NEWLINE",   
    "SPACE",     
    "TAB",       
    "IDENTIFIER",
    "INTLITERAL",
    "FLOATLITERA",
    "STRINGLITERA",
    "KEYWORD",   
    "OPERATOR",  
    "COMMENT",   
};

int main() {
    int ntoken, vtoken;
    ntoken = yylex();
    while(ntoken) {
        if(ntoken < 4 || ntoken != 10)
            printf("Token Type: %s\nValue: %s\n", tokenType[ntoken], yytext);
        ntoken = yylex();
    }
    return 0;
}
