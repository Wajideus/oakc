%{
#include <stdio.h>

extern void yyerror(const char *s);
extern int yylex();
extern int yyparse();
extern FILE *yyin;

extern int line_number;
%}

%union {
    const char *s;
}

%token DDEFINE DELSE DEND DIF DINCLUDE
%token CASE DEFAULT DEFER DO ELSE IF SWITCH THEN WHILE
%token BREAK CONTINUE END RETURN
%token ENUM FUNC STRUCT TYPEDEF UNION
%token BOOL CHAR FLOAT INT STR UINT VOID
%token EXTERN MIXIN TYPENAME
%token <s> IDENTIFIER
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

%%

file
    : file '\n' definition
    | file '\n' directive
    | file '\n'
    | definition
    | directive
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
    | statement_list ';' statement
    | statement_list '\n'
    | statement_list ';'
    | statement
    | '\n'
    ;

statement
    : BREAK IDENTIFIER
    | BREAK
    | CONTINUE IDENTIFIER
    | CONTINUE
    | DEFER instruction
    | IF condition_list THEN '\n'
          statement_list
      ELSE '\n'
          statement_list
      END
    | IF condition_list THEN '\n'
          statement_list
      ELSE statement
    | IF condition_list THEN '\n'
          statement_list
      END
    | RETURN expression_list
    | RETURN
    | SWITCH expression '\n'
          case_list
          DEFAULT '\n'
              statement_list
      END
    | SWITCH expression '\n'
          case_list
      END
    | WHILE condition_list DO '\n'
          statement_list
      END
    | assignment
    | definition
    | instruction
    ;

case_list
    : case_list case
    | case
    ;

case
    : CASE expression '\n' statement_list
    | CASE expression '\n'
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
    : TYPEDEF ENUM IDENTIFIER '\n'
          enum_item_list
      END
    | TYPEDEF FUNC IDENTIFIER '(' parameter_list ')'
    | TYPEDEF FUNC IDENTIFIER '(' ')'
    | TYPEDEF STRUCT IDENTIFIER '\n'
          struct_item_list
      END
    | EXTERN FUNC IDENTIFIER '(' parameter_list ')'
    | EXTERN FUNC IDENTIFIER '(' ')'
    | FUNC IDENTIFIER '(' parameter_list ')' '\n'
          statement_list
      END
    | FUNC IDENTIFIER '(' ')' '\n'
          statement_list
      END
    ;

enum_item_list
    : enum_item_list '\n' enum_item
    | enum_item_list ',' enum_item
    | enum_item_list '\n'
    | enum_item_list ','
    | enum_item
    | '\n'
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
    | '\n'
    ;

struct_item
    : MIXIN type_name indirection IDENTIFIER '=' expression
    | MIXIN type_name indirection IDENTIFIER
    | MIXIN STRUCT '\n'
          struct_item_list
      END
    | ENUM IDENTIFIER '\n'
          enum_item_list
      END
    | ENUM '\n'
          enum_item_list
      END
    | STRUCT IDENTIFIER '\n'
          struct_item_list
      END
    | STRUCT '\n'
          struct_item_list
      END
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
    : IDENTIFIER
    | BOOL
    | CHAR
    | FLOAT
    | INT
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

instruction
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
    | condition
    ;

condition
    : condition AND comparison
    | comparison
    ;

comparison
    : comparison EQ expression_list
    | comparison NEQ expression_list
    | comparison '<' expression_list
    | comparison '>' expression_list
    | comparison LTEQ expression_list
    | comparison GTEQ expression_list
    | expression_list
    ;

expression_list
    : expression_list ',' expression
    | expression
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
