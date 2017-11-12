%option yylineno
%pointer

%{
    #include <stdlib.h>
    #include <errno.h>
    #include <limits.h>
    #include "ast.hpp"
    #include "parser.hpp"
    void yyerror(const char *);
%}

/* WRITEME: Copy any definitions and start conditions from Project 3 here */

%%

  /* WRITEME: Copy your Flex rules from Project 3 here */
"//".*            ;
[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]      ;
[ \t\n]           ; 
"+"               { return T_PLUS; }
"-"               { return T_MINUS; }
"*"               { return T_MULTIPLY; }
"/"               { return T_DIVIDE; }
"="               { return T_EQUAL; }
"equals"              { return T_EQUALEQ; }
">"               { return T_GREAT; }
">="              { return T_GREATEQ; }
";"               { return T_SEMIC; }
":"               { return T_COLON; }
"->"              { return T_ARROW; }
"("               { return T_LEFTPAREN; }
")"               { return T_RIGHTPAREN; }
"{"               { return T_LEFTBRACK; }
"}"               { return T_RIGHTBRACK; }
","               { return T_COMMA; }
"and"             { return T_AND; }
"or"              { return T_OR; }
"if"              { return T_IF; }
"else"            { return T_ELSE; }
"while"           { return T_WHILE; }
"do"              { return T_DO; }
"true"            { yylval.integer_ptr = new IntegerNode(1); return T_TRUE; }
"false"           { yylval.integer_ptr = new IntegerNode(0); return T_FALSE; }
"print"           { return T_PRINT; }
"return"          { return T_RETURN; }
"int"             { return T_INT; }
"bool"            { return T_BOOL; }
"new"             { return T_NEW; }
"not"             { return T_NOT; }
"none"            { return T_NONE; }
"extends"         { return T_EXTENDS; }
"."               { return T_DOT; }
[a-zA-Z][a-zA-Z0-9]*     { yylval.identifier_ptr = new IdentifierNode(strdup(yytext)); return T_ID; }
0|[1-9][0-9]*            { yylval.integer_ptr = new IntegerNode(atoi(yytext)); return T_INTVALUE; }
.                 { yyerror("invalid character"); }

%%

int yywrap(void) {
  return 1;
}
