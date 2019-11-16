/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

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

#ifndef YY_YY_YYPARSE_H_INCLUDED
# define YY_YY_YYPARSE_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    TOK_ROOT = 258,
    TOK_IDENT = 259,
    TOK_FIELD = 260,
    TOK_DECLID = 261,
    TOK_TYPEID = 262,
    TOK_POS = 263,
    TOK_NEG = 264,
    TOK_INDEX = 265,
    TOK_CALL = 266,
    TOK_NEW = 267,
    TOK_NEWARRAY = 268,
    TOK_NEWSTRING = 269,
    TOK_WHILE = 270,
    TOK_RETURN = 271,
    TOK_RETURNVOID = 272,
    TOK_IFELSE = 273,
    TOK_BLOCK = 274,
    TOK_VARDECL = 275,
    TOK_FUNCTION = 276,
    TOK_PARAMLIST = 277,
    TOK_PROTOTYPE = 278,
    TOK_ARRAY = 279,
    TOK_IF = 280,
    TOK_ELSE = 281,
    TOK_INTCON = 282,
    TOK_CHARCON = 283,
    TOK_STRINGCON = 284,
    TOK_INT = 285,
    TOK_STRUCT = 286,
    TOK_NULL = 287,
    TOK_LT = 288,
    TOK_GT = 289,
    TOK_GE = 290,
    TOK_CHAR = 291,
    TOK_STRING = 292,
    TOK_VOID = 293,
    TOK_LE = 294,
    TOK_NE = 295,
    TOK_EQ = 296,
    TOK_NEQ = 297,
    TOK_LEQ = 298,
    TOK_GEQ = 299
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_YYPARSE_H_INCLUDED  */
