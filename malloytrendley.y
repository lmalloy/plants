/*
      mfpl.y

 	Specifications for the MFPL language, YACC input file.

      To create syntax analyzer:

        flex mfpl.l
        bison mfpl.y
        g++ mfpl.tab.c -o mfpl_parser
        mfpl_parser < inputFileName
 */

/*
 *	Declaration section.
 */
%{
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <string>
#include <stack>
#include "SymbolTable.h"
using namespace std;

#define ARITHMETIC_OP	1   // classification for operators
#define LOGICAL_OP   	2
#define RELATIONAL_OP	3

int lineNum = 1;

stack<SYMBOL_TABLE> scopeStack;    // stack of scope hashtables
stack<string> relational;
stack<char> arithmetic;

bool isIntCompatible(const int theType);
bool isStrCompatible(const int theType);
bool isIntOrStrCompatible(const int theType);

void beginScope();
void endScope();
void copyInfo(TYPE_INFO& target, TYPE_INFO& source);
void cleanUp();
TYPE_INFO findEntryInAnyScope(const string theName);

void printRule(const char*, const char*);
int yyerror(const char* s) {
  printf("Line %d: %s\n", lineNum, s);
  cleanUp();
  exit(1);
}

extern "C" {
    int yyparse(void);
    int yylex(void);
    int yywrap() {return 1;}
}

%}

%union {
  char* text;
  int num;
  TYPE_INFO typeInfo;
};

/*
 *	Token declarations
*/
%token  T_LPAREN T_RPAREN 
%token  T_IF T_LETSTAR T_PRINT T_INPUT
%token  T_ADD  T_SUB  T_MULT  T_DIV
%token  T_LT T_GT T_LE T_GE T_EQ T_NE T_AND T_OR T_NOT	 
%token  T_INTCONST T_STRCONST T_T T_NIL T_IDENT T_UNKNOWN

%type	<text> T_IDENT
%type <typeInfo> N_EXPR N_PARENTHESIZED_EXPR N_ARITHLOGIC_EXPR  
%type <typeInfo> N_CONST N_IF_EXPR N_PRINT_EXPR N_INPUT_EXPR 
%type <typeInfo> N_LET_EXPR N_EXPR_LIST  
%type <num> N_BIN_OP

/*
 *	Starting point.
 */
%start  N_START

/*
 *	Translation rules.
 */
%%
N_START		: N_EXPR
			{
				printRule("START", "EXPR");
				printf("\n---- Completed parsing ----\n\n");
				
				if($1.type == INT)
				{
					printf("\nValue of the expression is %d \n", $1.integer);	
				}

				else if ($1.type == STR)
				{
					printf("\nValue of the expression is %s \n", $1.str);	
				}
				else if($1.boolean == true)
				{
					printf("\nValue of the expression is t \n");
				}

				else
				{
					printf("\nValue of the expression is nil \n");	
				}

				return 0;
			};

N_EXPR		: N_CONST
			{
				printRule("EXPR", "CONST");
				$$.type = $1.type;
				$$.integer = $1.integer;
				$$.boolean = $1.boolean;
				$$.str = $1.str;
			}
			| T_IDENT
			{
				printRule("EXPR", "IDENT");
				string ident = string($1);
				TYPE_INFO exprTypeInfo = findEntryInAnyScope(ident);

				if (exprTypeInfo.type == UNDEFINED) 
				{
					yyerror("Undefined identifier");
					return(0);
				}
				
				copyInfo($$,exprTypeInfo);
			}
			| T_LPAREN N_PARENTHESIZED_EXPR T_RPAREN
			{
				printRule("EXPR", "( PARENTHESIZED_EXPR )");
				$$.type = $2.type;
				$$.integer = $2.integer;
				$$.boolean = $2.boolean;
				$$.str = $2.str;

				if($$.type == BOOL)
				{
					$$.boolean = $2.boolean;
				}
				
				copyInfo($$,$2);
			};

