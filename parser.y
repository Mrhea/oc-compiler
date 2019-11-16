%{
 // Parser for assginment 3

#include <cassert>
#include <stdlib.h>
#include <string.h>

#include "lyutils.h"
#include "astree.h"

%}

%debug
%defines
%error-verbose
%token-table
%verbose

%destructor { destroy ($$); } <>
%printer { astree::dump (yyoutput, $$); } <>

%initial-action {
   parser::root = new astree (TOK_ROOT, {0, 0, 0}, "<<TOK_ROOT>>");
}

%token    TOK_ROOT TOK_IDENT TOK_FIELD TOK_DECLID 

%token    TOK_TYPEID TOK_POS TOK_NEG TOK_INDEX

%token    TOK_CALL TOK_NEW TOK_NEWARRAY TOK_NEWSTRING

%token    TOK_WHILE TOK_RETURN TOK_RETURNVOID TOK_IFELSE

%token    TOK_BLOCK TOK_VARDECL TOK_FUNCTION TOK_PARAMLIST

%token    TOK_PROTOTYPE TOK_ARRAY TOK_IF TOK_ELSE 

%token    TOK_INTCON TOK_CHARCON TOK_STRINGCON TOK_INT TOK_STRUCT

%token    TOK_NULL TOK_LT TOK_GT TOK_GE TOK_CHAR TOK_STRING TOK_VOID 

%token    TOK_LE TOK_NE TOK_EQ 

%token    '[' ']' '(' ')' ';' '{' '}' ',' '.' '<' '>'

%token    '+' '-' '=' '*' '/' '%' '!' 

%right    TOK_IF TOK_ELSE
%right    '='
%left     TOK_EQ TOK_NEQ '<' TOK_LEQ '>' TOK_GEQ
%left     '+' '-'
%left     '*' '/' '%'
%right    TOK_POS TOK_NEG '!' TOK_NEW
%right    '^'
%left     TOK_ARRAY TOK_FIELD TOK_FUNCTION
%left     '[' '.'

%nonassoc '('


%start start

%%

start   : program           { $$ = $1 = nullptr; }
        ;
program : program structdef { $$ = $1->adopt ($2); }
        | program function  { $$ = $1->adopt ($2); }
        | program statement { $$ = $1->adopt ($2); }
        | program error '}' { destroy($3); $$ = $1; }
        | program error ';' { destroy($3); $$ = $1; }
        |                   { $$ = parser::root; }
        ;

structdef  : TOK_STRUCT TOK_IDENT '{' fielddecls '}'   {destroy($3, $5);
                                       $2 = $2->sub($2, TOK_TYPEID);
                                       $$ = $1->adopt($2, $4);}
            | TOK_STRUCT TOK_IDENT '{' '}'              {destroy($3, $4);
                                       $2 = $2->sub($2, TOK_TYPEID);
                                       $$ = $1->adopt($2);}
            ;

fielddecl   : basetype TOK_IDENT    {           $2 = $2->sub($2, TOK_FIELD);
                                                $$ = $1->adopt($2);}
            | basetype TOK_NEWARRAY TOK_IDENT  {$3 = $3->sub($3, TOK_FIELD);
                                                $$ = $2->adopt($1, $3);}
            ;

fielddecls  : fielddecl ';' fielddecls     {destroy($2);
                                            $$ = $1->adopt($3);}
            | fielddecl ';'                    {destroy($2); 
                                            $$ = $1;}
            ;

basetype    : TOK_VOID     {$$ = $1;}
            | TOK_INT      {$$ = $1;}
            | TOK_STRING   {$$ = $1;}
            | TOK_IDENT    {$$ = $1->sub($1, TOK_TYPEID);
                            $$ = $1;}    
            ;

function    : identdecl '(' identdecls ')' block     {$4 = $4->sub($4, TOK_FUNCTION);
                                                     $2 = $2->sub($2, TOK_PARAMLIST);
                                                     $2->adopt($3);
                                                     $$ = $4->adopt($1, $2, $5);}

            | identdecl '(' ')' ';'                 {destroy($4);
                                                     $3 = $3->sub($3, TOK_PROTOTYPE);
                                                     $2 = $2->sub($2, TOK_PARAMLIST);
                                                     $$ = $3->adopt($1, $2);}

            | identdecl '(' ')' block               {$3 = $3->sub($3, TOK_FUNCTION);
                                                     $2 = $2->sub($2, TOK_PARAMLIST);
                                                     $$ = $3->adopt($1, $2, $4);}

            | identdecl '(' identdecls ')' ';'       {destroy($5);
                                                     $2 = $2->sub($2, TOK_PARAMLIST);
                                                     $4 = $4->sub($4, TOK_FUNCTION);
                                                     $2 = $2->adopt($3);
                                                     $$ = $4->adopt($1, $2);}
            ;

identdecl   : basetype TOK_IDENT             {$2 = $2->sub($2, TOK_DECLID);
                                              $$ = $1->adopt($2);}
            | basetype TOK_ARRAY TOK_IDENT   {$3 = $3->sub($3, TOK_DECLID);
                                              $$ = $2->adopt($1, $3);}
            ;

