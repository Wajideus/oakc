%{
#include <ctype.h>
#include <stdbool.h>

#include "array.h"
#include "syntax.h"
#include "parser.h"

#define update_position() { \
    column_number += last_token_length; \
    last_token_length = yyleng; \
}

int last_token_length = 0;

int line_number = 1;
int column_number = 1;

const char **type_names = NULL;

const char *interned_string(const char *string);
%}

IDENTIFIER  [A-Z_a-z][0-9A-Z_a-z]*
NUMBER [0-9]+(\.[0-9]+)?
STRING \"(\\.|[^\\"])*\"

%%

\/\/.* update_position();

[ \t]  update_position();

\n\r?|\r\n? {
    line_number++;
    column_number = 1;
    last_token_length = 0;
}

\#[ \t]*define  { update_position(); return DDEFINE; }
\#[ \t]*else    { update_position(); return DELSE; }
\#[ \t]*end     { update_position(); return DEND; }
\#[ \t]*if      { update_position(); return DIF; }

include   { update_position(); return INCLUDE; }

Bool      { update_position(); return BOOL; }
break     { update_position(); return BREAK; }
case      { update_position(); return CASE; }
Char      { update_position(); return CHAR; }
Const     { update_position(); return CONST; }
continue  { update_position(); return CONTINUE; }
default   { update_position(); return DEFAULT; }
defer     { update_position(); return DEFER; }
do        { update_position(); return DO; }
Dict      { update_position(); return DICT; }
else      { update_position(); return ELSE; }
enum      { update_position(); return ENUM; }
extern    { update_position(); return EXTERN; }
FALSE     { update_position(); return KFALSE; }
finish    { update_position(); return FINISH; }
Float     { update_position(); return FLOAT; }
func      { update_position(); return FUNC; }
if        { update_position(); return IF; }
Int       { update_position(); return INT; }
lengthOf  { update_position(); return LENGTHOF; }
mixin     { update_position(); return MIXIN; }
NULL      { update_position(); return KNULL; }
Proc      { update_position(); return PROC; }
return    { update_position(); return RETURN; }
Size      { update_position(); return SIZE; }
sizeOf    { update_position(); return SIZEOF; }
Str       { update_position(); return STR; }
struct    { update_position(); return STRUCT; }
switch    { update_position(); return SWITCH; }
TRUE      { update_position(); return KTRUE; }
Type      { update_position(); return TYPE; }
typedef   { update_position(); return TYPEDEF; }
UInt      { update_position(); return UINT; }
var       { update_position(); return VAR; }
Void      { update_position(); return VOID; }
while     { update_position(); return WHILE; }
{IDENTIFIER}  {
    // todo: check if type or identifier
    update_position();
    const char *identifier = interned_string(yytext);
    yylval.identifier = identifier;
    return IDENTIFIER;
}
{NUMBER}      { update_position(); return NUMBER; }
{STRING}      { update_position(); return STRING; }
\<\<    { update_position(); return LSH; }
\>\>    { update_position(); return RSH; }
\<\=    { update_position(); return LTEQ; }
\>\=    { update_position(); return GTEQ; }
\=\=    { update_position(); return EQ; }
\!\=    { update_position(); return NEQ; }
\&\&    { update_position(); return AND; }
\|\|    { update_position(); return OR; }
\+\=    { update_position(); return ADDEQ; }
\-\=    { update_position(); return SUBEQ; }
\*\=    { update_position(); return MULEQ; }
\/\=    { update_position(); return DIVEQ; }
\%\=    { update_position(); return MODEQ; }
\<\<\=  { update_position(); return LSHEQ; }
\>\>\=  { update_position(); return RSHEQ; }
\&\=    { update_position(); return ANDEQ; }
\|\=    { update_position(); return OREQ; }
\^\=    { update_position(); return XOREQ; }
\-\-    { update_position(); return DEC; }
\+\+    { update_position(); return INC; }
\.\.\.  { update_position(); return ETC; }
.       { update_position(); return *yytext; }

%%

void yyerror(const char *error) {
    fprintf(stderr, "%i:%i: %s: ", line_number, column_number, error);
    fprintf(stderr, "unexpected token \"");
    for (int i = 0; i < last_token_length; i++) {
        if (isprint(yytext[i])) {
            fputc(yytext[i], stderr);
        }
        else {
            fprintf(stderr, "\\x%02x", yytext[i]);
        }
    }
    fprintf(stderr, "\"\n");
}

const char *interned_string(const char *string) {
    typedef struct {
        size_t length;
        const char *data;
    }  Interned_String;
    static Interned_String *interned_strings = NULL;
    size_t length = strlen(string);
    for (int i = 0; i < array_length(interned_strings); i++) {
        if (interned_strings[i].data == string
            || (interned_strings[i].length == length
                && !strncmp(string, interned_strings[i].data, length))) {
            return interned_strings[i].data;
        }
    }
    string = strndup(string, length);
    add_array_element(interned_strings, ((Interned_String){length, string}));
    return string;
}
