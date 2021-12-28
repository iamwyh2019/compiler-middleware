#ifndef TIGGER_CLASS
#define TIGGER_GLASS

#include <iostream>
#include <string>
#include <vector>
#include <queue>
#include <map>
#include <set>
using namespace std;

class Parser;

class Parser {
    int global_count;
    map<string, string> gscope;
    vector<string> ginit;
    vector<string> gdecl;
    vector<string> stmts;
    map<string, int> scope;
    map<string, int> funccost;
    string nowfunc;
    int stkcost;

    string newGVar(string&);
public:
    Parser();
    void addGInit(string&, int, int=0, bool=false);
    void addGDecl(string&, int=0);
    void parse();
    void newFunc(string&);
    void endFunc();
    void addVar(string&);
    void addStmt(const string&);
    string getName(string&);
};

#endif