%{
#include <stdio.h>

#include "syntax.h"

extern void yyerror(const char *s);
extern int yylex();
extern int yyparse();
extern FILE *yyin;

extern void compile_statement_list(Statement_List *);
%}

%union {
    const char *s;
    Statement_List *statement_list;
    Statement *statement;
    Condition_List *condition_list;
    Condition *condition;
    Comparison_List *comparison_list;
    Comparison *comparison;
    Expression_List *expression_list;
    Expression *expression;
}

%token DDEFINE DELSE DEND DIF DINCLUDE
%token CASE DEFAULT DEFER DO ELSE IF SWITCH WHILE
%token BREAK CONTINUE RETURN
%token CONST ENUM PROC STRUCT TYPEDEF UNION VAR
%token BOOL CHAR FLOAT INT STR UINT VOID
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

%type <statement_list> statement_list
%type <statement> statement
%type <condition_list> condition_list
%type <condition> condition
%type <comparison_list> comparison_list
%type <comparison> comparison
%type <expression_list> expression_list

%%

file
    : file '\n' definition
    | file '\n' directive
    | file '\n'
    | definition
    | directive
    |
    ;

optional_whitespace
    : optional_whitespace '\n'
    |
    ;

directive
    : DINCLUDE string_list
    ;

string_list
    : string_list ',' STRING
    | STRING
    ;

statement_list
    : statement_list '\n' statement
      {
          add_statement_to_list($3, $$);
      }
    | statement_list ';' statement
      {
          add_statement_to_list($3, $$);
      }
    | statement_list '\n'
    | statement
      {
          $$ = create_statement_list();
          add_statement_to_list($1, $$);
      }
    |
      {
          $$ = create_statement_list();
      }
    ;

statement
    : BREAK IDENTIFIER
      {
          $$ = as_statement(create_break_statement($2));
      }
    | BREAK
      {
          $$ = as_statement(create_break_statement(NULL));
      }
    | CONTINUE IDENTIFIER
      {
          $$ = as_statement(create_continue_statement($2));
      }
    | CONTINUE
      {
          $$ = as_statement(create_continue_statement(NULL));
      }
    | DEFER call_statement
      {
          $$ = as_statement(create_defer_statement());
      }
    | IF condition_list '{'
          statement_list
      '}' '\n'
      ELSE '{'
          statement_list
      '}'
      {
          $$ = as_statement(create_if_statement($2, /* conditions */
                                                $4  /* then_statements */));
      }
    | IF condition_list '{'
          statement_list
      '}' '\n'
      ELSE statement
      {
          $$ = as_statement(create_if_statement($2, /* conditions */
                                                $4  /* then_statements */));
      }
    | IF condition_list '{'
          statement_list
      '}'
      {
          $$ = as_statement(create_if_statement($2, /* conditions */
                                                $4  /* then_statements */));
      }
    | RETURN expression_list
      {
          $$ = as_statement(create_return_statement($2 /* expressions */));
      }
    | RETURN
      {
          $$ = as_statement(create_return_statement(NULL));
      }
    | SWITCH expression '{'
          case_list
          DEFAULT '\n'
              statement_list
      '}'
      {
          $$ = as_statement(create_switch_statement());
      }
    | SWITCH expression '{'
          case_list
      '}'
      {
          $$ = as_statement(create_switch_statement());
      }
    | WHILE condition_list '{'
          statement_list
      '}'
      {
          $$ = as_statement(create_while_statement($2, /* conditions */
                                                   $4  /* do_statements */));
      }
    | assignment
      {
          $$ = as_statement(create_set_statement());
      }
    | definition
      {
          $$ = as_statement(create_define_statement());
      }
    | call_statement
      {
          $$ = as_statement(create_call_statement());
      }
    ;

case_list
    : case_list case
    | case
    ;

case
    : CASE expression '\n' statement_list
    | CASE expression
    ;

assignment
    : reference_list '=' expression_list
    | reference ADDEQ expression
    | reference SUBEQ expression
    | reference MULEQ expression
    | reference DIVEQ expression
    | reference MODEQ expression
    | reference ANDEQ expression
    | reference OREQ expression
    | reference XOREQ expression
    | reference LSHEQ expression
    | reference RSHEQ expression
    | reference INC
    | reference DEC
    ;

reference_list
    : reference_list ',' reference
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
          enum_item_list
      '}'
    | TYPEDEF type_name IDENTIFIER '(' parameter_list ')'
    | TYPEDEF type_name IDENTIFIER '(' ')'
    | TYPEDEF STRUCT IDENTIFIER '{'
          struct_item_list
      '}'
    | EXTERN type_name IDENTIFIER '(' parameter_list ')'
    | EXTERN type_name IDENTIFIER '(' ')'
    | type_name IDENTIFIER '(' parameter_list ')' '{'
          statement_list
      '}'
      {
          compile_statement_list($7);
      }
    | type_name IDENTIFIER '(' ')' '{'
          statement_list
      '}'
      {
          compile_statement_list($6);
      }
    | CONST IDENTIFIER declarator_list
    | CONST type_name declarator_list
    | CONST initializer_list
    | VAR IDENTIFIER declarator_list
    | VAR type_name declarator_list
    | VAR initializer_list
    ;

initializer_list
    : initializer_list ',' optional_whitespace initializer
    | initializer
    ;

initializer
    : IDENTIFIER '=' expression
    ;

