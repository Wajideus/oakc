#include <stdio.h>
#include <stdlib.h>

#include "syntax.h"


// Convert a statement into a statement list item. This only works because
// all statements are secretly statement list items anyway, do to how
// they're allocated.
#define as_statement_list_item(statement) \
    ((Statement_List_Item *)( \
        (char *)(statement) - offsetof(Statement_List_Item, statement) \
    ))

#define add_item_to_list(item, list) \
    if (list) { \
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

Expression *
add_expression(Expression_List *expressions) {
    Expression_List_Item *item = calloc(1, sizeof(Expression_List_Item));
    if (item) {
        add_item_to_list(item, expressions);
    }
    return &item->expression;
}


Comparison_List *
create_comparison_list(void) {
    return calloc(1, sizeof(Comparison_List));
}

Comparison *
add_comparison(Comparison_List *comparisons) {
    Comparison_List_Item *item = calloc(1, sizeof(Comparison_List_Item));
    if (item) {
        add_item_to_list(item, comparisons);
    }
    return &item->comparison;
}


Condition_List *
create_condition_list(void) {
    return calloc(1, sizeof(Condition_List));
}

Condition *
add_condition(Condition_List *conditions) {
    Condition_List_Item *item = calloc(1, sizeof(Condition_List_Item));
    if (item) {
        add_item_to_list(item, conditions);
    }
    return &item->condition;
}


Statement_List *
create_statement_list(void) {
    return calloc(1, sizeof(Statement_List));
}

Break_Statement *
add_break_statement(Statement_List *statements,
                    const char *identifier) {
    Statement_List_Item *item = calloc(1, sizeof(Statement_List_Item));
    if (item) {
        item->statement.type = BREAK_STATEMENT;
        item->statement.as.break_statement.identifier = identifier;
        add_item_to_list(item, statements);
    }
    return &item->statement.as.break_statement;
}

Call_Statement *
add_call_statement(Statement_List *statements) {
    Statement_List_Item *item = calloc(1, sizeof(Statement_List_Item));
    if (item) {
        item->statement.type = CALL_STATEMENT;
        add_item_to_list(item, statements);
    }
    return &item->statement.as.call_statement;
}

Continue_Statement *
add_continue_statement(Statement_List *statements,
                       const char *identifier) {
    Statement_List_Item *item = calloc(1, sizeof(Statement_List_Item));
    if (item) {
        item->statement.type = CONTINUE_STATEMENT;
        item->statement.as.continue_statement.identifier = identifier;
        add_item_to_list(item, statements);
    }
    return &item->statement.as.continue_statement;
}

Defer_Statement *
add_defer_statement(Statement_List *statements) {
    Statement_List_Item *item = calloc(1, sizeof(Statement_List_Item));
    if (item) {
        item->statement.type = DEFER_STATEMENT;
        add_item_to_list(item, statements);
    }
    return &item->statement.as.defer_statement;
}

If_Statement *
add_if_statement(Statement_List *statements,
                 Condition_List *conditions,
                 Statement_List *then_statements) {
    Statement_List_Item *item = calloc(1, sizeof(Statement_List_Item));
    if (item) {
        item->statement.type = IF_STATEMENT;
        item->statement.as.if_statement.conditions = conditions;
        item->statement.as.if_statement.then_statements = then_statements;
        add_item_to_list(item, statements);
    }
    return &item->statement.as.if_statement;
}

Return_Statement *
add_return_statement(Statement_List *statements,
                     Expression_List *expressions) {
    Statement_List_Item *item = calloc(1, sizeof(Statement_List_Item));
    if (item) {
        item->statement.type = RETURN_STATEMENT;
        item->statement.as.return_statement.expressions = expressions;
        add_item_to_list(item, statements);
    }
    return &item->statement.as.return_statement;
}

Set_Statement *
add_set_statement(Statement_List *statements) {
    Statement_List_Item *item = calloc(1, sizeof(Statement_List_Item));
    if (item) {
        item->statement.type = SET_STATEMENT;
        add_item_to_list(item, statements);
    }
    return &item->statement.as.set_statement;
}

Switch_Statement *
add_switch_statement(Statement_List *statements) {
    Statement_List_Item *item = calloc(1, sizeof(Statement_List_Item));
    if (item) {
        item->statement.type = SWITCH_STATEMENT;
        add_item_to_list(item, statements);
    }
    return &item->statement.as.switch_statement;
}

While_Statement *
add_while_statement(Statement_List *statements,
                    Condition_List *conditions,
                    Statement_List *do_statements) {
    Statement_List_Item *item = calloc(1, sizeof(Statement_List_Item));
    if (item) {
        item->statement.type = WHILE_STATEMENT;
        item->statement.as.while_statement.conditions = conditions;
        item->statement.as.while_statement.do_statements = do_statements;
        add_item_to_list(item, statements);
    }
    return &item->statement.as.while_statement;
}


Statement *
add_statement(Statement_List *statements,
              Statement *statement) {
    if (!statements || !statement) {
        return NULL;
    }
    Statement_List_Item *item = as_statement_list_item(statement);
    add_item_to_list(item, statements);
    return statement;
}
