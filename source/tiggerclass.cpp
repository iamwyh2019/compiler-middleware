#include "tiggerclass.h"

Variable::Variable(const string &s) {
    tigger_name = s;
    is_global = false;
}

Variable::Variable(int num) {
    // This is a global variable
    tigger_name = "v" + to_string(num);
    is_global = true;
}

string& Variable::getName() {
    return tigger_name;
}

Parser::Parser() {
    global_count = 0;
}

Variable* Parser::newGVar(string &name) {
    auto gvar = new Variable(global_count++);
    gscope[name] = gvar;
    return gvar;
}

void Parser::addGInit(string &name, int val, int index) {
    auto gvar = gscope[name];
    ginit.emplace_back("load " + to_string(val) + " t1");
    ginit.emplace_back("loadaddr " + gvar->tigger_name + " t0");
    ginit.emplace_back("t0[" + to_string(index) + "] = t1");
}

void Parser::addGDecl(string &name, int len) {
    auto gvar = newGVar(name);
    if (len == 0)
        gdecl.emplace_back(gvar->tigger_name + " = 0");
    else
        gdecl.emplace_back(gvar->tigger_name + " = malloc " + to_string(len));
}

void Parser::parse() {
    for (auto &s: gdecl)
        cout << s << endl;
    
    bool need_ginit = (ginit.size() > 0);
    string ginit_name = "f___GINIT";
    if (need_ginit) {
        cout << ginit_name << " [0] [0]" << endl;
        for (auto &stmt: ginit)
            cout << '\t' << stmt << endl;
        cout << "end " << ginit_name << endl;
    }
}