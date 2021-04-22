/*
 * Acknowledgement: Qifan Chang and Zixian Lai 
 * acknowledgement for documentation : Abhishek Raj
 **/
%{
#include <string>
#include <vector>
#include "main.h"
#include "parser.hpp"
#include <stdio.h>
#include <iostream>

using namespace std;
%}
/* regex for single digit */
DIGIT	[0-9]
/* regex for single english alphabet */
LETTER	[A-Za-z]
/* regex for  a string with first character as an english letter / valid variable name*/
ID		{LETTER}({LETTER}|{DIGIT})*
/* regex for comment */
COMMENT             #.*\n

%option noyywrap
%option yylineno
/* below lines return relevent token values to parser */
%%
PROGRAM	{return TOKEN_PROGRAM;}
BEGIN	{return TOKEN_BEGIN;}
END	{return TOKEN_END;}
FUNCTION	{return TOKEN_FUNCTION;}
READ	{return TOKEN_READ;}
WRITE	{return TOKEN_WRITE;}
IF 	{return TOKEN_IF;}
ELSE	{return TOKEN_ELSE;}
FI 	{return TOKEN_FI;}
FOR	{return TOKEN_FOR;}
ROF	{return TOKEN_ROF;}
RETURN 	{return TOKEN_RETURN;}
INT 	{yylval.str = new string(yytext); return TOKEN_INT;}
VOID	{return TOKEN_VOID;}
STRING 	{yylval.str = new string(yytext); return TOKEN_STRING;}
FLOAT {yylval.str = new string(yytext); return TOKEN_FLOAT;}

{ID}					{/* store id value as string in yylval */  yylval.str = new string(yytext); return TOKEN_IDENTIFIER;}

{DIGIT}+				{/* store int value as string in yylval */  yylval.str = new string(yytext); return TOKEN_INTLITERAL;}

{DIGIT}*"."{DIGIT}+		{/* store float value as string in yylval */  yylval.str = new string(yytext); return TOKEN_FLOATLITERAL;}
{COMMENT}               {};

":="	{return TOKEN_OP_NE;}
"+"	{return TOKEN_OP_PLUS;}
"-"	{return TOKEN_OP_MINS;}
"*"	{return TOKEN_OP_STAR;}
"/"	{return TOKEN_OP_SLASH;}
"="	{return TOKEN_OP_EQ;}
"!="	{return TOKEN_OP_NEQ;}
"<"	{return TOKEN_OP_LESS;}
">"	{return TOKEN_OP_GREATER;}
"("	{return TOKEN_OP_LP;}
")"	{return TOKEN_OP_RP;}
";"	{return TOKEN_OP_SEMIC;}
","	{return TOKEN_OP_COMMA;}
"<="	{return TOKEN_OP_LE;}
">=" {return TOKEN_OP_GE;}

\"([^\"\n]|\"\")*\"			{/* store string value as string in yylval */  yylval.str = new string(yytext); return TOKEN_STRINGLITERAL;}
"--".*\n			{/* comment */}
[ \t\n\r]+			{/* space / tab / new line */}

%%
