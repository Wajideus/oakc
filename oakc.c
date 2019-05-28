#include <errno.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "parser.h"

extern FILE *yyin;

int main(int argc, char *argv[]) {
    FILE *f = fopen("./tests/test.oak", "r");
    if (f) {
        yyin = f;
        yyparse();
    }
    else {
        fprintf(stderr, "error: test.oak: %s\n", strerror(errno));
    }
}
