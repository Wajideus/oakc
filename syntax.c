#include <stdio.h>

#include "syntax.h"


void print_condition_list(Condition_List *conditions) {
    Condition_List_Item *item = conditions->first;
    do {
        print_condition(&item->condition);
        item = item->next;
        if (item) {
            printf(" || ");
        }
    }
    while (item);
}

void print_condition(Condition *condition) {
    printf("_");
}

void print_break_statement(Break_Statement *statement) {
    printf("break");
    if (statement->identifier) {
        printf(" %s", statement->identifier);
    }
}

void print_call_statement(Call_Statement *statement) {
}

void print_continue_statement(Continue_Statement *statement) {
    printf("continue");
    if (statement->identifier) {
        printf(" %s", statement->identifier);
    }
}

void print_defer_statement(Defer_Statement *statement) {
    printf("defer ");
    print_call_statement(statement->call_statement);
}

void print_if_statement(If_Statement *statement) {
    printf("if ");
    print_condition_list(statement->conditions);
    printf(" then\n");
    print_statement_list(statement->then_statements);
    printf("\nend");
}

void print_return_statement(Return_Statement *statement) {
    printf("return");
    if (statement->expressions) {
        // print_expression_list();
    }
}

void print_set_statement(Set_Statement *statement) {
}

void print_switch_statement(Switch_Statement *statement) {
}

void print_while_statement(While_Statement *statement) {
    printf("while ");
    print_condition_list(statement->conditions);
    printf(" do\n");
    print_statement_list(statement->do_statements);
    printf("\nend");
}

void print_statement_list(Statement_List *statements) {
    Statement_List_Item *item = statements->first;
    do {
        print_statement(&item->statement);
        item = item->next;
        if (item) {
            printf("\n");
        }
    }
    while (item);
}

void print_statement(Statement *statement) {
    switch (statement->type) {
        case BREAK_STATEMENT:
            print_break_statement((void *)statement);
            break;
        case CALL_STATEMENT:
            print_call_statement((void *)statement);
            break;
        case CONTINUE_STATEMENT:
            print_continue_statement((void *)statement);
            break;
        case DEFER_STATEMENT:
            print_defer_statement((void *)statement);
            break;
        case IF_STATEMENT:
            print_if_statement((void *)statement);
            break;
        case RETURN_STATEMENT:
            print_return_statement((void *)statement);
            break;
        case SET_STATEMENT:
            print_set_statement((void *)statement);
            break;
        case SWITCH_STATEMENT:
            print_switch_statement((void *)statement);
            break;
        case WHILE_STATEMENT:
            print_while_statement((void *)statement);
            break;
    }
}
