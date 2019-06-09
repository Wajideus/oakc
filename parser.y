%{
#include <stdio.h>

#include "array.h"
#include "syntax.h"

extern void yyerror(const char *s);
extern int yylex();
extern int yyparse();
extern FILE *yyin;

extern void compile_statements(Statement **);
%}

%union {
    const char *s;
    Statement **statements;
    Statement *statement;
    Condition **conditions;
    Condition *condition;
    Comparison **comparisons;
    Comparison *comparison;
    Expression **expressions;
    Expression *expression;
}

%token DDEFINE DELSE DEND DIF DINCLUDE
%token CASE DEFAULT DEFER DO ELSE IF SWITCH WHILE
%token BREAK CONTINUE FINISH RETURN
%token CONST ENUM PROC STRUCT TYPEDEF UNION VAR
%token BOOL CHAR DICT FLOAT INT STR UINT VOID
%token EXTERN FIXTO MIXIN VIA
%token <s> IDENTIFIER TYPENAME
%token NUMBER
%token STRING
%token KFALSE KNULL KTRUE
%token LENGTHOF NUMBEROF SIZEOF
%token LSH RSH
%token LTEQ GTEQ EQ NEQ
%token AND OR
%token ADDEQ SUBEQ MULEQ DIVEQ MODEQ
%token LSHEQ RSHEQ ANDEQ OREQ XOREQ 
%token INC DEC
%token ETC

%type <statements> statements
%type <conditions> conditions
%type <condition> condition
%type <comparisons> comparisons
%type <comparison> comparison
%type <expressions> expressions

%%

file
    : file definition
    | file directive
    |
    ;

directive
    : DINCLUDE strings
    ;

strings
    : strings ',' STRING
    | STRING
    ;

statements
    : statements BREAK IDENTIFIER ';'
      {
          add_array_element($$, as_statement(create_break_statement($3)));
      }
    | statements BREAK ';'
      {
          add_array_element($$, as_statement(create_break_statement(NULL)));
      }
    | statements CONTINUE reference ';'
      {
          add_array_element($$, as_statement(create_continue_statement(NULL)));
      }
    | statements CONTINUE ';'
      {
          add_array_element($$, as_statement(create_continue_statement(NULL)));
      }
    | statements DEFER call_statement
      {
          add_array_element($$, as_statement(create_defer_statement()));
      }
    | statements FINISH reference ';'
      {
          add_array_element($$, as_statement(create_finish_statement(NULL)));
      }
    | statements IF conditions '{'
          statements
      '}'
      ELSE '{'
          statements
      '}'
      {
          add_array_element($$, as_statement(create_if_statement($3, /* conditions */
                                                                 $5  /* then_statements */)));
      }
    | statements IF conditions '{'
          statements
      '}'
      {
          add_array_element($$, as_statement(create_if_statement($3, /* conditions */
                                                                 $5  /* then_statements */)));
      }
    | statements RETURN expressions ';'
      {
          add_array_element($$, as_statement(create_return_statement($3 /* expressions */)));
      }
    | statements RETURN ';'
      {
          add_array_element($$, as_statement(create_return_statement(NULL)));
      }
    | statements SWITCH expression '{'
          cases
          DEFAULT ':'
              statements
      '}'
      {
          add_array_element($$, as_statement(create_switch_statement()));
      }
    | statements SWITCH expression '{'
          cases
      '}'
      {
          add_array_element($$, as_statement(create_switch_statement()));
      }
    | statements WHILE conditions '{'
          statements
      '}'
      {
          add_array_element($$, as_statement(create_while_statement($3, /* conditions */
                                                                    $5  /* do_statements */)));
      }
    | statements assignment
      {
          add_array_element($$, as_statement(create_set_statement()));
      }
    | statements definition
      {
          add_array_element($$, as_statement(create_define_statement()));
      }
    | statements call_statement
      {
          add_array_element($$, as_statement(create_call_statement()));
      }
    | statements '{' statements '}'
    |
      {
          $$ = NULL;
      }
    ;

cases
    : cases case
    | case
    ;

case
    : CASE expression ':' statements
    ;

assignment
    : references '=' expressions ';'
    | reference ADDEQ expression ';'
    | reference SUBEQ expression ';'
    | reference MULEQ expression ';'
    | reference DIVEQ expression ';'
    | reference MODEQ expression ';'
    | reference ANDEQ expression ';'
    | reference OREQ expression ';'
    | reference XOREQ expression ';'
    | reference LSHEQ expression ';'
    | reference RSHEQ expression ';'
    | reference INC ';'
    | reference DEC ';'
    ;

references
    : references ',' reference
    | reference
    ;

reference
    : '(' expression ')' '[' expression ']'
    | '(' expression ')' '.' IDENTIFIER
    | reference '[' expression ']'
    | reference '.' IDENTIFIER
    | IDENTIFIER
    ;

definition
    : TYPEDEF ENUM IDENTIFIER '{'
          enum_items
      '}'
    | TYPEDEF STRUCT IDENTIFIER '{'
          struct_items
      '}'
    | TYPEDEF type IDENTIFIER '(' parameters ')' ';'
    | TYPEDEF type IDENTIFIER '(' ')' ';'
    | EXTERN type IDENTIFIER '(' parameters ')' ';'
    | EXTERN type IDENTIFIER '(' ')' ';'
    | type IDENTIFIER '(' parameters ')' '{'
          statements
      '}'
      {
          compile_statements($7);
      }
    | type IDENTIFIER '(' ')' '{'
          statements
      '}'
      {
          compile_statements($6);
      }
    | CONST IDENTIFIER indirection '(' parameters ')' declarators';'
    | CONST IDENTIFIER indirection '(' ')' declarators';'
    | CONST IDENTIFIER indirection '[' expression ']' declarators';'
    | CONST IDENTIFIER indirection '[' ']' declarators';'
    | CONST IDENTIFIER indirection declarators ';'
    | CONST type declarators ';'
    | CONST initializers ';'
    | VAR type declarators ';'
    | VAR initializers ';'
    ;

