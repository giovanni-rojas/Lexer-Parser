%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <iostream>

    #include "ast.hpp"
    
    #define YYDEBUG 1
    int yylex(void);
    void yyerror(const char *);
    
    extern ASTNode* astRoot;
%}

%error-verbose

/* WRITEME: Copy your token and precedence specifiers from Project 3 here */

%token T_PLUS
%token T_MINUS
%token T_MULTIPLY
%token T_DIVIDE
%token T_EQUAL
%token T_EQUALEQ
%token T_GREAT
%token T_GREATEQ
%token T_SEMIC
%token T_COLON
%token T_ARROW
%token T_LEFTPAREN
%token T_RIGHTPAREN
%token T_LEFTBRACK
%token T_RIGHTBRACK
%token T_COMMA
%token T_AND
%token T_OR
%token T_IF
%token T_ELSE
%token T_TRUE
%token T_FALSE
%token T_PRINT
%token T_RETURN
%token T_INT
%token T_BOOL
%token T_NEW
%token T_NOT
%token T_NONE
%token T_DOT
%token T_ID
%token T_INTVALUE
%token T_EOF
%token T_UMINUS
%token T_DO
%token T_WHILE
%token T_EXTENDS

%left T_OR
%left T_AND
%left T_GREAT T_GREATEQ T_EQUALEQ
%left T_PLUS T_MINUS
%left T_MULTIPLY T_DIVIDE
%precedence T_NOT T_UMINUS

/* WRITEME: Specify types for all nonterminals and necessary terminals here */

%type <expression_ptr> Expr;
%type <returnstatement_ptr> Return;
%type <methodcall_ptr> MethodCall;
%type <identifier_ptr> T_ID;
%type <assignment_ptr> Assignment;
%type <expression_list_ptr> Parameter;
%type <parameter_ptr> Argument;
%type <parameter_list_ptr> Args Arg;
%type <integer_ptr> T_INTVALUE T_TRUE T_FALSE
%type <statement_ptr> Statement;
%type <statement_list_ptr> Block Statements;
%type <dowhile_ptr> DOWHILE;
%type <ifelse_ptr> IFELSE;
%type <declaration_list_ptr> MemberList DeclarationList;
%type <declaration_ptr> Member;
%type <identifier_list_ptr> Declaration;
%type <type_ptr> Type ReturnT;
%type <integertype_ptr> T_INT;
%type <booleantype_ptr> T_BOOL;
%type <methodbody_ptr> Body;
%type <method_ptr> Method;
%type <method_list_ptr> MethodList;
%type <class_ptr> Class;
%type <class_list_ptr> ClassList;
%type <program_ptr> Start;

%%

/* WRITEME: This rule is a placeholder. Replace it with your grammar
            rules from Project 3 */

Start : ClassList
	;

CClassList : Class ClassList | Class
	;

Class : T_ID T_LEFTBRACK MemberList MethodList T_RIGHTBRACK 
	| T_ID T_EXTENDS T_ID T_LEFTBRACK MemberList MethodList T_RIGHTBRACK 

	;

Type : T_INT | T_BOOL | T_ID
	;

MemberList : MemberList Member
 	|%empty
	;

Member : Type T_ID T_SEMIC
	;	

MethodList : Method MethodList
	| %empty
	;

Method :  T_ID T_LEFTPAREN Args T_RIGHTPAREN T_ARROW ReturnT T_LEFTBRACK Body T_RIGHTBRACK
	;

Args : Arg | %empty
	;

Arg : Arg T_COMMA Argument | Argument 
	;

Argument : Type T_ID
	;

ReturnT : Type | T_NONE
	;

Body : DeclarationList Statements Return
	;

DeclarationList : %empty | DeclarationList Type Declaration T_SEMIC
	;

Declaration : Declaration T_COMMA T_ID | T_ID 
	;

Statements : Statement Statements | %empty
	;

Statement : Assignment | IfElse | DoWhile | While| MethodCall | T_PRINT Expr T_SEMIC
	;

Assignment : T_ID T_EQUAL Expr T_SEMIC | T_ID T_DOT T_ID T_EQUAL Expr T_SEMIC
	;

IfElse : T_IF Expr T_LEFTBRACK Block T_RIGHTBRACK
| T_IF Expr T_LEFTBRACK Block T_RIGHTBRACK T_ELSE T_LEFTBRACK Block T_RIGHTBRACK
	;

DoWhile : T_DO T_LEFTBRACK Block T_RIGHTBRACK T_WHILE Expr T_SEMIC
	;

While: T_WHILE Expr T_LEFTBRACK Block T_RIGHTBRACK
	;

Block : Block Statement |  %empty
	;

Return : T_RETURN Expr T_SEMIC | %empty
	;

Expr :  Expr T_PLUS Expr
	|	Expr T_MINUS Expr
	|	Expr T_MULTIPLY Expr
	|	Expr T_DIVIDE Expr
	|	Expr T_GREAT Expr
	|	Expr T_GREATEQ Expr
	|	Expr T_EQUALEQ Expr
	|	Expr T_AND Expr
	|	Expr T_OR Expr
	|	T_NOT Expr
	|	T_MINUS Expr %prec T_UMINUS
	|	T_ID
	|	T_ID T_DOT T_ID
	|	MethodCall
	|	T_LEFTPAREN Expr T_RIGHTPAREN
	|	T_INTVALUE
	|	T_TRUE
	|	T_FALSE
	|	T_NEW T_ID
	|	T_NEW T_ID T_LEFTPAREN Parameter T_RIGHTPAREN
	;

MethodCall : T_ID T_LEFTPAREN Args T_RIGHTPAREN T_SEMIC
| T_ID T_DOT T_ID T_LEFTPAREN Args T_RIGHTPAREN T_SEMIC
	;

Parameter : Parameter T_COMMA Expr | Expr 
	;

%%

extern int yylineno;

void yyerror(const char *s) {
  fprintf(stderr, "%s at line %d\n", s, yylineno);
  exit(0);
}
