#ifndef SYNTAX_H
#define SYNTAX_H


#ifndef offsetof
#define offsetof(struct_type, field) \
    ((size_t)&(((struct_type *)NULL)->field))
#endif


#define as_statement(thing) \
    ((Statement *)((char *)(thing) - offsetof(Statement, as)))


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


Expression_List *
create_expression_list(void);

void
add_expression_to_list(Expression *expression,
                       Expression_List *list);

Expression *
create_expression(void);


Comparison_List *
create_comparison_list(void);

void
add_comparison_to_list(Comparison *comparison,
                       Comparison_List *list);

Comparison *
create_comparison(Comparison_Type type,
                  Expression_List *left_expressions,
                  Expression_List *right_expressions);


Condition_List *
create_condition_list(void);

void
add_condition_to_list(Condition *condition,
                      Condition_List *list);

Condition *
create_condition(Comparison_List *comparisons);


Statement_List *
create_statement_list(void);

void
add_statement_to_list(Statement *statement,
                      Statement_List *list);

Break_Statement *
create_break_statement(const char *identifier);

Call_Statement *
create_call_statement(void);

Continue_Statement *
create_continue_statement(const char *identifier);

Defer_Statement *
create_defer_statement(void);

If_Statement *
create_if_statement(Condition_List *conditions,
                    Statement_List *then_statements);

Return_Statement *
create_return_statement(Expression_List *expressions);

Set_Statement *
create_set_statement(void);

Switch_Statement *
create_switch_statement(void);

While_Statement *
create_while_statement(Condition_List *conditions,
                       Statement_List *do_statements);


#endif
