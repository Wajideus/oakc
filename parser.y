%{
#include <stdio.h>

#include "array.h"
#include "syntax.h"

extern void yyerror(const char *s);
extern int yylex();
extern int yyparse();
extern FILE *yyin;

extern void declare_type(const char *);
extern void compile_statements(Statement **);
%}

%union {
    const char *identifier;

    Statement **statements;
    Condition **conditions;
    Comparison **comparisons;
    Expression **expressions;

    Statement *statement;
    Condition *condition;
    Comparison *comparison;
    Expression *expression;

    Break_Statement *break_statement;
    Call_Statement *call_statement;
    Continue_Statement *continue_statement;
    Declare_Statement *declare_statement;
    Defer_Statement *defer_statement;
    Define_Statement *define_statement;
    Finish_Statement *finish_statement;
    If_Statement *if_statement;
    Return_Statement *return_statement;
    Set_Statement *set_statement;
    Switch_Statement *switch_statement;
    While_Statement *while_statement;
}

%token DDEFINE DELSE DEND DIF INCLUDE
%token CASE DEFAULT DEFER DO ELSE IF SWITCH WHILE
%token BREAK CONTINUE FINISH RETURN
%token ENUM FUNC PROC STRUCT UNION
%token BOOL CHAR DICT FLOAT INT SIZE STR TYPE UINT VOID
%token CONST EXTERN MIXIN TYPEDEF VAR
%token <identifier> IDENTIFIER
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
%type <comparisons> comparisons
%type <expressions> expressions

%type <condition> condition
%type <comparison> comparison
%type <statement> statement

%type <break_statement> break_statement
%type <call_statement> call_statement
%type <continue_statement> continue_statement
%type <declare_statement> declare_statement
%type <defer_statement> defer_statement
%type <define_statement> define_statement
%type <finish_statement> finish_statement
%type <if_statement> if_statement
%type <return_statement> return_statement
%type <set_statement> set_statement
%type <switch_statement> switch_statement
%type <while_statement> while_statement

%start translation_unit
%%

translation_unit
    : /* empty */
    | translation_unit directive
    | translation_unit anonymous_enum
    | translation_unit anonymous_struct
    | translation_unit type_definition
    | translation_unit enum_declaration
    | translation_unit struct_declaration
    | translation_unit func_declaration
    | translation_unit var_declaration
    ;

directive
    : INCLUDE strings ';'
    ;

strings
    : strings ',' STRING
    | STRING
    ;

anonymous_enum
    : ENUM '{' enum_items '}'
    | ENUM '{'            '}'
    ;

anonymous_struct
    : STRUCT '{' struct_items '}'
    | STRUCT '{'              '}'
    ;

type_definition
    : TYPEDEF enum_declaration
    | TYPEDEF struct_declaration
    | TYPEDEF FUNC IDENTIFIER type_specifier ';'
    | TYPEDEF      IDENTIFIER type_specifier ';'
    ;

enum_declaration
    : ENUM IDENTIFIER '{' enum_items '}'
    | ENUM IDENTIFIER '{'            '}'
    ;

enum_items
    :                    IDENTIFIER '=' expression
    |                    IDENTIFIER
    | enum_items ','     IDENTIFIER '=' expression
    | enum_items ','     IDENTIFIER
    | enum_items ','
    ;

struct_declaration
    : STRUCT IDENTIFIER '{' struct_items '}'
    | STRUCT IDENTIFIER '{'              '}'
    ;

struct_items
    :              struct_item
    | struct_items struct_item
    ;

struct_item
    : MIXIN     IDENTIFIER type_specifier ';'
    | MIXIN VAR IDENTIFIER type_specifier ';'
    |       VAR typed_declaration         ';'
    |           typed_declaration         ';'
    | anonymous_enum
    | anonymous_struct
    | enum_declaration
    | struct_declaration
    | func_declaration
    ;

func_declaration
    : EXTERN       FUNC IDENTIFIER function_type_specifier ';'
    |              FUNC IDENTIFIER function_type_specifier '{'
                       statements
                   '}'
      {
          compile_statements($5);
      }
    ;

parameters
    : parameters ',' parameter
    | parameter
    ;

parameter
    : unmodified_parameter
    | ETC
    ;

unmodified_parameter
    : declarator type_specifier ETC
    | declarator type_specifier
    | declarator indirection    ETC
    | declarator indirection
    | declarator                ETC
    | declarator
    ;

var_declaration
    : EXTERN VAR declarators type_specifier ';'
    |        VAR declaration                ';'
    ;

declaration
    : typed_declaration
    | declarators '=' expressions
    | declarators
    ;

typed_declaration
    : declarators type_specifier '=' expressions
    | declarators type_specifier
    ;

function_type_specifier
    : '(' parameters ')' fields type_specifier
    | '(' parameters ')'        type_specifier
    | '(' parameters ')'
    | '('            ')' fields type_specifier
    | '('            ')'        type_specifier
    | '('            ')'
    ;

declarators
    : declarators ',' declarator
    |                 declarator
    ;

declarator
    : IDENTIFIER
    | IDENTIFIER fields
    ;

fields
    :        '(' parameters ')'
    |        '('            ')'
    |        '[' expression ']'
    |        '['            ']'
    | fields '(' parameters ')'
    | fields '('            ')'
    | fields '[' expression ']'
    | fields '['            ']'
    ;

