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

class Variable {
    string tigger_name;
    bool is_global;
    friend class Parser;
public:
    Variable(const string&);
    Variable(int);
    string& getName();
};

class Parser {
    int global_count;
    map<string, Variable*> gscope;
    vector<string> ginit;
    vector<string> gdecl;
    map<string, int> scope;

    Variable* newGVar(string&);
public:
    Parser();
    void addGInit(string&, int, int=0, bool=false);
    void addGDecl(string&, int=0);
    void parse();
};

#endif