N_CONST		: T_INTCONST
			{
				printRule("CONST", "INTCONST");
                $$.type = INT; 
				$$.integer = yylval.typeInfo.integer;
				$$.boolean = true;
				printf("Values of $$ and 1$ %d %d", $$.integer, yylval.typeInfo.integer);
			}
            | T_STRCONST
			{
				printRule("CONST", "STRCONST");
                $$.type = STR;
				$$.str = yylval.typeInfo.str;
			}
            | T_T
            {
				printRule("CONST", "t");
                $$.type = BOOL; 
				$$.boolean = true;
			}
            | T_NIL
            {
				printRule("CONST", "nil");
				$$.type = BOOL; 
				$$.boolean = false;
			};

N_PARENTHESIZED_EXPR	: N_ARITHLOGIC_EXPR 
						{
							printRule("PARENTHESIZED_EXPR", "ARITHLOGIC_EXPR");
							copyInfo($$,$1);
							/*$$.type = $1.type;
							$$.integer = $1.integer;
							$$.boolean = $1.boolean;
							$$.str = $1.str;

							if($$.type==BOOL)
							{
								$$.boolean = $1.boolean;
							} */
								
						}
                      	| N_IF_EXPR 
						{
							printRule("PARENTHESIZED_EXPR", "IF_EXPR");
							copyInfo($$,$1);
							//$$.type = $1.type; 
						}
                      	| N_LET_EXPR 
						{
							printRule("PARENTHESIZED_EXPR", "LET_EXPR");
							copyInfo($$,$1);
							//$$.type = $1.type; 
						}
						| N_PRINT_EXPR 
						{
							printRule("PARENTHESIZED_EXPR", "PRINT_EXPR");
							copyInfo($$,$1);
							
							/*$$.type = $1.type; 
							$$.type = $1.type;
							$$.integer = $1.integer;
							$$.boolean = $1.boolean;
							$$.str = $1.str;*/
						}
						| N_INPUT_EXPR 
						{
							printRule("PARENTHESIZED_EXPR", "INPUT_EXPR");
							copyInfo($$,$1);
							//$$.type = $1.type; 
						}
						| N_EXPR_LIST 
						{
							printRule("PARENTHESIZED_EXPR", "EXPR_LIST");
							copyInfo($$,$1);
							/*$$.type = $1.type;
							$$.integer = $1.integer;
							$$.boolean = $1.boolean;
							$$.str = $1.str;*/
						};

N_ARITHLOGIC_EXPR	: N_UN_OP N_EXPR
					{
						printRule("ARITHLOGIC_EXPR", "UN_OP EXPR");
						$$.type = BOOL; 
						copyInfo($$,$2);

						if($2.boolean == false)
						{
							$$.boolean = false;
						}

						else if($2.boolean == true)
						{
							$$.boolean = true;
						}
					}
					| N_BIN_OP N_EXPR N_EXPR
					{
						printRule("ARITHLOGIC_EXPR", "BIN_OP EXPR EXPR");
						$$.type = BOOL;
						switch ($1)
						{
						case (ARITHMETIC_OP) :
							$$.type = INT;

							if (!isIntCompatible($2.type)) 
							{
								yyerror("Arg 1 must be integer");
								return(0);
							}

							if (!isIntCompatible($3.type)) 
							{
								yyerror("Arg 2 must be integer");
								return(0);
							}
							
							if(arithmetic.top()=='+')
							{
								$$.integer = $2.integer + $3.integer;
								printf("Values of $$ and 1$ %d %d\n\n", $$.integer, $3.integer);
								arithmetic.pop();
							}

							else if(arithmetic.top() == '-')
							{
								$$.integer = $2.integer - $3.integer;
								printf("Values of $$ and 1$ %d %d\n\n", $$.integer, $3.integer);
								arithmetic.pop();
							}

							else if(arithmetic.top()== '*')
							{
								$$.integer = $2.integer * $3.integer;
								printf("Values of $$ and 1$ %d %d\n\n", $$.integer, $3.integer);
								arithmetic.pop();
							}

							else if(arithmetic.top()== '/')
							{
								if($3.integer == 0)
								{ 
									yyerror("Attempted division by zero\n");
								}

								$$.integer = $2.integer / $3.integer;
								printf("Values of $$ and 1$ %d %d\n\n", $$.integer, $3.integer);
								arithmetic.pop();
							}

							break;

					case (LOGICAL_OP) :
							break;

						case (RELATIONAL_OP) :
							if (!isIntOrStrCompatible($2.type)) 
							{
								yyerror("Arg 1 must be integer or string");
								return(0);
							}

							if (!isIntOrStrCompatible($3.type)) 
							{
							yyerror("Arg 2 must be integer or string");
							return(0);
							}

							if (isIntCompatible($2.type) && !isIntCompatible($3.type)) 
							{
								yyerror("Arg 2 must be integer");
								return(0);
							}

							else if (isStrCompatible($2.type) && !isStrCompatible($3.type)) 
							{
								yyerror("Arg 2 must be string");
								return(0);
							}

							if ($2.type||$3.type == STR)
							{
								$$.boolean = false;
							} 

							else if(relational.top() == ">")
							{
								if($2.integer > $3.integer)
								{
									$$.boolean = true;
								}
								else
								{
									$$.boolean = false;
								}
								relational.pop();
							}

							else if(relational.top() == "<")
							{
								if ($2.integer < $3.integer)
								{
									$$.boolean = true;
								}
								else
								{
									$$.boolean = false;
								}
								relational.pop();
							}

							else if(relational.top() == "<=")
							{
								if ($2.integer <= $3.integer)
								{
									$$.boolean = true;
								}
								else
								{
									$$.boolean = false;
								}
								relational.pop();
							}

							else if(relational.top() == ">=")
							{
								if ($2.integer >= $3.integer)
								{
									$$.boolean = true;
								}
								else
								{
									$$.boolean = false;
								}
								relational.pop();
							}

							else if(relational.top() == "=")
							{
								if ($2.integer == $3.integer)
								{
									$$.boolean = true;
								}
								else
								{
									$$.boolean = false;
								}
								relational.pop();
							}

							else if(relational.top() == "/=")
							{
								if ($2.integer != $3.integer)
								{
									$$.boolean = true;
								}
								else
								{
									$$.boolean = false;
								}
								relational.pop();
							}

							break; 
						}  // end switch
					};

