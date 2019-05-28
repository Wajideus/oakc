#include <stdio.h>

#include "syntax.h"


Expression_List *
create_expression_list(void) {
    return NULL;
}

Expression *
add_expression(Expression_List *expressions) {
    return NULL;
}


Comparison_List *
create_comparison_list(void) {
    return NULL;
}

Comparison *
add_comparison(Comparison_List *comparisons) {
    return NULL;
}


Condition_List *
create_condition_list(void) {
    return NULL;
}

Condition *
add_condition(Condition_List *conditions) {
    return NULL;
}


Statement_List *
create_statement_list(void) {
    return NULL;
}

Break_Statement *
add_break_statement(Statement_List *statements,
                         const char *identifier) {
    return NULL;
}

Call_Statement *
add_call_statement(Statement_List *statements) {
    return NULL;
}

Continue_Statement *
add_continue_statement(Statement_List *statements,
                            const char *identifier) {
    return NULL;
}

Defer_Statement *
add_defer_statement(Statement_List *statements) {
    return NULL;
}

If_Statement *
add_if_statement(Statement_List *statements,
                      Condition_List *conditions,
                      Statement_List *then_statements) {
    return NULL;
}

Return_Statement *
add_return_statement(Statement_List *statements,
                          Expression_List *expressions) {
    return NULL;
}

Set_Statement *
add_set_statement(Statement_List *statements) {
    return NULL;
}

Switch_Statement *
add_switch_statement(Statement_List *statements) {
    return NULL;
}

While_Statement *
add_while_statement(Statement_List *statements,
                         Condition_List *conditions,
                         Statement_List *do_statements) {
    return NULL;
}

