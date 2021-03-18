/* A Bison parser, made by GNU Bison 3.5.1.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

#ifndef YY_YY_MICROPARSER_TAB_H_INCLUDED
# define YY_YY_MICROPARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif
/* "%code requires" blocks.  */
#line 11 "microParser.y"

    #include<iostream>
    #include<string>
    #include<vector>
    #include<utility>
    #include "ast.hpp"

#line 56 "microParser.tab.h"

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    PROGRAM = 258,
    _BEGIN = 259,
    END = 260,
    IDENTIFIER = 261,
    STRINGLITERAL = 262,
    STRING = 263,
    FLOAT = 264,
    FLOATLITERAL = 265,
    INT = 266,
    INTLITERAL = 267,
    VOID = 268,
    FUNCTION = 269,
    READ = 270,
    WRITE = 271,
    RETURN = 272,
    IF = 273,
    FI = 274,
    ELSE = 275,
    FOR = 276,
    ROF = 277,
    ADD = 278,
    SUB = 279,
    MULT = 280,
    DIV = 281,
    EQUAL = 282,
    NEQUAL = 283,
    EXCL = 284,
    LESSTHAN = 285,
    GREATERTHAN = 286,
    LESSTHANEQ = 287,
    GREATERTHANEQ = 288,
    BRACKET_OPEN = 289,
    BRACKET_CLOSE = 290,
    SEMICOLON = 291,
    COLON = 292,
    ASSIGNMENT = 293
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 21 "microParser.y"

    int intval;
    float floatval;
    std::string* strval;
    std::vector<std::string*>* strlist;
    ASTNode* astnode;

#line 114 "microParser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_MICROPARSER_TAB_H_INCLUDED  */