N_IF_EXPR    	: T_IF N_EXPR N_EXPR N_EXPR
				{
					printRule("IF_EXPR", "if EXPR EXPR EXPR");
					if($2.boolean == true)
					{
						copyInfo($$,$3);
					}
					else
					{
						copyInfo($$,$4);
					}
					
					//$$.type = $3.type | $4.type; 
				};

N_LET_EXPR      : T_LETSTAR T_LPAREN N_ID_EXPR_LIST T_RPAREN N_EXPR
				{
					printRule("LET_EXPR", "let* ( ID_EXPR_LIST ) EXPR");
					endScope();
					copyInfo($$,$5);
					//$$.type = $5.type; 
				};

N_ID_EXPR_LIST  : /* epsilon */
				{
				printRule("ID_EXPR_LIST", "epsilon");
				}
                | N_ID_EXPR_LIST T_LPAREN T_IDENT N_EXPR T_RPAREN 
				{
					printRule("ID_EXPR_LIST", "ID_EXPR_LIST ( IDENT EXPR )");
					string lexeme = string($3);
					TYPE_INFO exprTypeInfo = $4;
					printf("___Adding %s to symbol table\n", $3);
					bool success = scopeStack.top().addEntry(SYMBOL_TABLE_ENTRY(lexeme, exprTypeInfo));

					if (! success) 
					{
						yyerror("Multiply defined identifier");
						return(0);
					}
				};

N_PRINT_EXPR    : T_PRINT N_EXPR
				{
					printRule("PRINT_EXPR", "print EXPR");
					copyInfo($$,$2);
					/*$$.type = $2.type;
					$$.integer = $2.integer;
					$$.boolean = $2.boolean;
					$$.str = $2.str;
					*/
				};

N_INPUT_EXPR	: T_INPUT
				{
					printRule("INPUT_EXPR", "input");
					$$.type = INT_OR_STR;
				};

N_EXPR_LIST : N_EXPR N_EXPR_LIST  
			{
				printRule("EXPR_LIST", "EXPR EXPR_LIST");
                copyInfo($$,$2);
				
				/*$$.type = $2.type;
				$$.integer = $2.integer;
				$$.boolean = $2.boolean;
				$$.str = $2.str;*/
			}
        	| N_EXPR
			{
				printRule("EXPR_LIST", "EXPR");
				copyInfo($$,$1);
				
				/*$$.type = $1.type;
				$$.integer = $1.integer;
				$$.boolean = $1.boolean;
				$$.str = $1.str;*/
			};

