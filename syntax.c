#include <stdio.h>
#include <stdlib.h>

#include "array.h"
#include "syntax.h"


Expression *
create_expression(void) {
    Expression *expression = malloc(sizeof(Expression));
    if (expression) {
        expression->terms = NULL;
        return expression;
    }
    else {
        return NULL;
    }
}

Comparison *
create_comparison(Comparison_Type type,
                  Expression **left_expressions,
                  Expression **right_expressions) {
    Comparison *comparison = malloc(sizeof(Comparison));
    if (comparison) {
        comparison->type = type;
        comparison->left_expressions = left_expressions;
        comparison->right_expressions = right_expressions;
        return comparison;
    }
    else {
        return NULL;
    }
}

Condition *
create_condition(Comparison **comparisons) {
    Condition *condition = malloc(sizeof(Condition));
    if (condition) {
        condition->comparisons = comparisons;
        return condition;
    }
    else {
        return NULL;
    }
}

Break_Statement *
create_break_statement(const char *identifier) {
    Statement *statement = malloc(sizeof(Statement));
    if (statement) {
        statement->type = BREAK_STATEMENT;
        statement->as.break_statement.identifier = identifier;
        return &statement->as.break_statement;
    }
    else {
        return NULL;
    }
}

Call_Statement *
create_call_statement(void) {
    Statement *statement = malloc(sizeof(Statement));
    if (statement) {
        statement->type = CALL_STATEMENT;
        return &statement->as.call_statement;
    }
    else {
        return NULL;
    }
}

Continue_Statement *
create_continue_statement(const char *identifier) {
    Statement *statement = malloc(sizeof(Statement));
    if (statement) {
        statement->type = CONTINUE_STATEMENT;
        statement->as.continue_statement.identifier = identifier;
        return &statement->as.continue_statement;
    }
    else {
        return NULL;
    }
}

Defer_Statement *
create_defer_statement(void) {
    Statement *statement = malloc(sizeof(Statement));
    if (statement) {
        statement->type = DEFER_STATEMENT;
        return &statement->as.defer_statement;
    }
    else {
        return NULL;
    }
}

Define_Statement *
create_define_statement(void) {
    Statement *statement = malloc(sizeof(Statement));
    if (statement) {
        statement->type = DEFINE_STATEMENT;
        return &statement->as.define_statement;
    }
    else {
        return NULL;
    }
}

Finish_Statement *
create_finish_statement(const char *identifier) {
    Statement *statement = malloc(sizeof(Statement));
    if (statement) {
        statement->type = FINISH_STATEMENT;
        statement->as.finish_statement.identifier = identifier;
        return &statement->as.finish_statement;
    }
    else {
        return NULL;
    }
}

If_Statement *
create_if_statement(Condition **conditions,
                    Statement **then_statements) {
    Statement *statement = malloc(sizeof(Statement));
    if (statement) {
        statement->type = IF_STATEMENT;
        statement->as.if_statement.conditions = conditions;
        statement->as.if_statement.then_statements = then_statements;
        return &statement->as.if_statement;
    }
    else {
        return NULL;
    }
}

Return_Statement *
create_return_statement(Expression **expressions) {
    Statement *statement = malloc(sizeof(Statement));
    if (statement) {
        statement->type = RETURN_STATEMENT;
        statement->as.return_statement.expressions = expressions;
        return &statement->as.return_statement;
    }
    else {
        return NULL;
    }
}

Set_Statement *
create_set_statement(void) {
    Statement *statement = malloc(sizeof(Statement));
    if (statement) {
        statement->type = SET_STATEMENT;
        return &statement->as.set_statement;
    }
    else {
        return NULL;
    }
}

Switch_Statement *
create_switch_statement(void) {
    Statement *statement = malloc(sizeof(Statement));
    if (statement) {
        statement->type = SWITCH_STATEMENT;
        return &statement->as.switch_statement;
    }
    else {
        return NULL;
    }
}

While_Statement *
create_while_statement(Condition **conditions,
                       Statement **do_statements) {
    Statement *statement = malloc(sizeof(Statement));
    if (statement) {
        statement->type = WHILE_STATEMENT;
        statement->as.while_statement.conditions = conditions;
        statement->as.while_statement.do_statements = do_statements;
        return &statement->as.while_statement;
    }
    else {
        return NULL;
    }
}
