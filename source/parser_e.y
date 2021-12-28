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

Parser parser;

%}

%token ADD SUB MUL DIV MOD
%token ASSIGN EQ NEQ LE LEQ GE GEQ NOT AND OR
%token NUM IDENT
%token LBRAC RBRAC
%token IF GOTO LABEL PARAM CALL RETURN COLON VAR FUNC END

%%
Program:    Declaration
    | Program Declaration
    | Initialization
    | Program Initialization
    ;

Declaration:    VAR IDENT 
    {
        string &name = *(string*)$2;
        parser.addGDecl(name, 0);
    }
    | VAR NUM IDENT
    {
        string &name = *(string*)$3;
        int len = V($2);
        parser.addGDecl(name, len);
    }
    ;

Initialization: IDENT ASSIGN NUM
    {
        string &name = *(string*)$1;
        int val = V($3);
        parser.addGInit(name, val);
    }
    | IDENT LBRAC NUM RBRAC ASSIGN NUM
    {
        string &name = *(string*)$1;
        int index = V($3);
        int val = V($6);
        parser.addGInit(name, val, index);
    }

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
    parser.parse();

    fclose(yyin);
    return 0;
}