type_specifier
    :             direct_type_specifier
    | indirection direct_type_specifier
    ;

direct_type_specifier
    : IDENTIFIER
    | BOOL
    | CHAR
    | DICT
    | FLOAT
    | INT
    | PROC
    | SIZE
    | STR
    | TYPE
    | UINT
    | VOID
    ;

indirection
    :             '*'
    |             '*' CONST
    | indirection '*'
    | indirection '*' CONST
    ;

statements
    :            statement
        {
            $$ = NULL;
            add_array_element($$, $1);
        }
    | statements statement
        { add_array_element($$, $2); }
    ;

statement
    : break_statement
        { $$ = as_statement($1); }
    | call_statement
        { $$ = as_statement($1); }
    | continue_statement
        { $$ = as_statement($1); }
    | declare_statement
        { $$ = as_statement($1); }
    | defer_statement
        { $$ = as_statement($1); }
    | define_statement
        { $$ = as_statement($1); }
    | finish_statement
        { $$ = as_statement($1); }
    | if_statement
        { $$ = as_statement($1); }
    | return_statement
        { $$ = as_statement($1); }
    | set_statement
        { $$ = as_statement($1); }
    | switch_statement
        { $$ = as_statement($1); }
    | while_statement
        { $$ = as_statement($1); }
    ;

break_statement
    : BREAK IDENTIFIER ';'
        { $$ = create_break_statement($2); }
    | BREAK ';'
        { $$ = create_break_statement(NULL); }
    ;

call_statement
    : IDENTIFIER arguments ';'
        { $$ = create_call_statement(); }
    | IDENTIFIER ';'
        { $$ = create_call_statement(); }
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

continue_statement
    : CONTINUE IDENTIFIER ';'
        { $$ = create_continue_statement($2); }
    | CONTINUE ';'
        { $$ = create_continue_statement(NULL); }
    ;

declare_statement
    : enum_declaration
        { $$ = create_declare_statement(); }
    | struct_declaration
        { $$ = create_declare_statement(); }
    | func_declaration
        { $$ = create_declare_statement(); }
    | var_declaration
        { $$ = create_declare_statement(); }
    ;

defer_statement
    : DEFER call_statement
        { $$ = create_defer_statement(); }
    ;

define_statement
    : anonymous_enum
        { $$ = create_define_statement(); }
    | anonymous_struct
        { $$ = create_define_statement(); }
    | type_definition
        { $$ = create_define_statement(); }
    ;

finish_statement
    : FINISH references ';'
        { $$ = create_finish_statement(NULL); }
    ;

if_statement
    : IF conditions '{'
          statements
      '}'
      ELSE '{'
          statements
      '}'
        { $$ = create_if_statement($2, $4); }
    | IF conditions '{'
          statements
      '}'
        { $$ = create_if_statement($2, $4); }
    ;

return_statement
    : RETURN expressions ';'
        { $$ = create_return_statement($2); }
    | RETURN ';'
        { $$ = create_return_statement(NULL); }
    ;

set_statement
    : references '=' expressions ';'
        { $$ = create_set_statement(); }
    | reference ADDEQ expression ';'
        { $$ = create_set_statement(); }
    | reference SUBEQ expression ';'
        { $$ = create_set_statement(); }
    | reference MULEQ expression ';'
        { $$ = create_set_statement(); }
    | reference DIVEQ expression ';'
        { $$ = create_set_statement(); }
    | reference MODEQ expression ';'
        { $$ = create_set_statement(); }
    | reference ANDEQ expression ';'
        { $$ = create_set_statement(); }
    | reference OREQ expression ';'
        { $$ = create_set_statement(); }
    | reference XOREQ expression ';'
        { $$ = create_set_statement(); }
    | reference LSHEQ expression ';'
        { $$ = create_set_statement(); }
    | reference RSHEQ expression ';'
        { $$ = create_set_statement(); }
    | reference INC ';'
        { $$ = create_set_statement(); }
    | reference DEC ';'
        { $$ = create_set_statement(); }
    ;

switch_statement
    : SWITCH expression '{'
          cases
          DEFAULT ':'
              statements
      '}'
        { $$ = create_switch_statement(); }
    | SWITCH expression '{'
          cases
      '}'
        { $$ = create_switch_statement(); }
    ;

cases
    : cases case
    | case
    ;

case
    : CASE expression ':' statements
    ;

while_statement
    : WHILE conditions '{'
          statements
      '}'
        { $$ = create_while_statement($2, $4); }
    ;

references
    : references ',' reference
    | reference
    ;

reference
    :           direct_reference
    | asterisks direct_reference
    ;

direct_reference
    : '(' expression ')' '[' expression ']'
    | '(' expression ')' '.' IDENTIFIER
    | direct_reference '[' expression ']'
    | direct_reference '.' IDENTIFIER
    | IDENTIFIER
    ;

asterisks
    :           '*'
    | asterisks '*'
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

// TODO: ! * operators

value
    : LENGTHOF '(' reference ')'
    | NUMBEROF '(' reference ')'
    | SIZEOF   '(' reference ')'
    | value    '(' arguments ')'
    | value    '(' ')'
    | value    '[' expression ']'
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