initializers
    : initializers ',' initializer
    | initializer
    ;

initializer
    : IDENTIFIER '=' expression
    ;

enum_items
    : enum_items ',' enum_item
    | enum_items ','
    | enum_item
    |
    ;

enum_item
    : IDENTIFIER '=' expression
    | IDENTIFIER
    ;

struct_items
    : struct_items struct_item
    |
    ;

struct_item
    : MIXIN IDENTIFIER indirection IDENTIFIER '=' expression ';'
    | MIXIN IDENTIFIER indirection IDENTIFIER ';'
    | MIXIN FIXTO reference VIA IDENTIFIER IDENTIFIER ';'
    | MIXIN FIXTO reference VIA type_name IDENTIFIER ';'
    | MIXIN type IDENTIFIER '=' expression ';'
    | MIXIN type IDENTIFIER ';'
    | MIXIN STRUCT '{'
          struct_items
      '}'
    | FIXTO reference VIA type_name IDENTIFIER ';'
    | ENUM IDENTIFIER '{'
          enum_items
      '}'
    | ENUM '{'
          enum_items
      '}'
    | STRUCT IDENTIFIER '{'
          struct_items
      '}'
    | STRUCT '{'
          struct_items
      '}'
    | IDENTIFIER indirection '(' parameters ')' declarators ';'
    | IDENTIFIER indirection '(' ')' declarators ';'
    | IDENTIFIER indirection '[' expression ']' declarators ';'
    | IDENTIFIER indirection '[' ']' declarators ';'
    | IDENTIFIER indirection declarators ';'
    | type declarators ';'
    ;

parameters
    : parameters ',' parameter
    | parameter
    ;

parameter
    : IDENTIFIER indirection '(' parameters ')' IDENTIFIER ';'
    | IDENTIFIER indirection '(' ')' IDENTIFIER ';'
    | IDENTIFIER indirection '[' expression ']' IDENTIFIER ';'
    | IDENTIFIER indirection '[' ']' IDENTIFIER ';'
    | IDENTIFIER indirection IDENTIFIER ';'
    | type IDENTIFIER
    ;

type
    : type_name '(' parameters ')'
    | type_name '(' ')'
    | type_name indirection '[' expression ']'
    | type_name indirection '[' ']'
    | type_name
    ;

type_name
    : BOOL
    | CHAR
    | DICT
    | FLOAT
    | INT
    | PROC
    | STR
    | UINT
    | VOID
    ;

declarators
    : declarators ',' declarator
    | declarator
    ;

declarator
    : IDENTIFIER '=' expression
    | IDENTIFIER
    ;

indirection
    : indirection '*'
    |
    ;

call_statement
    : IDENTIFIER arguments ';'
    | IDENTIFIER ';'
    ;

arguments
    : arguments ',' argument
    | argument
    ;

argument
    : IDENTIFIER '=' expression
    | expression
    | ETC
    ;

conditions
    : conditions OR condition
      {
          add_array_element($$, $3);
      }
    | condition
      {
          $$ = NULL;
          add_array_element($$, $1);
      }
    ;

condition
    : comparisons
      {
          $$ = create_condition($1);
      }
    ;

comparisons
    : comparisons AND comparison
      {
          add_array_element($$, $3);
      }
    | comparison
      {
          $$ = NULL;
          add_array_element($$, $1);
      }
    ;

comparison
    : expressions EQ expressions
      {
          $$ = create_comparison(EQUAL_COMPARISON, $1, $3);
      }
    | expressions NEQ expressions
      {
          $$ = create_comparison(NOT_EQUAL_COMPARISON, $1, $3);
      }
    | expressions '<' expressions
      {
          $$ = create_comparison(LESS_THAN_COMPARISON, $1, $3);
      }
    | expressions '>' expressions
      {
          $$ = create_comparison(GREATER_THAN_COMPARISON, $1, $3);
      }
    | expressions LTEQ expressions
      {
          $$ = create_comparison(LESS_THAN_EQUAL_COMPARISON, $1, $3);
      }
    | expressions GTEQ expressions
      {
          $$ = create_comparison(GREATER_THAN_EQUAL_COMPARISON, NULL, $3);
      }
    | expressions
      {
          $$ = create_comparison(NO_COMPARISON, $1, NULL);
      }
    ;

expressions
    : expressions ',' expression
      {
          add_array_element($$, create_expression());
      }
    | expression
      {
          $$ = NULL;
          add_array_element($$, create_expression());
      }
    ;

expression
    : expression '+' term
    | expression '-' term
    | expression '|' term
    | expression '^' term
    | term
    ;

term
    : term '*' value
    | term '/' value
    | term '%' value
    | term '&' value
    | term LSH value
    | term RSH value
    | value
    ;

// TODO: ! & * operators

value
    : LENGTHOF '(' reference ')'
    | NUMBEROF '(' reference ')'
    | SIZEOF '(' reference ')'
    | value '(' arguments ')'
    | value '(' ')'
    | value '[' expression ']'
    | value '.' IDENTIFIER
    | '(' conditions ')'
    | IDENTIFIER
    | NUMBER
    | STRING
    | KFALSE
    | KTRUE
    | KNULL
    ;

%%
