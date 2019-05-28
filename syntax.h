#ifndef SYNTAX_H
#define SYNTAX_H

// Declaration | Expression | Statement


typedef enum {
    PRODUCT_EXPRESSION
} Expression_Type;

typedef struct {
    Expression_Type type;
} Expression;

// Items in an expression list are combined with ','
typedef struct Expression_List_Item {
    struct Expression_List_Item *next;
    Expression expression;
} Expression_List_Item;

typedef struct {
    Expression_List_Item *first,
                              *last;
} Expression_List;

typedef enum {
    EQUAL_COMPARISON,              // ==
    NOT_EQUAL_COMPARISON,          // !=
    LESS_THAN_COMPARISON,          // <
    GREATER_THAN_COMPARISON,       // >
    LESS_THAN_EQUAL_COMPARISON,    // <=
    GREATER_THAN_EQUAL_COMPARISON  // >=
} Comparison_Type;

typedef struct {
    Comparison_Type type;
    Expression_List *left_expressions;
    Expression_List *right_expressions;
} Comparison;

// Items in a comparison list are combined with '&&'
typedef struct Comparison_List_Item {
    struct Comparison_List_Item *next;
    Comparison comparison;
} Comparison_List_Item;

typedef struct {
    Comparison_List_Item *first,
                              *last;
} Comparison_List;

// A condition is a list of comparisons
typedef struct {
    Comparison_List *comparisons;
} Condition;

// Items in a condition list are combined with '||'
typedef struct Condition_List_Item {
    struct Condition_List_Item *next;
    Condition condition;
} Condition_List_Item;

typedef struct {
    Condition_List_Item *first,
                             *last;
} Condition_List;


typedef struct Statement_List Statement_List;

typedef struct {
    const char *identifier;
} Break_Statement;

typedef struct {
} Call_Statement;

typedef struct {
    const char *identifier;
} Continue_Statement;

typedef struct {
    Call_Statement *call_statement;
} Defer_Statement;

typedef struct {
    Condition_List *conditions;
    Statement_List *then_statements;
} If_Statement;

typedef struct {
    Expression_List *expressions;
} Return_Statement;

typedef struct {
} Set_Statement;

typedef struct {
} Switch_Statement;

typedef struct {
    Condition_List *conditions;
    Statement_List *do_statements;
} While_Statement;

typedef enum {
    BREAK_STATEMENT,
    CALL_STATEMENT,
    CONTINUE_STATEMENT,
    DEFER_STATEMENT,
    IF_STATEMENT,
    RETURN_STATEMENT,
    SET_STATEMENT,
    SWITCH_STATEMENT,
    WHILE_STATEMENT
} Statement_Type;

typedef struct {
    Statement_Type type;
    union {
        Break_Statement break_statement;
        Call_Statement call_statement;
        Continue_Statement continue_statement;
        Defer_Statement defer_statement;
        If_Statement if_statement;
        Return_Statement return_statement;
        Set_Statement set_statement;
        Switch_Statement switch_statement;
        While_Statement while_statement;
    } as;
} Statement;

// Items in a statement list are separated by '\n' or ';'
typedef struct Statement_List_Item {
    struct Statement_List_Item *next;
    Statement statement;
} Statement_List_Item;

struct Statement_List {
    Statement_List_Item *first,
                             *last;
};


// Building Functions (Contained in "builder.c")

Expression_List *
create_expression_list(void);

Expression *
add_expression(Expression_List *expressions);


Comparison_List *
create_comparison_list(void);

Comparison *
add_comparison(Comparison_List *comparisons);


Condition_List *
create_condition_list(void);

Condition *
add_condition(Condition_List *conditions);


Statement_List *
    create_statement_list(void);

Break_Statement *
add_break_statement(Statement_List *statements,
                         const char *identifier);

Call_Statement *
add_call_statement(Statement_List *statements);

Continue_Statement *
add_continue_statement(Statement_List *statements,
                            const char *identifier);

Defer_Statement *
add_defer_statement(Statement_List *statements);

If_Statement *
add_if_statement(Statement_List *statements,
                      Condition_List *conditions,
                      Statement_List *then_statements);

Return_Statement *
add_return_statement(Statement_List *statements,
                          Expression_List *expressions);

Set_Statement *
add_set_statement(Statement_List *statements);

Switch_Statement *
add_switch_statement(Statement_List *statements);

While_Statement *
add_while_statement(Statement_List *statements,
                         Condition_List *conditions,
                         Statement_List *do_statements);


// Printing Functions (Contained in "printer.c")

void print_condition_list(Condition_List *conditions);
void print_condition(Condition *condition);

void print_break_statement(Break_Statement *statement);
void print_call_statement(Call_Statement *statement);
void print_continue_statement(Continue_Statement *statement);
void print_defer_statement(Defer_Statement *statement);
void print_if_statement(If_Statement *statement);
void print_return_statement(Return_Statement *statement);
void print_set_statement(Set_Statement *statement);
void print_switch_statement(Switch_Statement *statement);
void print_while_statement(While_Statement *statement);
void print_statement(Statement *statement);
void print_statement_list(Statement_List *statements);


#endif
