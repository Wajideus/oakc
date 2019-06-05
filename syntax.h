#ifndef SYNTAX_H
#define SYNTAX_H


#ifndef offsetof
#define offsetof(struct_type, field) \
    ((size_t)&(((struct_type *)NULL)->field))
#endif


#define as_statement(thing) \
    ((Statement *)((char *)(thing) - offsetof(Statement, as)))


typedef struct Condition Condition;

typedef struct {
} Value;

typedef struct {
    Value **values;
} Term;

typedef struct Expression {
    Term **terms;
} Expression;

typedef enum {
    NO_COMPARISON,
    EQUAL_COMPARISON,
    NOT_EQUAL_COMPARISON,
    LESS_THAN_COMPARISON,
    GREATER_THAN_COMPARISON,
    LESS_THAN_EQUAL_COMPARISON,
    GREATER_THAN_EQUAL_COMPARISON
} Comparison_Type;

typedef struct {
    Comparison_Type type;
    Expression **left_expressions;
    Expression **right_expressions;
} Comparison;

struct Condition {
    Comparison **comparisons;
};

typedef struct Statement Statement;

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
} Define_Statement;

typedef struct {
    Condition **conditions;
    Statement **then_statements;
} If_Statement;

typedef struct {
    Expression **expressions;
} Return_Statement;

typedef struct {
} Set_Statement;

typedef struct {
} Switch_Statement;

typedef struct {
    Condition **conditions;
    Statement **do_statements;
} While_Statement;

typedef enum {
    BREAK_STATEMENT,
    CALL_STATEMENT,
    CONTINUE_STATEMENT,
    DEFER_STATEMENT,
    DEFINE_STATEMENT,
    IF_STATEMENT,
    RETURN_STATEMENT,
    SET_STATEMENT,
    SWITCH_STATEMENT,
    WHILE_STATEMENT
} Statement_Type;

struct Statement {
    Statement_Type type;
    union {
        Break_Statement break_statement;
        Call_Statement call_statement;
        Continue_Statement continue_statement;
        Defer_Statement defer_statement;
        Define_Statement define_statement;
        If_Statement if_statement;
        Return_Statement return_statement;
        Set_Statement set_statement;
        Switch_Statement switch_statement;
        While_Statement while_statement;
    } as;
};


Expression *
create_expression(void);

Comparison *
create_comparison(Comparison_Type type,
                  Expression **left_expressions,
                  Expression **right_expressions);

Condition *
create_condition(Comparison **comparisons);

Break_Statement *
create_break_statement(const char *identifier);

Call_Statement *
create_call_statement(void);

Continue_Statement *
create_continue_statement(const char *identifier);

Defer_Statement *
create_defer_statement(void);

Define_Statement *
create_define_statement(void);

If_Statement *
create_if_statement(Condition **conditions,
                    Statement **then_statements);

Return_Statement *
create_return_statement(Expression **expressions);

Set_Statement *
create_set_statement(void);

Switch_Statement *
create_switch_statement(void);

While_Statement *
create_while_statement(Condition **conditions,
                       Statement **do_statements);


#endif
