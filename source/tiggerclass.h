#ifndef TIGGER_CLASS
#define TIGGER_GLASS

#include <iostream>
#include <string>
#include <vector>
#include <queue>
#include <map>
#include <set>
using namespace std;

enum VarType {
    IntType,
    ArrType,
};

class Parser;

class Parser {
    int global_count;
    map<string, string> gscope;
    map<string, VarType> gtype;
    vector<string> ginit;
    vector<string> gdecl;
    vector<string> stmts;
    map<string, int> scope;
    map<string, int> funccost;
    map<string, VarType> scopetype;
    string nowfunc;
    int stkcost;

    string newGVar(string&, VarType);
public:
    Parser();
    void addGInit(string&, int, int=0, bool=false);
    void addGDecl(string&, int=0);
    void parse();
    void newFunc(string&);
    void endFunc();
    void addVar(const string&, VarType, int=1);
    void addStmt(const string&);
    string getName(string&);
    VarType getType(string&);
};

#endif