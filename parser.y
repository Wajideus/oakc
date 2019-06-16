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
    const char *identifier,
               *type_name;

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
%token CASE DEFAULT DEFER DO ELSE END IF OF SWITCH THEN WHILE
%token BREAK CONTINUE FINISH RETURN
%token ENUM PROC STRUCT UNION
%token BOOL CHAR DICT FLOAT INT STR UINT VOID
%token CONST EXTERN MIXIN TYPEDEF
%token <identifier> IDENTIFIER
%token <type_name> TYPE_NAME
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
%token NEWLINE

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
    | translation_unit NEWLINE
    | translation_unit directive
    | translation_unit anonymous_enum
    | translation_unit anonymous_struct
    | translation_unit enum_declaration
    | translation_unit struct_declaration
    | translation_unit deferred_declaration
    | translation_unit deferred_type_definition
    | translation_unit deferred_function_definition
    ;

directive
    : INCLUDE strings
    ;

strings
    : strings ',' optional_whitespace STRING
    | STRING
    ;

optional_whitespace
    : /* empty */
    | optional_whitespace NEWLINE
    ;

anonymous_enum
    : ENUM NEWLINE enum_items END NEWLINE
    | ENUM NEWLINE            END NEWLINE
    ;

anonymous_struct
    : STRUCT NEWLINE struct_items END NEWLINE
    | STRUCT NEWLINE              END NEWLINE
    ;

enum_declaration
    : ENUM IDENTIFIER NEWLINE enum_items END NEWLINE
    | ENUM IDENTIFIER NEWLINE            END NEWLINE
    ;

enum_items
    :            NEWLINE
    |                    IDENTIFIER '=' expression
    |                    IDENTIFIER
    | enum_items NEWLINE IDENTIFIER '=' expression
    | enum_items NEWLINE IDENTIFIER
    | enum_items NEWLINE
    | enum_items ',' IDENTIFIER '=' expression
    | enum_items ',' IDENTIFIER
    | enum_items ','
    ;

struct_declaration
    : STRUCT IDENTIFIER NEWLINE struct_items END NEWLINE
    | STRUCT IDENTIFIER NEWLINE              END NEWLINE
    ;

struct_items
    :              NEWLINE
    |              anonymous_enum
    |              anonymous_struct
    |              enum_declaration
    |              struct_declaration
    |              deferred_declaration
    | struct_items NEWLINE
    | struct_items anonymous_enum
    | struct_items anonymous_struct
    | struct_items enum_declaration
    | struct_items struct_declaration
    | struct_items deferred_declaration
    ;

deferred_declaration
    : deferred_declaration_specifier declarators NEWLINE
    ;

deferred_declaration_specifier
    : storage_class_specifier type_qualifiers deferred_type_specifier
    | storage_class_specifier                 deferred_type_specifier
    |                         type_qualifiers deferred_type_specifier
    |                                         deferred_type_specifier
    ;

declaration
    : declaration_specifier declarators NEWLINE
    ;

declaration_specifier
    : storage_class_specifier type_qualifiers type_specifier
    | storage_class_specifier                 type_specifier
    |                         type_qualifiers type_specifier
    |                                         type_specifier
    ;

declarators
    :                 initialized_declarator
    |                 declarator
    | declarators ',' optional_whitespace initialized_declarator
    | declarators ',' optional_whitespace declarator
    ;

declarator
    :             direct_declarator
    | indirection direct_declarator
    ;

direct_declarator
    : IDENTIFIER
    | '(' declarator ')'
    | direct_declarator '[' expression ']'
    | direct_declarator '[' ']'
    | direct_declarator '(' parameters ')'
    | direct_declarator '(' ')'
    ;

initialized_declarator
    : declarator '=' initializer
    ;

initializer
    : expression
    ;

indirection
    :             '*'
    |             '*' type_qualifiers
    | indirection '*'
    | indirection '*' type_qualifiers
    ;

storage_class_specifier
    : EXTERN
    ;

deferred_type_specifier
    : IDENTIFIER
    | type_specifier
    ;

type_specifier
    : TYPE_NAME
    | BOOL
    | CHAR
    | DICT
    | FLOAT
    | INT
    | PROC
    | STR
    | UINT
    | VOID
    ;

type_qualifiers
    :                 type_qualifier
    | type_qualifiers type_qualifier
    ;

