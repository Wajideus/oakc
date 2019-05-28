#include <stdio.h>
#include <stdlib.h>

#include "syntax.h"


Expression_List *
create_expression_list(void) {
    return calloc(1, sizeof(Expression_List));
}

Expression *
add_expression(Expression_List *expressions) {
    Expression_List_Item *item = calloc(1, sizeof(Expression_List_Item));
    if (item) {
        if (!expressions->first) {
            expressions->first = item;
        }
        if (expressions->last) {
            expressions->last->next = item;
        }
        expressions->last = item;
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
        if (!comparisons->first) {
            comparisons->first = item;
        }
        if (comparisons->last) {
            comparisons->last->next = item;
        }
        comparisons->last = item;
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
        if (!conditions->first) {
            conditions->first = item;
        }
        if (conditions->last) {
            conditions->last->next = item;
        }
        conditions->last = item;
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
        item->statement.as.break_statement.identifier = identifier;
        if (!statements->first) {
            statements->first = item;
        }
        if (statements->last) {
            statements->last->next = item;
        }
        statements->last = item;
    }
    return &item->statement.as.break_statement;
}

Call_Statement *
add_call_statement(Statement_List *statements) {
    Statement_List_Item *item = calloc(1, sizeof(Statement_List_Item));
    if (item) {
        if (!statements->first) {
            statements->first = item;
        }
        if (statements->last) {
            statements->last->next = item;
        }
        statements->last = item;
    }
    return &item->statement.as.call_statement;
}

Continue_Statement *
add_continue_statement(Statement_List *statements,
                            const char *identifier) {
    Statement_List_Item *item = calloc(1, sizeof(Statement_List_Item));
    if (item) {
        item->statement.as.continue_statement.identifier = identifier;
        if (!statements->first) {
            statements->first = item;
        }
        if (statements->last) {
            statements->last->next = item;
        }
        statements->last = item;
    }
    return &item->statement.as.continue_statement;
}

Defer_Statement *
add_defer_statement(Statement_List *statements) {
    Statement_List_Item *item = calloc(1, sizeof(Statement_List_Item));
    if (item) {
        if (!statements->first) {
            statements->first = item;
        }
        if (statements->last) {
            statements->last->next = item;
        }
        statements->last = item;
    }
    return &item->statement.as.defer_statement;
}

If_Statement *
add_if_statement(Statement_List *statements,
                      Condition_List *conditions,
                      Statement_List *then_statements) {
    Statement_List_Item *item = calloc(1, sizeof(Statement_List_Item));
    if (item) {
        item->statement.as.if_statement.conditions = conditions;
        item->statement.as.if_statement.then_statements = then_statements;
        if (!statements->first) {
            statements->first = item;
        }
        if (statements->last) {
            statements->last->next = item;
        }
        statements->last = item;
    }
    return &item->statement.as.if_statement;
}

Return_Statement *
add_return_statement(Statement_List *statements,
                          Expression_List *expressions) {
    Statement_List_Item *item = calloc(1, sizeof(Statement_List_Item));
    if (item) {
        item->statement.as.return_statement.expressions = expressions;
        if (!statements->first) {
            statements->first = item;
        }
        if (statements->last) {
            statements->last->next = item;
        }
        statements->last = item;
    }
    return &item->statement.as.return_statement;
}

Set_Statement *
add_set_statement(Statement_List *statements) {
    Statement_List_Item *item = calloc(1, sizeof(Statement_List_Item));
    if (item) {
        if (!statements->first) {
            statements->first = item;
        }
        if (statements->last) {
            statements->last->next = item;
        }
        statements->last = item;
    }
    return &item->statement.as.set_statement;
}

Switch_Statement *
add_switch_statement(Statement_List *statements) {
    Statement_List_Item *item = calloc(1, sizeof(Statement_List_Item));
    if (item) {
        if (!statements->first) {
            statements->first = item;
        }
        if (statements->last) {
            statements->last->next = item;
        }
        statements->last = item;
    }
    return &item->statement.as.switch_statement;
}

While_Statement *
add_while_statement(Statement_List *statements,
                         Condition_List *conditions,
                         Statement_List *do_statements) {
    Statement_List_Item *item = calloc(1, sizeof(Statement_List_Item));
    if (item) {
        item->statement.as.while_statement.conditions = conditions;
        item->statement.as.while_statement.do_statements = do_statements;
        if (!statements->first) {
            statements->first = item;
        }
        if (statements->last) {
            statements->last->next = item;
        }
        statements->last = item;
    }
    return &item->statement.as.while_statement;
}

