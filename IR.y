%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

int yylex(void);
void yyerror(const char *msg);
void parseError(const char *msg);

FILE *genFile;
int tempVarCount = 0;

char* makeTempVar() {
    char *buf = (char*)malloc(32);
    sprintf(buf, "v%d", tempVarCount++);
    return buf;
}
%}

%union {
    int ival;
    char *sval;
}

%token MAINFN INT_TYPE BOOL_TYPE
%token LBRACE_SYM RBRACE_SYM LPAREN_SYM RPAREN_SYM SEMI_SYM ASSIGN_OP ADD_OP MUL_OP REL_OP
%token <sval> IDENT
%token <ival> NUMBER
%left ADD_OP
%left MUL_OP

%type <sval> expr term factor stmtBlock

%start program

%%

program     : MAINFN LBRACE_SYM declList stmtGroup RBRACE_SYM
                { printf("Parsing Successful\n"); }
            ;

declList    : declList declStmt
            | declStmt
            ;

declStmt    : dataType IDENT SEMI_SYM
            ;

dataType    : INT_TYPE
            | BOOL_TYPE
            ;

stmtGroup   : stmtGroup SEMI_SYM stmtBlock 
            | stmtBlock 
            ;

stmtBlock   : IDENT ASSIGN_OP expr
                {
                    fprintf(genFile, "%s = %s\n", $1, $3);
                }
            ;

expr        : expr ADD_OP term
                {
                    char *t = makeTempVar();
                    fprintf(genFile, "%s = %s + %s\n", t, $1, $3);
                    $$ = t;
                }
            | term
                { $$ = $1; }
            ;

term        : term MUL_OP factor
                {
                    char *t = makeTempVar();
                    fprintf(genFile, "%s = %s * %s\n", t, $1, $3);
                    $$ = t;
                }
            | factor
                { $$ = $1; }
            ;

factor      : IDENT  { $$ = $1; }
            | NUMBER {
                    char *t = (char*)malloc(32);
                    sprintf(t, "%d", $1);
                    $$ = t;
                }
            ;

%%

int main() {
    genFile = fopen("result.txt", "w");
    if (!genFile) {
        printf("Error: unable to open output file.\n");
        return 1;
    }
    yyparse();
    return 0;
}

void parseError(const char *msg) {
    fprintf(stderr, "Error: %s\n", msg);
}

/* Bison expects a yyerror function name; forward parseError to it */
void yyerror(const char *msg) {
    parseError(msg);
}
