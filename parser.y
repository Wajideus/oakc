%{
#include <stdio.h>

extern void yyerror(const char *s);
extern int yylex();
extern int yyparse();
extern FILE *yyin;
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
%token NEWLINE

%%

file
    : file NEWLINE definition
    | file NEWLINE directive
    | file NEWLINE
    | definition
    | directive
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
    : statements NEWLINE statement
    | statements ';' statement
    | statements NEWLINE
    | statements ';'
    | statement
    | NEWLINE
    ;

statement
    : BREAK IDENTIFIER
    | BREAK
    | CONTINUE IDENTIFIER
    | CONTINUE
    | DEFER instruction
    | IF conditions THEN NEWLINE statements ELSE NEWLINE statements END
    | IF conditions THEN NEWLINE statements ELSE statement
    | IF conditions THEN NEWLINE statements END
    | RETURN expressions
    | RETURN
    | SWITCH expression NEWLINE cases DEFAULT NEWLINE statements END
    | SWITCH expression NEWLINE cases END
    | WHILE conditions DO NEWLINE statements END
    | assignment
    | definition
    | instruction
    ;

cases
    : cases case
    | case
    ;

case
    : CASE expression NEWLINE statements
    | CASE expression NEWLINE
    ;

assignment
    : references '=' expressions
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
    : TYPEDEF ENUM IDENTIFIER NEWLINE enumCases END
    | TYPEDEF FUNC IDENTIFIER '(' parameters ')'
    | TYPEDEF FUNC IDENTIFIER '(' ')'
    | TYPEDEF STRUCT IDENTIFIER NEWLINE structFields END
    | EXTERN FUNC IDENTIFIER '(' parameters ')'
    | EXTERN FUNC IDENTIFIER '(' ')'
    | FUNC IDENTIFIER '(' parameters ')' NEWLINE statements END
    | FUNC IDENTIFIER '(' ')' NEWLINE statements END
    ;

enumCases
    : enumCases NEWLINE enumCase
    | enumCases ',' enumCase
    | enumCases NEWLINE
    | enumCases ','
    | enumCase
    | NEWLINE
    ;

enumCase
    : IDENTIFIER '=' expression
    | IDENTIFIER
    ;

structFields
    : structFields NEWLINE structField
    | structFields ';' structField
    | structFields NEWLINE
    | structFields ';'
    | structField
    | NEWLINE
    ;

structField
    : MIXIN typeName indirection IDENTIFIER '=' expression
    | MIXIN typeName indirection IDENTIFIER
    | MIXIN STRUCT NEWLINE structFields END
    | ENUM IDENTIFIER NEWLINE enumCases END
    | ENUM NEWLINE enumCases END
    | STRUCT IDENTIFIER NEWLINE structFields END
    | STRUCT NEWLINE structFields END
    | typeName declarators
    ;

parameters
    : parameters ',' parameter
    | parameter
    ;

parameter
    : typeName declarator
    ;

typeName
    : IDENTIFIER
    | BOOL
    | CHAR
    | FLOAT
    | INT
    | STR
    | UINT
    | VOID
    ;

declarators
    : declarators ',' declarator
    | declarator
    ;

declarator
    : name '=' expression
    | name
    ;

name
    : indirection '(' '*' IDENTIFIER ')' '[' expression ']'
    | indirection '(' '*' IDENTIFIER ')' '[' ']'
    | indirection '(' '*' IDENTIFIER ')' '(' parameters ')'
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
    : IDENTIFIER arguments
    | IDENTIFIER
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
    | condition
    ;

condition
    : condition AND comparison
    | comparison
    ;

comparison
    : comparison EQ expressions
    | comparison NEQ expressions
    | comparison '<' expressions
    | comparison '>' expressions
    | comparison LTEQ expressions
    | comparison GTEQ expressions
    | expressions
    ;

expressions
    : expressions ',' expression
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
    | value '(' arguments ')'
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
