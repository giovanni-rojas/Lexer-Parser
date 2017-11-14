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

 //precedence rules

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
%type <expression_list_ptr> ParameterList Parameter;
%type <parameter_ptr> Argument;
%type <parameter_list_ptr> Args Arg;
%type <integer_ptr> T_INTVALUE T_TRUE T_FALSE
%type <statement_ptr> Statement;
%type <statement_list_ptr> Block Statements;
%type <dowhile_ptr> DoWhile;
%type <while_ptr> While;
%type <ifelse_ptr> IfElse;
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

Start : ClassList {$$ = new ProgramNode($1); astRoot = $$;}
	;

/* WRITME: Write your Bison grammar specification here */

ClassList : Class ClassList {$$ = $2; $$->push_front($1);}
| Class {$$ = new std::list<ClassNode*>(); $$->push_back($1);}
	;

Class : T_ID T_LEFTBRACK MemberList MethodList T_RIGHTBRACK {$$ = new ClassNode($1,NULL,$3,$4);}
| T_ID T_EXTENDS T_ID T_LEFTBRACK MemberList MethodList T_RIGHTBRACK {$$ = new ClassNode($1,$3,$5,$6);}

	;

Type : T_INT {$$ = new IntegerTypeNode();}
| T_BOOL {$$ = new BooleanTypeNode();}
| T_ID {$$ = new ObjectTypeNode($1);}
	;

MemberList : MemberList Member {$$ = $1; $$->push_back($2);}
|%empty {$$ = new std::list<DeclarationNode*>();}
	;

Member : Type T_ID T_SEMIC {$$ = new DeclarationNode($1, new std::list<IdentifierNode*>(1, $2));}
	;	

MethodList : Method MethodList {$$ = $2; $$->push_front($1);}
| %empty {$$ = new std::list<MethodNode*>();}
	;

Method :  T_ID T_LEFTPAREN Args T_RIGHTPAREN T_ARROW ReturnT T_LEFTBRACK Body T_RIGHTBRACK {$$ = new MethodNode($1,$3,$6,$8);}
	;

Args : Arg {$$ = $1;}
| %empty {$$ = new std::list<ParameterNode*>();}
	;

Arg : Arg T_COMMA Argument {$$ = $1; $$->push_back($3);}
| Argument {$$ = new std::list<ParameterNode*>(); $$->push_back($1);}
	;

Argument : Type T_ID {$$ = new ParameterNode($1,$2);}
	;

ReturnT : Type {$$ = $1;}
| T_NONE {$$ = new NoneNode();}
	;

Body : DeclarationList Statements Return {$$ = new MethodBodyNode($1,$2,$3);}
	;

DeclarationList : DeclarationList Type Declaration T_SEMIC {$$=$1; $$->push_back(new DeclarationNode($2,$3));}
| %empty {$$ = new std::list<DeclarationNode*>();}
;

Declaration : Declaration T_COMMA T_ID {$$ = $1; $$->push_back($3);}
| T_ID {$$ = new std::list<IdentifierNode*>(); $$->push_back($1);}
	;

Statements : Statement Statements {$$ = $2; $$->push_front($1);}
| %empty {$$ = new std::list<StatementNode*>();}
	;

Statement : Assignment {$$ = $1;}| IfElse {$$ = $1;} | DoWhile {$$ = $1;}| While {$$ = $1;}| MethodCall {$$ = new CallNode($1);}| T_PRINT Expr T_SEMIC {$$ = new PrintNode($2);}
	;

Assignment : T_ID T_EQUAL Expr T_SEMIC {$$ = new AssignmentNode($1,NULL,$3);}
|T_ID T_DOT T_ID T_EQUAL Expr T_SEMIC {$$ = new AssignmentNode($1, $3, $5);}
	;

IfElse : T_IF Expr T_LEFTBRACK Block T_RIGHTBRACK {$$ = new IfElseNode($2, $4, NULL);}
| T_IF Expr T_LEFTBRACK Block T_RIGHTBRACK T_ELSE T_LEFTBRACK Block T_RIGHTBRACK {$$ = new IfElseNode($2, $4, $8);}
	;

DoWhile : T_DO T_LEFTBRACK Block T_RIGHTBRACK T_WHILE T_LEFTPAREN Expr T_RIGHTPAREN T_SEMIC {$$ = new DoWhileNode($3,$7);}
	;

While : T_WHILE Expr T_LEFTBRACK Block T_RIGHTBRACK {$$ = new WhileNode($2,$4);}
;

Block : Block Statement {$$->push_back($2);}
|  Statement {$$ = new std::list<StatementNode*>(); $$->push_back($1);}
	;

Return : T_RETURN Expr T_SEMIC {$$ = new ReturnStatementNode($2);}
| %empty {$$ = NULL;}
	;

Expr :  Expr T_PLUS Expr {$$ = new PlusNode($1,$3);}
|	Expr T_MINUS Expr {$$ = new MinusNode($1,$3);}
|	Expr T_MULTIPLY Expr {$$ = new TimesNode($1,$3);}
|	Expr T_DIVIDE Expr {$$ = new DivideNode($1,$3);}
|	Expr T_GREAT Expr {$$ = new GreaterNode($1,$3);}
|	Expr T_GREATEQ Expr {$$ = new GreaterEqualNode($1,$3);}
|	Expr T_EQUALEQ Expr {$$ = new EqualNode($1, $3);}
|	Expr T_AND Expr {$$ = new AndNode($1,$3);}
|	Expr T_OR Expr {$$ = new OrNode($1,$3);}
|	T_NOT Expr {$$ = new NotNode($2);}
|	T_MINUS Expr %prec T_UMINUS {$$ = new NegationNode($2);}
|	T_ID {$$ = new VariableNode($1);}
|	T_ID T_DOT T_ID {$$ = new MemberAccessNode($1,$3);}
|	MethodCall {$$ = $1;}
|	T_LEFTPAREN Expr T_RIGHTPAREN {$$ = $2 ;}
|	T_INTVALUE {$$ = new IntegerLiteralNode($1);}
|	T_TRUE {$$ = new BooleanLiteralNode($1);}
|	T_FALSE {$$ = new BooleanLiteralNode($1);}
|	T_NEW T_ID {$$ = new NewNode($2,NULL);}
|	T_NEW T_ID T_LEFTPAREN ParameterList T_RIGHTPAREN {$$ = new NewNode($2,$4);}
;

MethodCall : T_ID T_LEFTPAREN ParameterList T_RIGHTPAREN T_SEMIC {$$ = new MethodCallNode($1, NULL, $3);}
| T_ID T_DOT T_ID T_LEFTPAREN ParameterList T_RIGHTPAREN T_SEMIC {$$ = new MethodCallNode($1, $3, $5);}
	;

ParameterList: Parameter {$$ = $1;} | %empty {$$ = new std::list<ExpressionNode*>();}
;

Parameter : Parameter T_COMMA Expr {$$ = $1; $$->push_back($3);}
   | Expr {$$ = new std::list<ExpressionNode*>();$$->push_back($1);}
	;


%%

extern int yylineno;

void yyerror(const char *s) {
  fprintf(stderr, "%s at line %d\n", s, yylineno);
  exit(0);
}