N_BIN_OP	: N_ARITH_OP
			{
				printRule("BIN_OP", "ARITH_OP");
				$$ = ARITHMETIC_OP;
			}
			|
			N_LOG_OP
			{
				printRule("BIN_OP", "LOG_OP");
				$$ = LOGICAL_OP;
			}
			|
			N_REL_OP
			{
				printRule("BIN_OP", "REL_OP");
				$$ = RELATIONAL_OP;
			};

N_ARITH_OP	: T_ADD
			{
				arithmetic.push('+');
				printRule("ARITH_OP", "+");
			}
            | T_SUB
			{
				arithmetic.push('-');
				printRule("ARITH_OP", "-");
			}
			| T_MULT
			{
				arithmetic.push('*');
				printRule("ARITH_OP", "*");
			}
			| T_DIV
			{
				arithmetic.push('/');
				printRule("ARITH_OP", "/");
			};

N_REL_OP	: T_LT
			{
				relational.push("<");
				printRule("REL_OP", "<");
			}	
			| T_GT
			{
				relational.push(">");
				printRule("REL_OP", ">");
			}	
			| T_LE
			{
				relational.push("<=");
				printRule("REL_OP", "<=");
			}	
			| T_GE
			{
				relational.push(">=");
				printRule("REL_OP", ">=");
			}	
			| T_EQ
			{
				relational.push("=");
				printRule("REL_OP", "=");
			}	
			| T_NE
			{
				relational.push("/=");
				printRule("REL_OP", "/=");
			};

N_LOG_OP	: T_AND
			{
				printRule("LOG_OP", "and");
			}	
			| T_OR
			{
				printRule("LOG_OP", "or");
			};

N_UN_OP	    : T_NOT
			{
				printRule("UN_OP", "not");
			};
%%

#include "lex.yy.c"
extern FILE *yyin;

bool isIntCompatible(const int theType) 
{
  return((theType == INT) || (theType == INT_OR_STR) ||
         (theType == INT_OR_BOOL) || 
         (theType == INT_OR_STR_OR_BOOL));
}

bool isStrCompatible(const int theType) 
{
  return((theType == STR) || (theType == INT_OR_STR) ||
         (theType == STR_OR_BOOL) || 
         (theType == INT_OR_STR_OR_BOOL));
}

bool isIntOrStrCompatible(const int theType) 
{
  return(isStrCompatible(theType) || isIntCompatible(theType));
}

void printRule(const char* lhs, const char* rhs) 
{
  printf("%s -> %s\n", lhs, rhs);
  return;
}

void beginScope() {
  scopeStack.push(SYMBOL_TABLE());
  printf("\n___Entering new scope...\n\n");
}

void endScope() {
  scopeStack.pop();
  printf("\n___Exiting scope...\n\n");
}

TYPE_INFO findEntryInAnyScope(const string theName) 
{
  TYPE_INFO info = {UNDEFINED};

  if (scopeStack.empty( )) 
  	return(info);

  info = scopeStack.top().findEntry(theName);

  if (info.type != UNDEFINED)
    return(info);

  else { // check in "next higher" scope
	   SYMBOL_TABLE symbolTable = scopeStack.top( );
	   scopeStack.pop( );
	   info = findEntryInAnyScope(theName);
	   scopeStack.push(symbolTable); // restore the stack
	   return(info);
  }
}

void cleanUp() 
{
  if (scopeStack.empty()) 
    return;

  else 
  {
    scopeStack.pop();
    cleanUp();
  }
}

void copyInfo(TYPE_INFO& target, TYPE_INFO& source){
	target.type = source.type;
	target.str = source.str;
	target.integer = source.integer;
	target.boolean = source.boolean;
}

int main(int argc, char** argv)
{
	if (argc < 2)
	{
		printf("You must specify a file in the command line!\n");
		exit(1);
	}

	yyin = fopen(argv[1], "r");

	do{
			yyparse();
	} while (!feof(yyin));

	cleanUp();
	return 0;
}