type_qualifier
    : CONST
    | MIXIN
    ;

deferred_type_definition
    : TYPEDEF enum_declaration
    | TYPEDEF struct_declaration
    | TYPEDEF deferred_declaration
    ;

type_definition
    : TYPEDEF enum_declaration
    | TYPEDEF struct_declaration
    | TYPEDEF declaration
    ;

deferred_function_definition
    : deferred_declaration_specifier declarator DO NEWLINE
          statements
      END NEWLINE
        { compile_statements($5); }
    ;


function_definition
    : declaration_specifier declarator DO NEWLINE
          statements
      END NEWLINE
        { compile_statements($5); }
    ;


parameters
    : parameters ',' parameter
    | parameter
    ;

parameter
    : deferred_declaration_specifier declarator
    ;

statements
    :            NEWLINE
        {
            $$ = NULL;
        }
    |            statement
        {
            $$ = NULL;
            add_array_element($$, $1);
        }
    | statements NEWLINE
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
    : BREAK IDENTIFIER NEWLINE
        { $$ = create_break_statement($2); }
    | BREAK NEWLINE
        { $$ = create_break_statement(NULL); }
    ;

call_statement
    : IDENTIFIER arguments NEWLINE
        { $$ = create_call_statement(); }
    | IDENTIFIER NEWLINE
        { $$ = create_call_statement(); }
    ;

arguments
    : arguments ',' optional_whitespace argument
    | argument
    ;

argument
    : IDENTIFIER '=' expression
    | expression
    | ETC
    ;

continue_statement
    : CONTINUE IDENTIFIER NEWLINE
        { $$ = create_continue_statement($2); }
    | CONTINUE NEWLINE
        { $$ = create_continue_statement(NULL); }
    ;

declare_statement
    : enum_declaration
        { $$ = create_declare_statement(); }
    | struct_declaration
        { $$ = create_declare_statement(); }
    | declaration
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
    | function_definition
        { $$ = create_define_statement(); }
    ;

finish_statement
    : FINISH references NEWLINE
        { $$ = create_finish_statement(NULL); }
    ;

if_statement
    : IF conditions THEN NEWLINE
          statements
      ELSE NEWLINE
          statements
      END NEWLINE
        { $$ = create_if_statement($2, $5); }
    | IF conditions THEN NEWLINE
          statements
      END NEWLINE
        { $$ = create_if_statement($2, $5); }
    ;

return_statement
    : RETURN expressions NEWLINE
        { $$ = create_return_statement($2); }
    | RETURN NEWLINE
        { $$ = create_return_statement(NULL); }
    ;

set_statement
    : references '=' expressions NEWLINE
        { $$ = create_set_statement(); }
    | reference ADDEQ expression NEWLINE
        { $$ = create_set_statement(); }
    | reference SUBEQ expression NEWLINE
        { $$ = create_set_statement(); }
    | reference MULEQ expression NEWLINE
        { $$ = create_set_statement(); }
    | reference DIVEQ expression NEWLINE
        { $$ = create_set_statement(); }
    | reference MODEQ expression NEWLINE
        { $$ = create_set_statement(); }
    | reference ANDEQ expression NEWLINE
        { $$ = create_set_statement(); }
    | reference OREQ expression NEWLINE
        { $$ = create_set_statement(); }
    | reference XOREQ expression NEWLINE
        { $$ = create_set_statement(); }
    | reference LSHEQ expression NEWLINE
        { $$ = create_set_statement(); }
    | reference RSHEQ expression NEWLINE
        { $$ = create_set_statement(); }
    | reference INC NEWLINE
        { $$ = create_set_statement(); }
    | reference DEC NEWLINE
        { $$ = create_set_statement(); }
    ;

switch_statement
    : SWITCH expression OF NEWLINE
          cases
          DEFAULT NEWLINE
              statements
      END NEWLINE
        { $$ = create_switch_statement(); }
    | SWITCH expression OF NEWLINE
          cases
      END NEWLINE
        { $$ = create_switch_statement(); }
    ;

cases
    : cases case
    | case
    ;

case
    : CASE expression NEWLINE statements
    ;

while_statement
    : WHILE conditions DO NEWLINE
          statements
      END NEWLINE
        { $$ = create_while_statement($2, $5); }
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