enum_item_list
    : enum_item_list '\n' enum_item
    | enum_item_list ',' enum_item
    | enum_item_list '\n'
    | enum_item_list ','
    | enum_item
    |
    ;

enum_item
    : IDENTIFIER '=' expression
    | IDENTIFIER
    ;

struct_item_list
    : struct_item_list '\n' struct_item
    | struct_item_list ';' struct_item
    | struct_item_list '\n'
    | struct_item_list ';'
    | struct_item
    |
    ;

struct_item
    : MIXIN IDENTIFIER indirection IDENTIFIER '=' expression
    | MIXIN IDENTIFIER indirection IDENTIFIER
    | MIXIN FIXTO reference VIA IDENTIFIER IDENTIFIER
    | MIXIN type_name indirection IDENTIFIER '=' expression
    | MIXIN type_name indirection IDENTIFIER
    | MIXIN FIXTO reference VIA type_name IDENTIFIER
    | MIXIN STRUCT '{'
          struct_item_list
      '}'
    | FIXTO reference VIA type_name IDENTIFIER
    | ENUM IDENTIFIER '{'
          enum_item_list
      '}'
    | ENUM '{'
          enum_item_list
      '}'
    | STRUCT IDENTIFIER '{'
          struct_item_list
      '}'
    | STRUCT '{'
          struct_item_list
      '}'
    | IDENTIFIER declarator_list
    | type_name declarator_list
    ;

parameter_list
    : parameter_list ',' parameter
    | parameter
    ;

parameter
    : type_name declarator
    ;

type_name
    : BOOL
    | CHAR
    | FLOAT
    | INT
    | PROC
    | STR
    | UINT
    | VOID
    ;

declarator_list
    : declarator_list ',' optional_whitespace declarator
    | declarator
    ;

declarator
    : name '=' optional_whitespace expression
    | name
    ;

name
    : indirection '(' '*' IDENTIFIER ')' '[' expression ']'
    | indirection '(' '*' IDENTIFIER ')' '[' ']'
    | indirection '(' '*' IDENTIFIER ')' '(' parameter_list ')'
    | indirection '(' '*' IDENTIFIER ')' '(' ')'
    | indirection IDENTIFIER
    | name '[' expression ']'
    | name '[' ']'
    ;

indirection
    : indirection '*'
    |
    ;

call_statement
    : IDENTIFIER argument_list
    | IDENTIFIER
    ;

argument_list
    : argument_list ',' optional_whitespace argument
    | argument
    ;

argument
    : IDENTIFIER '=' expression
    | expression
    | ETC
    ;

condition_list
    : condition_list optional_whitespace OR optional_whitespace condition
      {
          add_condition_to_list($5, $$);
      }
    | condition
      {
          $$ = create_condition_list();
          add_condition_to_list($1, $$);
      }
    ;

condition
    : comparison_list
      {
          $$ = create_condition($1);
      }
    ;

comparison_list
    : comparison_list AND optional_whitespace comparison
      {
          add_comparison_to_list($4, $$);
      }
    | comparison
      {
          $$ = create_comparison_list();
          add_comparison_to_list($1, $$);
      }
    ;

comparison
    : expression_list EQ optional_whitespace expression_list
      {
          $$ = create_comparison(EQUAL_COMPARISON, $1, $4);
      }
    | expression_list NEQ optional_whitespace expression_list
      {
          $$ = create_comparison(NOT_EQUAL_COMPARISON, $1, $4);
      }
    | expression_list '<' optional_whitespace expression_list
      {
          $$ = create_comparison(LESS_THAN_COMPARISON, $1, $4);
      }
    | expression_list '>' optional_whitespace expression_list
      {
          $$ = create_comparison(GREATER_THAN_COMPARISON, $1, $4);
      }
    | expression_list LTEQ optional_whitespace expression_list
      {
          $$ = create_comparison(LESS_THAN_EQUAL_COMPARISON, $1, $4);
      }
    | expression_list GTEQ optional_whitespace expression_list
      {
          $$ = create_comparison(GREATER_THAN_EQUAL_COMPARISON, NULL, $4);
      }
    | expression_list
      {
          $$ = create_comparison(NO_COMPARISON, $1, NULL);
      }
    ;

expression_list
    : expression_list ',' optional_whitespace expression
      {
          add_expression_to_list(create_expression(), $$);
      }
    | expression
      {
          $$ = create_expression_list();
          add_expression_to_list(create_expression(), $$);
      }
    ;

expression
    : expression '+' optional_whitespace term
    | expression '-' optional_whitespace term
    | expression '|' optional_whitespace term
    | expression '^' optional_whitespace term
    | term
    ;

term
    : term '*' optional_whitespace value
    | term '/' optional_whitespace value
    | term '%' optional_whitespace value
    | term '&' optional_whitespace value
    | term LSH optional_whitespace value
    | term RSH optional_whitespace value
    | value
    ;

// TODO: ! & * operators

value
    : LENGTHOF '(' reference ')'
    | NUMBEROF '(' reference ')'
    | SIZEOF '(' reference ')'
    | value '(' argument_list ')'
    | value '[' expression ']'
    | value '.' IDENTIFIER
    | '(' condition_list ')'
    | IDENTIFIER
    | NUMBER
    | STRING
    | KFALSE
    | KTRUE
    | KNULL
    ;

%%
