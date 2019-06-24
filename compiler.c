#include <stdio.h>

#include "array.h"
#include "syntax.h"


int indent_level = 0;


void compile_statements(Statement **statements);


static void indent(void) {
    for (int i = 0; i < indent_level; i++) {
        printf("    ");
    }
}

static void compile_expression(Expression *expression) {
    printf("[expr]");
}

static void compile_expressions(Expression **expressions) {
    if (expressions) {
        for (int i = 0; i < array_length(expressions); i++) {
            compile_expression(expressions[i]);
            if (i < array_length(expressions) - 1) {
                printf(", ");
            }
        }
    }
}

static void compile_comparison(Comparison *comparison) {
    if (comparison) {
        compile_expressions(comparison->left_expressions);
        switch (comparison->type) {
            case EQUAL_COMPARISON:
                printf(" == ");
                compile_expressions(comparison->right_expressions);
                break;
            case NOT_EQUAL_COMPARISON:
                printf(" != ");
                compile_expressions(comparison->right_expressions);
                break;
            case LESS_THAN_COMPARISON:
                printf(" < ");
                compile_expressions(comparison->right_expressions);
                break;
            case GREATER_THAN_COMPARISON:
                printf(" > ");
                compile_expressions(comparison->right_expressions);
                break;
            case LESS_THAN_EQUAL_COMPARISON:
                printf(" <= ");
                compile_expressions(comparison->right_expressions);
                break;
            case GREATER_THAN_EQUAL_COMPARISON:
                printf(" >= ");
                compile_expressions(comparison->right_expressions);
                break;
        }
    }
}

static void compile_comparisons(Comparison **comparisons) {
    if (comparisons) {
        for (int i = 0; i < array_length(comparisons); i++) {
            compile_comparison(comparisons[i]);
            if (i < array_length(comparisons) - 1) {
                printf(" && ");
            }
        }
    }
}

static void compile_condition(Condition *condition) {
    if (condition) {
        compile_comparisons(condition->comparisons);
    }
}

static void compile_conditions(Condition **conditions) {
    if (conditions) {
        for (int i = 0; i < array_length(conditions); i++) {
            compile_condition(conditions[i]);
            if (i < array_length(conditions) - 1) {
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

static void compile_declare_statement(Declare_Statement *statement) {
    if (statement) {
        indent();
        printf("[declare]");
    }
}

static void compile_defer_statement(Defer_Statement *statement) {
    if (statement) {
        indent();
        printf("defer ");
        compile_call_statement(statement->call_statement);
    }
}

static void compile_define_statement(Define_Statement *statement) {
    if (statement) {
        indent();
        printf("[define]");
    }
}

static void compile_if_statement(If_Statement *statement) {
    if (statement) {
        indent();
        printf("if ");
        compile_conditions(statement->conditions);
        printf(" {\n");
        indent_level++;
        compile_statements(statement->then_statements);
        indent_level--;
        indent();
        printf("}");
    }
}

static void compile_return_statement(Return_Statement *statement) {
    if (statement) {
        indent();
        printf("return");
        if (statement->expressions) {
            putchar(' ');
            compile_expressions(statement->expressions);
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
        compile_conditions(statement->conditions);
        printf(" {\n");
        indent_level++;
        compile_statements(statement->do_statements);
        indent_level--;
        indent();
        printf("}");
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
            case DECLARE_STATEMENT:
                compile_declare_statement(&statement->as.declare_statement);
                break;
            case DEFER_STATEMENT:
                compile_defer_statement(&statement->as.defer_statement);
                break;
            case DEFINE_STATEMENT:
                compile_define_statement(&statement->as.define_statement);
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

void compile_statements(Statement **statements) {
    if (statements) {
        for (int i = 0; i < array_length(statements); i++) {
            compile_statement(statements[i]);
            if (i < array_length(statements - 1)) {
                printf("\n");
            }
        }
    }
}