identdecls  : identdecls '.' identdecl {destroy($2);
                                        $$ = $1->adopt($3);}
            | identdecl                {$$ = $1;}
            ;

block       : statements '}'         {destroy($2);
                                     $$ = $1->sub($1, TOK_BLOCK);
                                     $$ = $1;}    
            | '{' '}'               {destroy($2);
                                     $1 = $1->sub($1, TOK_BLOCK);
                                     $$ = $1;}
            ;


statement   : block     {$$ = $1;}
            | vardecl   {$$ = $1;}
            | while     {$$ = $1;}
            | ifelse    {$$ = $1;}
            | return    {$$ = $1;}
            | expr ';'  {destroy($2);
                         $$ = $1;}
            | ';'       { $$ = $1; }
            ;

statements  : statements statement  { $$ = $1->adopt($2); }
            | '{' statement         { $$ = $1->adopt($2); }
            ;

vardecl     : identdecl '=' expr ';'     {destroy($4);
                                          $2 = $2->sub($2, TOK_VARDECL);
                                          $$ = $2->adopt($1, $3);}
            ;

while       : TOK_WHILE '(' expr ')' statement     {destroy($2, $4);
                                                    $$ = $1->adopt($3, $5);}
            ;

ifelse      : TOK_IF '(' expr ')' statement %prec TOK_IF        {destroy($2, $4);
                                                                 $$ = $1->adopt($3, $5);}
            | TOK_IF '(' expr ')' statement TOK_ELSE statement  {destroy($2, $4);
                                                                 destroy($5, $6);
                                                                 $1 = $1->sub($1, TOK_IFELSE);
                                                                 $$ = $1->adopt($3, $5, $7);}
            ;

return      : TOK_RETURN ';'        {destroy($2);
                                     $$ = $1->sub($1, TOK_RETURNVOID);}
            | TOK_RETURN expr ';'    {destroy($3);
                                     $$ = $1->adopt($2);}
            ;

expr        : expr '=' expr             { $$ = $2->adopt ($1, $3); }
            | expr '+' expr             { $$ = $2->adopt ($1, $3); }
            | expr '-' expr             { $$ = $2->adopt ($1, $3); }
            | expr '*' expr             { $$ = $2->adopt ($1, $3); }
            | expr '/' expr             { $$ = $2->adopt ($1, $3); } 
            | '+' expr %prec TOK_POS    { $$ = $1->adopt_sym ($2, TOK_POS); }
            | '-' expr %prec TOK_NEG    { $$ = $1->adopt_sym ($2, TOK_NEG); }
            | expr '>' expr             { $$ = $2->adopt ($1, $3);}
            | expr '<' expr             { $$ = $2->adopt ($1, $3);}
            | allocator                 { $$ = $1; }
            | call                      { $$ = $1; }
            | '(' expr ')'              { destroy ($1, $3); $$ = $2; }
            | variable                  { $$ = $1; }
            | constant                  { $$ = $1; }
            ;

param      : TOK_IDENT '(' expr    {$$ = $2->adopt($1,$3);}
            | param ',' expr   {destroy($2);
                                 $$ = $1->adopt($3);}
            ;


allocator   : TOK_NEW TOK_IDENT '('')'       {destroy($3, $4);
                                              $2 = $2->sub($2, TOK_FIELD);
                                              $$ = $1->adopt($2);}
            | TOK_NEW TOK_STRING '('expr')'  {destroy($2, $3, $5);
                                              $1 = $1->sub($1, TOK_NEWSTRING);
                                              $$ = $1->adopt($4);}
            | TOK_NEW basetype '['expr']'    {destroy($3, $5);
                                              $1 = $1->sub($1, TOK_NEWARRAY);
                                              $$ = $1->adopt($2, $4);}
            ;

call        : param ')'  {destroy($2);
                                    $1 = $1->sub($1, TOK_CALL);
                                    $$ = $1;}
            | TOK_IDENT '(' ')'     {destroy($3);
                                     $2 = $2->sub($2, TOK_CALL);
                                     $$ = $2->adopt($1);}             
            ;

variable    : TOK_IDENT             {$$ = $1 = $1->sub($1, TOK_FIELD);}
            | expr '[' expr ']'     {destroy($4);
                                     $$ = $2->adopt($1,$3);}
            | expr '.' TOK_IDENT    {destroy($2);
                                     $3 = $3->sub($3, TOK_FIELD);
                                     $$ = $2->adopt($1, $3);}
            ;

constant    : TOK_INTCON     {$$ = $1;}
            | TOK_CHARCON    {$$ = $1;}
            | TOK_STRINGCON  {$$ = $1;}
            | TOK_NULL       {$$ = $1;}
            ;

%%

const char* parser::get_tname (int symbol) {
   return yytname [YYTRANSLATE (symbol)];
}


bool is_defined_token (int symbol) {
   return YYTRANSLATE (symbol) > YYUNDEFTOK;
}

