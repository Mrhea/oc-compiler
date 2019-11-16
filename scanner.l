/*
 * scanner.l 
 * Author: Matthew Rhea
 * CruzID: Mrhea
 */

%{

#include "astree.h"
#include "lyutils.h"

#define YY_USER_ACTION { lexer::advance(); }

extern FILE* tok_File;

int yylval_token (int symbol) {
   yylval = new astree (symbol, lexer::lloc, yytext);
   yylval->printToken(yylval, tok_File);
   return symbol;
}

%}

%option 8bit
%option debug
%option nodefault
%option nounput
%option noyywrap
%option verbose
%option warn

LETTER          [A-Za-z_]
DIGIT           [0-9]
MANTISSA        ({DIGIT}+\.?{DIGIT}*|\.{DIGIT}+)
EXPONENT        ([Ee][+-]?{DIGIT}+)
NUMBER          ({MANTISSA}{EXPONENT}?)
NOTNUMBER       ({MANTISSA}[Ee][+-]?)
IDENT           ({LETTER}({LETTER}|{DIGIT})*)
TOK_CHAR        ('([^\\'\n]|\\[\\'"0nt])')
TOK_STR         (\"([^\\"\n]|\\[\\'"0nt])*\")
NOTCHAR         ('([^\\'\n]|\\[\\'"0nt]?)[^']?)
NOTSTR          (\"([^\\"\n]|\\[\\'"0nt])*[^\"]?)
NOTIDENT        ({DIGIT}+{IDENT})





%%

"#".*           { lexer::include(); }
[ \t]+          { }
\n              { lexer::newline(); }

{NUMBER}        { return yylval_token (TOK_INT); }
{IDENT}         { return yylval_token (TOK_INTCON); }
{TOK_CHAR}      { return yylval_token (TOK_CHARCON); }
{TOK_STR}       { return yylval_token (TOK_STRINGCON); }


"="             { return yylval_token ('='); }
"+"             { return yylval_token ('+'); }
"-"             { return yylval_token ('-'); }
"*"             { return yylval_token ('*'); }
"/"             { return yylval_token ('/'); }
"^"             { return yylval_token ('^'); }
"("             { return yylval_token ('('); }
")"             { return yylval_token (')'); }
";"             { return yylval_token (';'); }
"!"             { return yylval_token ('!'); }
","             { return yylval_token (','); }
";"             { return yylval_token (';'); }
"["             { return yylval_token ('['); }
"]"             { return yylval_token (']'); }
"{"             { return yylval_token ('{'); }
"}"             { return yylval_token ('}'); }
"["             { return yylval_token ('['); }
"]"             { return yylval_token (']'); }
"."             { return yylval_token ('.'); }
"%"             { return yylval_token ('%'); }

"if"            { return yylval_token (TOK_IF); }
"else"          { return yylval_token (TOK_ELSE); }
"while"         { return yylval_token (TOK_WHILE); }
"return"        { return yylval_token (TOK_RETURN); }
"int"           { return yylval_token (TOK_INT); }
"string"        { return yylval_token (TOK_STRING); }
"struct"        { return yylval_token (TOK_STRUCT); }
"void"          { return yylval_token (TOK_VOID); }
"new"           { return yylval_token (TOK_NEW); }
"null"          { return yylval_token (TOK_NULL); }

"=="            { return yylval_token (TOK_EQ); }
"!="            { return yylval_token (TOK_NE); }
"<"             { return yylval_token (TOK_LT); }
"<="            { return yylval_token (TOK_LE); }
">"             { return yylval_token (TOK_GT); }
">="            { return yylval_token (TOK_GE); }
"[]"            { return yylval_token (TOK_ARRAY); }

{NOTNUMBER}     { lexer::badtoken (yytext);
                  return yylval_token (TOK_INT); }
{NOTCHAR}       { lexer::badtoken (yytext);
                  return yylval_token (TOK_CHAR); }
{NOTSTR}        { lexer::badtoken (yytext);
                  return yylval_token (TOK_STRING); }
{NOTIDENT}      { lexer::badtoken (yytext);
                  return yylval_token (TOK_IDENT); }
%%

