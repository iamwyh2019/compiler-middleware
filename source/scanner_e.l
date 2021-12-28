%{
#include <iostream>
#include <string>
#include <cstring>
#include "parser_e.tab.h"
#include "tiggerclass.h"
using namespace std;
#define YYSTYPE void*
int charNum = 1;
%}
%option yylineno

digit [0-9]

%%
[\040\t]    {charNum += yyleng;}
[\n\r]  {charNum = 1;}
if      {charNum += yyleng; return IF;}
return  {charNum += yyleng; return RETURN;}
var     {charNum += yyleng; return VAR;}
goto    {charNum += yyleng; return GOTO;}
call    {charNum += yyleng; return CALL;}
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