%{
#define YYSTYPE void*
#include <iostream>
#include <string>
#include <cstring>
#include "parser_e.tab.h"
#include "tiggerclass.h"
using namespace std;
int charNum = 1;
%}
%option yylineno

digit [0-9]
letter_ [A-Za-z_]
ident {letter_}({letter_}|{digit})*
fname f_{ident}
label l{digit}+

%%
[\040\t]    {charNum += yyleng;}
[\n\r]  {charNum = 1;}
if      {charNum += yyleng; return IF;}
return  {charNum += yyleng; return RETURN;}
var     {charNum += yyleng; return VAR;}
goto    {charNum += yyleng; return GOTO;}
call    {charNum += yyleng; return CALL;}
param   {charNum += yyleng; return PARAM;}
label   {
    charNum += yyleng;
    yylval = new string(yytext);
    return LABEL;
}
[Ttp]{digit}+   {
    charNum += yyleng;
    yylval = new string(yytext);
    return IDENT;
}
{fname}     {
    charNum += yyleng;
    yylval = new string(yytext);
    return FUNC;
}
{digit}+    {
    charNum += yyleng;
    yylval = new int(strtol(yytext, nullptr, 10));
    return NUM;
}
":"     {++charNum; return COLON;}
"+"     {++charNum; return ADD;}
"-"     {++charNum; return SUB;}
"*"     {++charNum; return MUL;}
"/"     {++charNum; return DIV;}
"<"     {++charNum; return LE;}
"<="    {charNum += 2; return LEQ;}
">"     {++charNum; return GE;}
">="    {charNum += 2; return GEQ;}
"=="    {charNum += 2; return EQ;}
"!="    {charNum += 2; return NEQ;}
"="     {++charNum; return ASSIGN;}
"["     {++charNum; return LBRAC;}
"]"     {++charNum; return RBRAC;}
"&&"    {charNum += 2; return AND;}
"||"    {charNum += 2; return OR;}
"!"     {++charNum; return NOT;}
"%"     {++charNum; return MOD;}

"//".*$ {/* Single line comment */}
%%

int yywrap() {
    return 1;
}