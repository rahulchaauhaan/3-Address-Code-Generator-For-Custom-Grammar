%{
#include "IR.tab.h"
#include <string.h>
#include <stdlib.h> /* for atoi and strdup */
%}

numChar    [0-9]
alphaChar  [a-zA-Z]
identSym   {alphaChar}({alphaChar}|{numChar})*
constVal   {numChar}+
relSymbol  (<|>|<=|>=|==|!=)

%%

"BcsMain"        { return MAINFN; }
"int"            { return INT_TYPE; }
"bool"           { return BOOL_TYPE; }

"{"                { return LBRACE_SYM; }
"}"                { return RBRACE_SYM; }
"("                { return LPAREN_SYM; }
")"                { return RPAREN_SYM; }
";"                { return SEMI_SYM; }
"="                { return ASSIGN_OP; }
"+"                { return ADD_OP; }
"*"                { return MUL_OP; }

{relSymbol}        { return REL_OP; }
{identSym}         { yylval.sval = strdup(yytext); return IDENT; }
{constVal}         { yylval.ival = atoi(yytext); return NUMBER; }

[ \t\n]            ;
.                  { fprintf(stderr, "Unrecognized input: %s\n", yytext); }

%%
int yywrap(void) { return 1; }
