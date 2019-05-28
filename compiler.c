#include <stdio.h>

#include "syntax.h"


int indent_level = 0;


void compile_statement_list(Statement_List *statements);


static void indent(void) {
    for (int i = 0; i < indent_level; i++) {
        printf("    ");
    }
}

static void compile_condition(Condition *condition) {
    printf("_");
}

static void compile_condition_list(Condition_List *conditions) {
    if (!conditions) {
        return;
    }
    Condition_List_Item *item = conditions->first;
    for (;;) {
        if (!item) {
            break;
        }
        compile_condition(&item->condition);
        item = item->next;
        if (item) {
            printf(" || ");
        }
    }
}

static void compile_break_statement(Break_Statement *statement) {
    if (!statement) {
        return;
    }
    indent();
    printf("break");
    if (statement->identifier) {
        printf(" %s", statement->identifier);
    }
}

static void compile_call_statement(Call_Statement *statement) {
    if (!statement) {
        return;
    }
    indent();
    printf("call");
}

static void compile_continue_statement(Continue_Statement *statement) {
    if (!statement) {
        return;
    }
    indent();
    printf("continue");
    if (statement->identifier) {
        printf(" %s", statement->identifier);
    }
}

static void compile_defer_statement(Defer_Statement *statement) {
    if (!statement) {
        return;
    }
    indent();
    printf("defer ");
    compile_call_statement(statement->call_statement);
}

static void compile_if_statement(If_Statement *statement) {
    if (!statement) {
        return;
    }
    indent();
    printf("if ");
    compile_condition_list(statement->conditions);
    printf(" then\n");
    indent_level++;
    compile_statement_list(statement->then_statements);
    indent_level--;
    indent();
    printf("end");
}

static void compile_return_statement(Return_Statement *statement) {
    if (!statement) {
        return;
    }
    indent();
    printf("return");
    if (statement->expressions) {
        // compile_expression_list();
    }
}

static void compile_set_statement(Set_Statement *statement) {
    if (!statement) {
        return;
    }
    indent();
    printf("set");
}

static void compile_switch_statement(Switch_Statement *statement) {
    if (!statement) {
        return;
    }
    indent();
    printf("switch");
}

static void compile_while_statement(While_Statement *statement) {
    indent();
    printf("while ");
    compile_condition_list(statement->conditions);
    printf(" do\n");
    indent_level++;
    compile_statement_list(statement->do_statements);
    indent_level--;
    indent();
    printf("end");
}

static void compile_statement(Statement *statement) {
    if (!statement) {
        return;
    }
    switch (statement->type) {
        case BREAK_STATEMENT:
            compile_break_statement(&statement->as.break_statement);
            break;
        case CALL_STATEMENT:
            compile_call_statement(&statement->as.call_statement);
            break;
        case CONTINUE_STATEMENT:
            compile_continue_statement(&statement->as.continue_statement);
            break;
        case DEFER_STATEMENT:
            compile_defer_statement(&statement->as.defer_statement);
            break;
        case IF_STATEMENT:
            compile_if_statement(&statement->as.if_statement);
            break;
        case RETURN_STATEMENT:
            compile_return_statement(&statement->as.return_statement);
            break;
        case SET_STATEMENT:
            compile_set_statement(&statement->as.set_statement);
            break;
        case SWITCH_STATEMENT:
            compile_switch_statement(&statement->as.switch_statement);
            break;
        case WHILE_STATEMENT:
            compile_while_statement(&statement->as.while_statement);
            break;
    }
}

void compile_statement_list(Statement_List *statements) {
    if (!statements) {
        return;
    }
    Statement_List_Item *item = statements->first;
    for (;;) {
        if (!item) {
            break;
        }
        compile_statement(&item->statement);
        item = item->next;
        printf("\n");
    }
}
