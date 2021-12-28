#include "tiggerclass.h"

Parser::Parser() {
    global_count = 0;
}

string Parser::newGVar(string &name) {
    string gvar = "v" + to_string(global_count++);
    gscope[name] = gvar;
    return gvar;
}

void Parser::addGInit(string &name, int val, int index, bool is_array) {
    static string last_var;
    auto gvar = gscope[name];
    if (val != 0) {
        if (last_var != name)
            ginit.emplace_back("loadaddr " + gvar + " t0");
        ginit.emplace_back("t1 = " + to_string(val));
        ginit.emplace_back("t0[" + to_string(index) + "] = t1");
        last_var = name;
    }
    else if (is_array) {
        if (last_var != name)
            ginit.emplace_back("loadaddr " + gvar + " t0");
        ginit.emplace_back("t0[" + to_string(index) + "] = x0");
        last_var = name;
    }
}

void Parser::addGDecl(string &name, int len) {
    auto gvar = newGVar(name);
    if (len == 0)
        gdecl.emplace_back(gvar + " = 0");
    else
        gdecl.emplace_back(gvar + " = malloc " + to_string(len));
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

    for (auto &stmt: stmts) {
        if (stmt[0] == '@') {
            string funcdecl = stmt.substr(1);
            string fname = funcdecl.substr(0, funcdecl.find(' '));
            int fcost = funccost[fname];
            cout << funcdecl << " [" << fcost << "]" << endl;

            if (need_ginit && fname == "f_main") {
                cout << "call " << ginit_name << endl;
            }
        }
        else cout << stmt << endl;
    }
}

void Parser::newFunc(string &funcname) {
    nowfunc = funcname;
    stkcost = 0;
}

void Parser::endFunc() {
    scope.clear();
    funccost[nowfunc] = stkcost;
}

void Parser::addVar(string &name) {
    scope[name] = stkcost++;
}

void Parser::addStmt(const string &stmt) {
    stmts.emplace_back(stmt);
}

string Parser::getName(string &name) {
    if (name[0] == 'p')
        return "a" + name.substr(1);
    auto iter = gscope.find(name);
    if (iter != gscope.end())
        return iter->second;
    auto iter2 = scope.find(name);
    return to_string(iter2->second);
}