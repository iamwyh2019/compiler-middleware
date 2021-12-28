%{
#define YYSTYPE void*
#define V(p) (*((int*)(p)))

#include <iostream>
#include <fstream>
#include <string>
#include <cstdlib>
#include "tiggerclass.h"
using namespace std;

void yyerror(const char *);
void yyerror(const string&);
extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern int yylineno, charNum;

%}

%token ADD SUB MUL DIV MOD
%token ASSIGN EQ NEQ LE LEQ GE GEQ NOT AND OR
%token NUM IDENT
%token LBRAC RBRAC
%token IF GOTO LABEL PARAM CALL RETURN COLON VAR

%%
CompUnit: ADD;

%%

void yyerror(const char *s) {
    cout << "Line " << yylineno << "," << charNum << ": " << s << endl;
    exit(1);
}

void yyerror(const string &s) {
    yyerror(s.c_str());
}

int main(int argc, char **argv) {
    ios::sync_with_stdio(false);
    if (argc >= 4)
        if ((yyin = fopen(argv[3], "r")) == NULL)
            yyerror("Cannot open input file.");
    
    if (argc >= 6)
        if (freopen(argv[5], "w", stdout) == NULL)
            yyerror("Cannot open output file.");

    yyparse();

    fclose(yyin);
    return 0;
}