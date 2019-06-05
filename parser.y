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
%type <condition_list> condition_list
%type <condition> condition
%type <comparison_list> comparison_list
%type <comparison> comparison
%type <expression_list> expression_list

%%

file
    : file definition
    | file directive
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
    : statement_list BREAK IDENTIFIER ';'
      {
          add_statement_to_list(as_statement(create_break_statement($3)), $$);
      }
    | statement_list BREAK ';'
      {
          add_statement_to_list(as_statement(create_break_statement(NULL)), $$);
      }
    | statement_list CONTINUE IDENTIFIER ';'
      {
          add_statement_to_list(as_statement(create_continue_statement($3)), $$);
      }
    | statement_list CONTINUE ';'
      {
          add_statement_to_list(as_statement(create_continue_statement(NULL)), $$);
      }
    | statement_list DEFER call_statement ';'
      {
          add_statement_to_list(as_statement(create_defer_statement()), $$);
      }
    | statement_list IF condition_list '{'
          statement_list
      '}'
      ELSE '{'
          statement_list
      '}'
      {
          add_statement_to_list(as_statement(create_if_statement($3, /* conditions */
                                                                 $5  /* then_statements */)),
                                $$);
      }
    | statement_list IF condition_list '{'
          statement_list
      '}'
      {
          add_statement_to_list(as_statement(create_if_statement($3, /* conditions */
                                                                 $5  /* then_statements */)),
                                $$);
      }
    | statement_list RETURN expression_list ';'
      {
          add_statement_to_list(as_statement(create_return_statement($3 /* expressions */)), $$);
      }
    | statement_list RETURN ';'
      {
          add_statement_to_list(as_statement(create_return_statement(NULL)), $$);
      }
    | statement_list SWITCH expression '{'
          case_list
          DEFAULT ':'
              statement_list
      '}'
      {
          add_statement_to_list(as_statement(create_switch_statement()), $$);
      }
    | statement_list SWITCH expression '{'
          case_list
      '}'
      {
          add_statement_to_list(as_statement(create_switch_statement()), $$);
      }
    | statement_list WHILE condition_list '{'
          statement_list
      '}'
      {
          add_statement_to_list(as_statement(create_while_statement($3, /* conditions */
                                                                    $5  /* then_statements */)),
                                $$);
      }
    | statement_list assignment ';'
      {
          add_statement_to_list(as_statement(create_set_statement()), $$);
      }
    | statement_list definition ';'
      {
          add_statement_to_list(as_statement(create_define_statement()), $$);
      }
    | statement_list call_statement ';'
      {
          add_statement_to_list(as_statement(create_call_statement()), $$);
      }
    |
      {
          $$ = create_statement_list();
      }
    ;

case_list
    : case_list case
    | case
    ;

case
    : CASE expression ':' statement_list
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
    : initializer_list ',' initializer
    | initializer
    ;

initializer
    : IDENTIFIER '=' expression
    ;

enum_item_list
    : enum_item_list ',' enum_item
    | enum_item_list ','
    | enum_item
    |
    ;

enum_item
    : IDENTIFIER '=' expression
    | IDENTIFIER
    ;

struct_item_list
    : struct_item_list ';' struct_item
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
    : declarator_list ',' declarator
    | declarator
    ;

declarator
    : name '=' expression
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
    : argument_list ',' argument
    | argument
    ;

argument
    : IDENTIFIER '=' expression
    | expression
    | ETC
    ;

condition_list
    : condition_list OR condition
      {
          add_condition_to_list($3, $$);
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
    : comparison_list AND comparison
      {
          add_comparison_to_list($3, $$);
      }
    | comparison
      {
          $$ = create_comparison_list();
          add_comparison_to_list($1, $$);
      }
    ;

comparison
    : expression_list EQ expression_list
      {
          $$ = create_comparison(EQUAL_COMPARISON, $1, $3);
      }
    | expression_list NEQ expression_list
      {
          $$ = create_comparison(NOT_EQUAL_COMPARISON, $1, $3);
      }
    | expression_list '<' expression_list
      {
          $$ = create_comparison(LESS_THAN_COMPARISON, $1, $3);
      }
    | expression_list '>' expression_list
      {
          $$ = create_comparison(GREATER_THAN_COMPARISON, $1, $3);
      }
    | expression_list LTEQ expression_list
      {
          $$ = create_comparison(LESS_THAN_EQUAL_COMPARISON, $1, $3);
      }
    | expression_list GTEQ expression_list
      {
          $$ = create_comparison(GREATER_THAN_EQUAL_COMPARISON, NULL, $3);
      }
    | expression_list
      {
          $$ = create_comparison(NO_COMPARISON, $1, NULL);
      }
    ;

expression_list
    : expression_list ',' expression
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
