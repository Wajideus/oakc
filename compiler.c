#include <stdio.h>

#include "syntax.h"


int indent_level = 0;


void compile_statement_list(Statement_List *statements);


static void indent(void) {
    for (int i = 0; i < indent_level; i++) {
        printf("    ");
    }
}

static void compile_expression(Expression *expression) {
    printf("[expr]");
}

static void compile_expression_list(Expression_List *list) {
    if (list) {
        Expression_List_Item *item = list->first;
        while (item) {
            compile_expression(&item->expression);
            item = item->next;
            if (item) {
                printf(", ");
            }
        }
    }
}

static void compile_comparison(Comparison *comparison) {
    if (comparison) {
        compile_expression_list(comparison->left_expressions);
        switch (comparison->type) {
            case EQUAL_COMPARISON:
                printf(" == ");
                compile_expression_list(comparison->right_expressions);
                break;
            case NOT_EQUAL_COMPARISON:
                printf(" != ");
                compile_expression_list(comparison->right_expressions);
                break;
            case LESS_THAN_COMPARISON:
                printf(" < ");
                compile_expression_list(comparison->right_expressions);
                break;
            case GREATER_THAN_COMPARISON:
                printf(" > ");
                compile_expression_list(comparison->right_expressions);
                break;
            case LESS_THAN_EQUAL_COMPARISON:
                printf(" <= ");
                compile_expression_list(comparison->right_expressions);
                break;
            case GREATER_THAN_EQUAL_COMPARISON:
                printf(" >= ");
                compile_expression_list(comparison->right_expressions);
                break;
        }
    }
}

static void compile_comparison_list(Comparison_List *list) {
    if (list) {
        Comparison_List_Item *item = list->first;
        while (item) {
            compile_comparison(&item->comparison);
            item = item->next;
            if (item) {
                printf(" && ");
            }
        }
    }
}

static void compile_condition(Condition *condition) {
    if (condition) {
        compile_comparison_list(condition->comparisons);
    }
}

static void compile_condition_list(Condition_List *list) {
    if (list) {
        Condition_List_Item *item = list->first;
        while (item) {
            compile_condition(&item->condition);
            item = item->next;
            if (item) {
                printf(" || ");
            }
        }
    }
}

static void compile_break_statement(Break_Statement *statement) {
    if (statement) {
        indent();
        printf("break");
        if (statement->identifier) {
            printf(" %s", statement->identifier);
        }
    }
}

static void compile_call_statement(Call_Statement *statement) {
    if (statement) {
        indent();
        printf("[call]");
    }
}

static void compile_continue_statement(Continue_Statement *statement) {
    if (statement) {
        indent();
        printf("continue");
        if (statement->identifier) {
            printf(" %s", statement->identifier);
        }
    }
}

static void compile_defer_statement(Defer_Statement *statement) {
    if (statement) {
        indent();
        printf("defer ");
        compile_call_statement(statement->call_statement);
    }
}

static void compile_if_statement(If_Statement *statement) {
    if (statement) {
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
}

static void compile_return_statement(Return_Statement *statement) {
    if (statement) {
        indent();
        printf("return");
        if (statement->expressions) {
            // compile_expression_list();
        }
    }
}

static void compile_set_statement(Set_Statement *statement) {
    if (statement) {
        indent();
        printf("[set]");
    }
}

static void compile_switch_statement(Switch_Statement *statement) {
    if (statement) {
        indent();
        printf("[switch]");
    }
}

static void compile_while_statement(While_Statement *statement) {
    if (statement) {
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
}

static void compile_statement(Statement *statement) {
    if (statement) {
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
}

void compile_statement_list(Statement_List *list) {
    if (list) {
        Statement_List_Item *item = list->first;
        for (;;) {
            if (!item) {
                break;
            }
            compile_statement(&item->statement);
            item = item->next;
            printf("\n");
        }
    }
}
