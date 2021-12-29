#include "tiggerclass.h"

Parser::Parser() {
    global_count = 0;
}

string Parser::newGVar(string &name, VarType tp) {
    string gvar = "v" + to_string(global_count++);
    gscope[name] = gvar;
    gtype[name] = tp;
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
    bool is_array = (len>0);
    auto gvar = newGVar(name, is_array? ArrType: IntType);
    if (is_array)
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
        cout << "return" << endl;
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
    scopetype.clear();
    funccost[nowfunc] = stkcost;
}

void Parser::addVar(string &name, VarType tp, int len) {
    scope[name] = stkcost;
    stkcost += len;
    scopetype[name] = tp;
}

void Parser::addStmt(const string &stmt) {
    stmts.emplace_back(stmt);
}

string Parser::getName(string &name) {
    if (name[0] == 'p')
        return "a" + name.substr(1);
    auto iter2 = scope.find(name);
    if (iter2 != scope.end())
        return to_string(iter2->second);
    auto iter = gscope.find(name);
    return iter->second;
}

VarType Parser::getType(string &name) {
    auto iter2 = scopetype.find(name);
    if (iter2 != scopetype.end())
        return iter2->second;
    auto iter = gtype.find(name);
    if (iter != gtype.end())
        return iter->second;
    return IntType;
}