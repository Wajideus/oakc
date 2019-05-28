%{
#include "parser.h"
%}

IDENTIFIER  [A-Z_a-z][0-9A-Z_a-z]*
NUMBER [0-9]+(\.[0-9]+)?
STRING \"(\\.|[^\\"])*\"

%%

\/\/.*  ;
[ \t]   ;
\n      return NEWLINE;
\#[ \t]*define   return DDEFINE;
\#[ \t]*else     return DELSE;
\#[ \t]*end      return DEND;
\#[ \t]*if       return DIF;
\#[ \t]*include  return DINCLUDE;
FALSE     return KFALSE;
NULL      return KNULL;
TRUE      return KTRUE;
bool      return BOOL;
break     return BREAK;
case      return CASE;
char      return CHAR;
continue  return CONTINUE;
default   return DEFAULT;
defer     return DEFER;
do        return DO;
else      return ELSE;
end       return END;
enum      return ENUM;
extern    return EXTERN;
float     return FLOAT;
func      return FUNC;
if        return IF;
int       return INT;
lengthof  return LENGTHOF;
mixin     return MIXIN;
numberof  return NUMBEROF;
return    return RETURN;
sizeof    return SIZEOF;
str       return STR;
struct    return STRUCT;
switch    return SWITCH;
then      return THEN;
typedef   return TYPEDEF;
uint      return UINT;
void      return VOID;
while     return WHILE;
{IDENTIFIER}  return IDENTIFIER;    // todo: check if type or identifier
{NUMBER}      return NUMBER;
{STRING}      return STRING;
\<\<    return LSH;
\>\>    return RSH;
\<\=    return LTEQ;
\>\=    return GTEQ;
\=\=    return EQ;
\!\=    return NEQ;
\&\&    return AND;
\|\|    return OR;
\+\=    return ADDEQ;
\-\=    return SUBEQ;
\*\=    return MULEQ;
\/\=    return DIVEQ;
\%\=    return MODEQ;
\<\<\=  return LSHEQ;
\>\>\=  return RSHEQ;
\&\=    return ANDEQ;
\|\=    return OREQ;
\^\=    return XOREQ;
\-\-    return DEC;
\+\+    return INC;
\.\.\.  return ETC;
.       return *yytext;

%%
