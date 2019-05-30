#include <stdio.h>
#include <stdlib.h>

#include "syntax.h"


#define as_expression_list_item(object) \
    ((Expression_List_Item *)( \
        (char *)(object) - offsetof(Expression_List_Item, expression) \
    ))

#define as_comparison_list_item(object) \
    ((Comparison_List_Item *)( \
        (char *)(object) - offsetof(Comparison_List_Item, comparison) \
    ))

#define as_condition_list_item(object) \
    ((Condition_List_Item *)( \
        (char *)(object) - offsetof(Condition_List_Item, condition) \
    ))

#define as_statement_list_item(object) \
    ((Statement_List_Item *)( \
        (char *)(object) - offsetof(Statement_List_Item, statement) \
    ))


#define add_item_to_list(item, list) \
    if (item && list) { \
        if (!list->first) { \
            list->first = item; \
        } \
        if (list->last) { \
            list->last->next = item; \
        } \
        list->last = item; \
    }


Expression_List *
create_expression_list(void) {
    return calloc(1, sizeof(Expression_List));
}

void
add_expression_to_list(Expression *expression,
                       Expression_List *list) {
    add_item_to_list(as_expression_list_item(expression), list);
}

Expression *
create_expression(void) {
    Expression_List_Item *item = malloc(sizeof(Expression_List_Item));
    if (item) {
        item->next = NULL;
        item->expression.type = ADDITION_EXPRESSION;
        return &item->expression;
    }
    else {
        return NULL;
    }
}


Comparison_List *
create_comparison_list(void) {
    return calloc(1, sizeof(Comparison_List));
}

void
add_comparison_to_list(Comparison *comparison,
                       Comparison_List *list) {
    add_item_to_list(as_comparison_list_item(comparison), list);
}

Comparison *
create_comparison(Comparison_Type type,
                  Expression_List *left_expressions,
                  Expression_List *right_expressions) {
    Comparison_List_Item *item = malloc(sizeof(Comparison_List_Item));
    if (item) {
        item->next = NULL;
        item->comparison.type = type;
        item->comparison.left_expressions = left_expressions;
        item->comparison.right_expressions = right_expressions;
        return &item->comparison;
    }
    else {
        return NULL;
    }
}


Condition_List *
create_condition_list(void) {
    return calloc(1, sizeof(Condition_List));
}

void
add_condition_to_list(Condition *condition,
                      Condition_List *list) {
    add_item_to_list(as_condition_list_item(condition), list);
}

Condition *
create_condition(Comparison_List *comparisons) {
    Condition_List_Item *item = malloc(sizeof(Condition_List_Item));
    if (item) {
        item->next = NULL;
        item->condition.comparisons = comparisons;
        return &item->condition;
    }
    else {
        return NULL;
    }
}


Statement_List *
create_statement_list(void) {
    return calloc(1, sizeof(Statement_List));
}

void
add_statement_to_list(Statement *statement,
                      Statement_List *list) {
    add_item_to_list(as_statement_list_item(statement), list);
}

Break_Statement *
create_break_statement(const char *identifier) {
    Statement_List_Item *item = malloc(sizeof(Statement_List_Item));
    if (item) {
        item->next = NULL;
        item->statement.type = BREAK_STATEMENT;
        item->statement.as.break_statement.identifier = identifier;
        return &item->statement.as.break_statement;
    }
    else {
        return NULL;
    }
}

Call_Statement *
create_call_statement(void) {
    Statement_List_Item *item = malloc(sizeof(Statement_List_Item));
    if (item) {
        item->next = NULL;
        item->statement.type = CALL_STATEMENT;
        return &item->statement.as.call_statement;
    }
    else {
        return NULL;
    }
}

Continue_Statement *
create_continue_statement(const char *identifier) {
    Statement_List_Item *item = malloc(sizeof(Statement_List_Item));
    if (item) {
        item->next = NULL;
        item->statement.type = CONTINUE_STATEMENT;
        item->statement.as.continue_statement.identifier = identifier;
        return &item->statement.as.continue_statement;
    }
    else {
        return NULL;
    }
}

Defer_Statement *
create_defer_statement(void) {
    Statement_List_Item *item = malloc(sizeof(Statement_List_Item));
    if (item) {
        item->next = NULL;
        item->statement.type = DEFER_STATEMENT;
        return &item->statement.as.defer_statement;
    }
    else {
        return NULL;
    }
}

If_Statement *
create_if_statement(Condition_List *conditions,
                    Statement_List *then_statements) {
    Statement_List_Item *item = malloc(sizeof(Statement_List_Item));
    if (item) {
        item->next = NULL;
        item->statement.type = IF_STATEMENT;
        item->statement.as.if_statement.conditions = conditions;
        item->statement.as.if_statement.then_statements = then_statements;
        return &item->statement.as.if_statement;
    }
    else {
        return NULL;
    }
}

Return_Statement *
create_return_statement(Expression_List *expressions) {
    Statement_List_Item *item = malloc(sizeof(Statement_List_Item));
    if (item) {
        item->next = NULL;
        item->statement.type = RETURN_STATEMENT;
        item->statement.as.return_statement.expressions = expressions;
        return &item->statement.as.return_statement;
    }
    else {
        return NULL;
    }
}

Set_Statement *
create_set_statement(void) {
    Statement_List_Item *item = malloc(sizeof(Statement_List_Item));
    if (item) {
        item->next = NULL;
        item->statement.type = SET_STATEMENT;
        return &item->statement.as.set_statement;
    }
    else {
        return NULL;
    }
}

Switch_Statement *
create_switch_statement(void) {
    Statement_List_Item *item = malloc(sizeof(Statement_List_Item));
    if (item) {
        item->next = NULL;
        item->statement.type = SWITCH_STATEMENT;
        return &item->statement.as.switch_statement;
    }
    else {
        return NULL;
    }
}

While_Statement *
create_while_statement(Condition_List *conditions,
                       Statement_List *do_statements) {
    Statement_List_Item *item = malloc(sizeof(Statement_List_Item));
    if (item) {
        item->next = NULL;
        item->statement.type = WHILE_STATEMENT;
        item->statement.as.while_statement.conditions = conditions;
        item->statement.as.while_statement.do_statements = do_statements;
        return &item->statement.as.while_statement;
    }
    else {
        return NULL;
    }
}
