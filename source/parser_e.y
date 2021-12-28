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

int s_count = 0;
int p_count = 0;

Parser parser;

void addStore(const string &loadname) {
    if (loadname[0] == 'v') { // global variable
        parser.addStmt("loadaddr " + loadname + " s4");
        parser.addStmt("s4[0] = s0");
    }
    else {
        parser.addStmt("store s0 "+ loadname);
    }
}

%}

%token ADD SUB MUL DIV MOD
%token ASSIGN EQ NEQ LE LEQ GE GEQ NOT AND OR
%token NUM IDENT
%token LBRAC RBRAC
%token IF GOTO LABEL PARAM CALL RETURN COLON VAR FUNC END

%%
Program:    Slice
    | Program Slice
    ;

Slice:  Declaration
    | Initialization
    | FunctionDef
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
        parser.addGInit(name, val, index, true);
    }
    ;

FunctionDef:    FunctionHeader Statements FunctionEnd;

FunctionHeader: FUNC LBRAC NUM RBRAC
    {
        string &fname = *(string*)$1;
        int nparams = V($3);
        parser.addStmt("@" + fname + " [" + to_string(nparams) + "]");
        parser.newFunc(fname);
    }

Statements: Statement
    | Statements Statement;

Statement:  SDeclaration
    | Expression
    ;

SDeclaration:   VAR IDENT
    {
        string &fname = *(string*)$2;
        parser.addVar(fname);
    }
    | VAR NUM IDENT
    {
        string &fname = *(string*)$3;
        parser.addVar(fname);
    }
    ;

Expression: IDENT ASSIGN RVal BinOp RVal
    {
        string &name = *(string*)$1;
        string loadname = parser.getName(name);
        string &op = *(string*)$4;
        parser.addStmt("s0 = s1 " + op + " s2");

        addStore(loadname);
        s_count = 0;
    }
    | IDENT ASSIGN Op RVal
    {
        string &name = *(string*)$1;
        string loadname = parser.getName(name);
        string &op = *(string*)$3;
        parser.addStmt("s0 = " + op + " s1");

        addStore(loadname);
        s_count = 0;
    }
    | IDENT ASSIGN RVal
    {
        string &name = *(string*)$1;
        string loadname = parser.getName(name);
        parser.addStmt("s0 = s1");

        addStore(loadname);
        s_count = 0;
    }
    | IDENT LBRAC RVal RBRAC ASSIGN RVal
    {
        string &name = *(string*)$1;
        string loadname = parser.getName(name);
        parser.addStmt("loadaddr " + loadname + " s0");
        
        parser.addStmt("s0 = s0 + s1");
        parser.addStmt("s0[0] = s2");

        s_count = 0;
    }
    | IDENT ASSIGN IDENT LBRAC RVal RBRAC
    {
        string &name = *(string*)$1;
        string loadname = parser.getName(name);

        string &arrname = *(string*)$3;
        string loadarrname = parser.getName(arrname);

        parser.addStmt("loadaddr " + loadarrname + " s2");
        parser.addStmt("s2 = s2 + s1");
        parser.addStmt("s0 = s2[0]");

        addStore(loadname);
        s_count = 0;
    }
    | IF RVal LogicOp RVal GOTO LABEL
    {
        string &op = *(string*)$3;
        string &label = *(string*)$6;
        parser.addStmt("if s1 " + op + " s2 goto " + label);
        s_count = 0;
    }
    | GOTO LABEL
    {
        string &label = *(string*)$2;
        parser.addStmt("goto " + label);
    }
    | LABEL COLON
    {
        string &label = *(string*)$1;
        parser.addStmt(label + ":");
    }
    | PARAM RVal
    {
        parser.addStmt("a" + to_string(p_count++) + " = s1");
        s_count = 0;
    }
    | CALL FUNC
    {
        p_count = 0;
        string &funcname = *(string*)$2;
        parser.addStmt("call " + funcname);
    }
    | IDENT ASSIGN CALL FUNC
    {
        p_count = 0;
        string &funcname = *(string*)$2;
        string &name = *(string*)$1;
        string loadname = parser.getName(name);

        parser.addStmt("call " + funcname);
        parser.addStmt("s0 = a0");
        addStore(loadname);
    }
    | RETURN
    {
        parser.addStmt("return");
    }
    | RETURN RVal
    {
        parser.addStmt("a0 = s1");
        parser.addStmt("return");
        s_count = 0;
    }
    ;

RVal:   NUM
    {
        string regname = "s" + to_string(++s_count);
        string val = to_string(V($1));
        parser.addStmt(regname + " = " + val);
    }
    | IDENT
    {
        string regname = "s" + to_string(++s_count);
        string name = *(string*)$1;
        if (name[0] == 'p') {
            name[0] = 'a';
            parser.addStmt(regname + " = " + name);
        }
        else {
            string loadname = parser.getName(name);
            parser.addStmt("load " + loadname + " " + regname);
        }
    }
    ;

BinOp:  Op {$$ = $1;}
    | LogicOp {$$ = $1;}

Op: ADD {$$ = new string("+");}
    | SUB {$$ = new string("-");}
    | MUL {$$ = new string("*");}
    | DIV {$$ = new string("/");}
    | MOD {$$ = new string("%");}
    ;

LogicOp:    AND {$$ = new string("&&");}
    | OR {$$ = new string("||");}
    | NOT {$$ = new string("!");}
    | LE {$$ = new string("<");}
    | LEQ {$$ = new string("<=");}
    | GE {$$ = new string(">");}
    | GEQ {$$ = new string(">=");}
    | EQ {$$ = new string("==");}
    | NEQ {$$ = new string("!=");}
    ;

FunctionEnd:    END FUNC
    {
        string &fname = *(string*)$2;
        parser.addStmt("end " + fname);
        parser.endFunc();
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