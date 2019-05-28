#include <stdio.h>

#include "syntax.h"


static void compile_condition_list(Condition_List *conditions) {
    Condition_List_Item *item = conditions->first;
    do {
        compile_condition(&item->condition);
        item = item->next;
        if (item) {
            printf(" || ");
        }
    }
    while (item);
}

static void compile_condition(Condition *condition) {
    printf("_");
}

static void compile_break_statement(Break_Statement *statement) {
    printf("break");
    if (statement->identifier) {
        printf(" %s", statement->identifier);
    }
}

void compile_call_statement(Call_Statement *statement) {
}

void compile_continue_statement(Continue_Statement *statement) {
    printf("continue");
    if (statement->identifier) {
        printf(" %s", statement->identifier);
    }
}

void compile_defer_statement(Defer_Statement *statement) {
    printf("defer ");
    compile_call_statement(statement->call_statement);
}

void compile_if_statement(If_Statement *statement) {
    printf("if ");
    compile_condition_list(statement->conditions);
    printf(" then\n");
    compile_statement_list(statement->then_statements);
    printf("\nend");
}

void compile_return_statement(Return_Statement *statement) {
    printf("return");
    if (statement->expressions) {
        // compile_expression_list();
    }
}

void compile_set_statement(Set_Statement *statement) {
}

void compile_switch_statement(Switch_Statement *statement) {
}

void compile_while_statement(While_Statement *statement) {
    printf("while ");
    compile_condition_list(statement->conditions);
    printf(" do\n");
    compile_statement_list(statement->do_statements);
    printf("\nend");
}

void compile_statement_list(Statement_List *statements) {
    Statement_List_Item *item = statements->first;
    do {
        compile_statement(&item->statement);
        item = item->next;
        if (item) {
            printf("\n");
        }
    }
    while (item);
}

void compile_statement(Statement *statement) {
    switch (statement->type) {
        case BREAK_STATEMENT:
            compile_break_statement((void *)statement);
            break;
        case CALL_STATEMENT:
            compile_call_statement((void *)statement);
            break;
        case CONTINUE_STATEMENT:
            compile_continue_statement((void *)statement);
            break;
        case DEFER_STATEMENT:
            compile_defer_statement((void *)statement);
            break;
        case IF_STATEMENT:
            compile_if_statement((void *)statement);
            break;
        case RETURN_STATEMENT:
            compile_return_statement((void *)statement);
            break;
        case SET_STATEMENT:
            compile_set_statement((void *)statement);
            break;
        case SWITCH_STATEMENT:
            compile_switch_statement((void *)statement);
            break;
        case WHILE_STATEMENT:
            compile_while_statement((void *)statement);
            break;
    }
}
