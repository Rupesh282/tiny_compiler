/*
 * Acknowledgement: Qifan Chang and Zixian Lai 
 * acknowledgement for documentation : Abhishek Raj
 **/
%{
	#include <stdio.h>
	#include <iostream>
	#include <string>
	#include <vector>
	#include <utility>
	#include "main.h"
	extern int yylex();
	extern char* yytext();
	extern int yyparse();
	extern int yylineno;
	using namespace std;

//std::string * global_name = new std::string("GLOBAL");
std::string global_name = "GLOBAL";	 // GLOBAL scope name
std::string block_name = "BLOCK";	// block label prefix
std::string temp_name = "T";		// temp var name prefix
std::string stack_sign = "$";		// prefix for accessing vars in stack
std::string lable_name = "label";	// label prefix
int block_counter = 0;
int temp_counter = -1;
int label_num = 0;
int scope_counter = 0;
int link_counter = 1;
int param_counter = 1;
int local_counter = 0;
bool in_function = false;
std::map<string, bool> func_var_map;	 // stores if var is present in current function or not
std::map<string, bool> func_type_map;	// stores type (int / float) of vars
//int map_index = 0;


//---------------Global variables------------
	std::vector<std::Scope*> SymTabHead;
	std::vector<std::IR_code*> IR_vector;
	std::stack<int> label_counter;
	//std::ASTNode * test = new std::ASTNode();
	//------------ Local variables-------------
	std::map<Symbol*, int> newMap;
	std::map<Symbol*, int>* currMap = &newMap;
	std::vector<std::string*> scope_table;
	//----------------------------------------------


	void yyerror(char const* msg)
	{
		printf("Not accepted");
	}
%}

//%option yylineno

%token TOKEN_EOF
%token TOKEN_INTLITERAL
%token TOKEN_FLOATLITERAL

%token TOKEN_PROGRAM
%token TOKEN_BEGIN
%token TOKEN_END
%token TOKEN_FUNCTION
%token TOKEN_READ
%token TOKEN_WRITE
%token TOKEN_IF
%token TOKEN_ELSE
%token TOKEN_FI
%token TOKEN_FOR
%token TOKEN_ROF
%token TOKEN_RETURN
%token <tok_numer> TOKEN_INT
%token TOKEN_VOID
%token TOKEN_STRING
%token <tok_numer> TOKEN_FLOAT
%token TOKEN_OP_NE
%token TOKEN_OP_PLUS
%token TOKEN_OP_MINS
%token TOKEN_OP_STAR
%token TOKEN_OP_SLASH
%token TOKEN_OP_EQ
%token TOKEN_OP_NEQ
%token TOKEN_OP_LESS
%token TOKEN_OP_GREATER
%token TOKEN_OP_LP
%token TOKEN_OP_RP
%token TOKEN_OP_SEMIC
%token TOKEN_OP_COMMA
%token TOKEN_OP_LE
%token TOKEN_OP_GE

%token TOKEN_STRINGLITERAL
%token <str> TOKEN_IDENTIFIER
%start program

%union{
	std::string * str;
	int tok_numer;
	std::vector <std::string*> * svec;
	std::ASTNode* ast_node;
	std::vector <std::ASTNode*>* expr_vector;
}

%type <tok_numer> var_type compop any_type
%type <str> id str
%type <svec> id_tail id_list
%type <ast_node> primary factor_prefix postfix_expr mulop addop factor expr_prefix expr assign_expr call_expr
%type <expr_vector> expr_list_tail expr_list



%%
program:	TOKEN_PROGRAM id TOKEN_BEGIN{

	// we are at start of program, create GLOBAL scope
	std::Scope * globalScope = new std::Scope(global_name);
	SymTabHead.push_back(globalScope); //push to symTabHead
	// start of 3AC code
	std::IR_code * start_code = new std::IR_code("IR", "code", "", "", temp_counter);
	IR_vector.push_back(start_code);

}
pgm_body TOKEN_END{};

id:		TOKEN_IDENTIFIER {
			$$ = yylval.str; // set id name 
		};

pgm_body:	decl{
				// push 4 registers and return address space to stack
				std::IR_code * push_code = new std::IR_code("PUSH", "", "", "", temp_counter);
				IR_vector.push_back(push_code); // reg
				IR_vector.push_back(push_code); // reg  
				IR_vector.push_back(push_code); // reg
				IR_vector.push_back(push_code); // reg
				IR_vector.push_back(push_code); // return adddress space on stack
				//jumpt to main function to start execution
				std::IR_code * main_code = new std::IR_code("JSR", "", "", "main", temp_counter);
				IR_vector.push_back(main_code);
				// halt command indicating end of execution / program
				std::IR_code * halt_code = new std::IR_code("HALT", "", "", "", temp_counter);
				IR_vector.push_back(halt_code);

} func_declarations{};

decl:		string_decl decl{}
		|	var_decl decl{}
		|	;

string_decl:	TOKEN_STRING id TOKEN_OP_NE str TOKEN_OP_SEMIC {
	// create new symbol with var name as id and value as string value
	Symbol *newSym = new std::Symbol($2, $4, TOKEN_STRING, 0);
	// insert record in current scope table  / symbol table
	SymTabHead.back() -> insert_record(*($2) ,newSym);
	// add 3Ac code for string declaration 
	std::IR_code * string_decl = new std::IR_code("STRING_DECL", *$2, "", *$4, temp_counter);
	if (in_function == false){
		// if declaration is not in function, add to IR_vector
		IR_vector.push_back(string_decl);
	}
	else{
		// increment link_counter to add space for local vars in activation block
		link_counter = link_counter + 1;
	}
	// set if string is declared inside function
	func_var_map[*$2] = in_function;
	//IR_vector.push_back(string_decl);
};

str:TOKEN_STRINGLITERAL {
		$$ = yylval.str; 	// set string value
	};

var_decl:	var_type id_list TOKEN_OP_SEMIC {
	std::string s_type = "";
	// itereate over variables in id_list
	for(int i = $2 -> size() -1; i >= 0; i--){
		// if decl variable is inside function, decrement local_counter to access its stack position
		if (in_function == true)
		{
			//decrement
			local_counter = local_counter - 1; 
		}
		// create new symbol obj for this var
		std::Symbol * newSym = new std::Symbol((*$2)[i], NULL, $1, local_counter);
		//for debugging
		cout << ";" <<  *( (*$2)[i] ) << " the local counter: " << local_counter <<endl;
		// insert record in current scope table  / symbol table
		SymTabHead.back() -> insert_record(*( (*$2)[i] ) , newSym);
		// set if var is declared inside function
		func_var_map[*( (*$2)[i] )] = in_function;
		// if variable is of type of INT,  else FLOAT
		if($1 == TOKEN_INT){
			// set type as INT_DECL
			s_type = "INT_DECL";
		}
		else if($1 == TOKEN_FLOAT){
			// set type as FLOAT_DECL
			s_type = "FLOAT_DECL";
		}
		// add 3Ac code for variable declaration 
		std::IR_code * string_decl = new std::IR_code(s_type, *( (*$2)[i] ), "", "", temp_counter);
		if (in_function == false){
			// if declaration is not in function, add to IR_vector
			IR_vector.push_back(string_decl);
		}
		else{
			// increment link_counter to add space for local vars in activation block
			link_counter = link_counter + 1;
		}
		//IR_vector.push_back(string_decl);
	}
};

var_type:	TOKEN_FLOAT {
			$$ = TOKEN_FLOAT; // set as FLOAT var
		}
		|	TOKEN_INT{
			$$ = TOKEN_INT;  // set as INT var
		};

any_type:	var_type {
		$$ = $1;  // return value from var_type (INT / FLOAT)
	}
	|	TOKEN_VOID {
		$$ = TOKEN_VOID; // return VOID
	};

id_list:	id id_tail{
			$$ = $2;  // set the cur id_list as id_list we got from traversing id_tail recursively
			$$ -> push_back($1); // push back id value at this node to id_list
		}

id_tail:	TOKEN_OP_COMMA id id_tail { 
			$$ = $3; // set the cur id_list as id_list we got from traversing id_tail recursively
			$$ -> push_back($2); // push back id value at this node to id_list
		} 
		|	{
			// when we reach at end of recursion, initiate the id_tail with empty vector
			std::vector<std::string*>* temp = new std::vector<std::string*>; $$ = temp; 
		};

//grammar for parameters list
param_decl_list:	param_decl param_decl_tail{}
				|	;

param_decl:	var_type id{
	// create new symbol for paramenter var
	std::Symbol * newSym = new std::Symbol($2, NULL, $1, ++param_counter);
	// update symbol table 
	SymTabHead.back() -> insert_record(*($2) , newSym);
	// set if string is declared inside function
	func_var_map[*($2)] = in_function;
};

// grammar for declaration of multiple parameter 
param_decl_tail:	TOKEN_OP_COMMA param_decl param_decl_tail{}
				|	;

// grammar for declaration of multiple functions
func_declarations:   func_decl func_declarations{}
				|	;

// grammar for single function declaration
func_decl:	TOKEN_FUNCTION any_type id {
		//add function scope
		std::Scope * funcScope = new std::Scope(*$3);
		// update symbol table with new scope
		SymTabHead.push_back(funcScope);
		//add label name for function
		std::IR_code *func_code = new std::IR_code("LABEL", "", "", *$3, temp_counter);
		IR_vector.push_back(func_code); // push to 3AC to IR_vector
		in_function = true; // set in_function = true
		if($2 == TOKEN_INT){
			// if return type of funct is INT, update func_type_map with true
			func_type_map[*($3)] = true;
		}
		else{
			// else set false
			func_type_map[*($3)] = false;
		}
	}
	TOKEN_OP_LP {
		param_counter = 1;  //set parameter counter = 1 
		local_counter = 0;  //set local_counter = 0;
	} param_decl_list TOKEN_OP_RP TOKEN_BEGIN func_body TOKEN_END { 
		// set in_function as false
		in_function = false;
	};

// grammar for func body decl
func_body:	{ 
		link_counter = 1; //set link_counter to 1
	}
	decl {
		// set variable for linking in activation block of this funct
		std::string link_counter_str = std::to_string(static_cast<long long>(link_counter));
		// create 3AC  
		std::IR_code *link_code = new std::IR_code("LINK", link_counter_str, "", "", link_counter);
		// add 3AC in IR_vector
		IR_vector.push_back(link_code);
	} 
	stmt_list{};

// grammar for multiple statements
stmt_list:	stmt stmt_list{};
		|

// grammar for single statement
stmt:		base_stmt{} // simple statement
		|	if_stmt{} // if statment
		|	for_stmt{}; // for loop statement

// base statements
base_stmt:	assign_stmt{} // statement for assigning
		|	read_stmt{} // read command
		|	write_stmt{} // write command 
		|	return_stmt{}; // return command

assign_stmt:	assign_expr TOKEN_OP_SEMIC{
	/*print the 3 address code to vector*/
	if(($1->get_right_node())->get_int_or_float() == ($1->get_left_node())->get_int_or_float()){
		if(($1->get_right_node())->get_int_or_float() == true){		// return true of its int 
			//cout << "assign to int" <<endl;
			std::string temp_counter_str = std::to_string(static_cast<long long>(temp_counter));	// convert temp_coutner to string
			std::string s = temp_name + temp_counter_str;	// join it with temp_name
			if(($1->get_right_node())->get_node_type() == name_value){	
				s = ($1->get_right_node())->get_name(); // assign s to name of AST_node
			}
			// create 3AC for STOREI of this variable
			std::IR_code * assign_int = new IR_code("STOREI", s, "", (($1->get_left_node())->get_name()), temp_counter);
			// add 3AC to IR_vector
			IR_vector.push_back(assign_int);
		}
		else if(($1->get_right_node())->get_int_or_float() == false){	// if var is not int
			std::string temp_counter_str = std::to_string(static_cast<long long>(temp_counter));	// convert temp_counter to string
			std::string s = temp_name + temp_counter_str;	// join it with temp_name
			if(($1->get_right_node())->get_node_type() == name_value){
				s = ($1->get_right_node())->get_name();		// assign s to name of AST_node
			}
			// create STOREF 3AC for this var
			std::IR_code * assign_float = new IR_code("STOREF", s, "", (($1->get_left_node())->get_name()), temp_counter);
			IR_vector.push_back(assign_float);	// add 3AC to IR_vector
		}
	}
	else{
		// type error
	}
};

assign_expr: id TOKEN_OP_NE expr {
	// create new node for ASSIGN expression
	std::ASTNode * assign_node = new ASTNode();
	assign_node->change_node_type(operator_value);	// change it node type to operator_value
	assign_node->change_operation_type(TOKEN_OP_NE);	// change operation type to TOKEN_OP_NE
	//create the id node
	std::ASTNode * id_node = new ASTNode();
	id_node -> change_node_type(name_value);	// set type to name_value
	std::string s = *($1);	// name of variable being assigned

	//id_node -> add_name(*($1));
	//find out the type of the id by looking up the symbol table need to use for loop later
	int temp;
	if (func_var_map[*($1)])		// if the var is already present
	{
		temp = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[*($1)] -> get_type() ); // get type of variable
		id_node -> change_int_or_float(temp == TOKEN_INT);	// if INT , set true else false

		int stack_num = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[s] -> get_stack_pointer() ); // get stack position
		std::string stack_label = std::to_string(static_cast<long long>(stack_num));	 // convert it to string
		s = stack_sign + stack_label;	// concatate with stack_sign
		id_node -> add_name(s); // set name of id_node
	}
	else{	// new variable
		temp = ( (SymTabHead.front()->get_tab())[*($1)] -> get_type() );	// get type of var
		id_node -> change_int_or_float(temp == TOKEN_INT);	// set true of INT else false
		id_node -> add_name(s);	// set name of id_node
	}
	//int temp = ( (SymTabHead.front()->get_tab())[*($1)] -> get_type() );
	id_node -> change_int_or_float(temp == TOKEN_INT); // set int_or_float value (true / false)
	assign_node -> add_left_child(id_node);	// assign left child
	assign_node -> add_right_child($3);	// assign right child
	assign_node->change_int_or_float((temp == TOKEN_INT)); // set value of int_or_float for node

	//set the assign_expr type
	$$ = assign_node;
};

read_stmt:		TOKEN_READ TOKEN_OP_LP id_list TOKEN_OP_RP TOKEN_OP_SEMIC{
	// iterate over id_list in reverse order
	for(int i = ($3->size()) - 1; i >= 0; --i){
		std::string s_type = "";
		//need to check the scope use loop later
		if(func_var_map[*( (*$3)[i] )]){
			if((SymTabHead[SymTabHead.size() - 1]->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_INT){  // if var is of type INT
				s_type = "READI";	 // if INT, set READI
			}
			else if((SymTabHead[SymTabHead.size() - 1]->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_FLOAT){ // if var is of type FLOAT
				s_type = "READF";	// if FLOAT, set READF
			}
		}
		else{
			if((SymTabHead.front()->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_INT){// if var is of type INT
				s_type = "READI";// if INT, set READI
			}
			else if((SymTabHead.front()->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_FLOAT){// if var is of type FLOAT
				s_type = "READF";// if FLOAT, set READF
			}
		}
		/*if((SymTabHead.front()->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_INT){
			s_type = "READI";
		}
		else if((SymTabHead.front()->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_FLOAT){
			s_type = "READF";
		}*/
		std::string s = *( (*$3)[i] );	 // store var name in string s
		if (func_var_map[s])	// if var name is already mapped
		{
			int stack_num = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[s] -> get_stack_pointer() ); // get stack position of that var
			std::string stack_label = std::to_string(static_cast<long long>(stack_num));	// convert it to string
			s = stack_sign + stack_label;	// join it with stack_sign
		}
		// create 3AC for READ
		std::IR_code * read_code = new IR_code(s_type, "", "", s, temp_counter);
		IR_vector.push_back(read_code); // push it in IR_vector
	}
};

write_stmt:		TOKEN_WRITE TOKEN_OP_LP id_list TOKEN_OP_RP TOKEN_OP_SEMIC{
	// iterate over id_list in reverse order
	for(int i = ($3->size()) - 1; i >= 0; --i){
		std::string s_type = "";
		//need to check the scope use loop later
		if(func_var_map[*( (*$3)[i] )]){	 // if var is already declared in this function
			if((SymTabHead[SymTabHead.size() - 1]->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_INT){
				s_type = "WRITEI";	 // if var is of type INT
			}
			else if((SymTabHead[SymTabHead.size() - 1]->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_FLOAT){
				s_type = "WRITEF";	 // if var is of type FLOAT
			}
			else if((SymTabHead[SymTabHead.size() - 1]->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_STRING){
				s_type = "WRITES";	// if var is of type STRING
			}
		}
		else{
			if((SymTabHead.front()->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_INT){
				s_type = "WRITEI";	 //if var is of type INT
			}
			else if((SymTabHead.front()->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_FLOAT){
				s_type = "WRITEF";	// if var is of type FLOAT
			}
			else if((SymTabHead.front()->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_STRING){
				s_type = "WRITES";	// var type as STRING
			}
		}
		/*if((SymTabHead.front()->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_INT){
			s_type = "WRITEI";
		}
		else if((SymTabHead.front()->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_FLOAT){
			s_type = "WRITEF";
		}
		else if((SymTabHead.front()->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_STRING){
			s_type = "WRITES";
		}*/
		std::string s = *( (*$3)[i] );	// take var name in s
		if (func_var_map[s]) // if var is decl in this function , 
		{
			int stack_num = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[s] -> get_stack_pointer() ); // get position of stack 
			std::string stack_label = std::to_string(static_cast<long long>(stack_num));	// convert to string
			s = stack_sign + stack_label;	// join with stack_sign
		}
		// create 3AC for WRITE
		std::IR_code * write_code = new IR_code(s_type, s, "", "", temp_counter);
		IR_vector.push_back(write_code);	// add it to IR_vector
	}
};

return_stmt:	TOKEN_RETURN expr TOKEN_OP_SEMIC{
	//need to store the expr onto stack
	std::string return_name = ""; // return var name
	std::string data_type = "";	// STOREI / STOREF
	std::string dest = "";	// destinaton for return value
	if ($2->get_node_type() == name_value){
		return_name = $2->get_name();	// if node type is name_value, set return_name as node id
	}
	else{
		// else assign a new temp variable to return value
		std::string temp_counter_str = std::to_string(static_cast<long long>(temp_counter));	// convert to string
		return_name = temp_name + temp_counter_str; // join with temp_name
	}
	if ($2->get_int_or_float()){ // if INT, use STOREI
		data_type = "STOREI";
	}
	else{
		data_type = "STOREF"; // else use STOREF for FLOAT
	}
	// increment parameter counter and convert it to string
	std::string param_counter_str = std::to_string(static_cast<long long>(param_counter+1));
	dest = stack_sign + param_counter_str; // join with stack_sign
	// create 3AC for STORE operation
	std::IR_code * ret_addr = new IR_code(data_type, return_name, "", dest, temp_counter);
	IR_vector.push_back(ret_addr);	// add it to IR_vector
	// before returning,  unlink command 
	std::IR_code * unlink_code = new IR_code("UNLINK", "", "", "", temp_counter);
	IR_vector.push_back(unlink_code); // add 3AC for unlink in IR_vector
	// 3AC for returning from current function
	std::IR_code * return_code = new IR_code("RET", "", "", "", temp_counter);
	IR_vector.push_back(return_code); // push to IR_vector
};

// grammar for expression
expr: expr_prefix factor{
		//cout << "counting add/sub times*********" <<endl;
		if ($1 == NULL){
			$$ = $2;
			//cout << "EXPR with only facto: " << $2->get_temp_count() <<endl;
			//cout << temp_counter <<endl;
		}
		else{
			std::string s_op1 = "";	 // op1
			std::string s_op2 = "" ; // op2
			std::string s_result = "" ; // dest operand
			std::string s_type = "" ;	// operation type
			if($1->get_int_or_float() == $2->get_int_or_float()){ // if both var types match
				$1 -> add_right_child($2); // assign right child to expr_prefix node
				if($1->get_int_or_float()){	 // if var type is int
					//int op
					if($1->get_operation_type() == TOKEN_OP_PLUS){
						s_type = "ADDI";	 // ADDI for int if (operation = add)
					}
					else if($1->get_operation_type() == TOKEN_OP_MINS){
						s_type = "SUBI"; // SUBI for int if (operation = sub)
					}
				}
				else{
					//float op
					if($1->get_operation_type() == TOKEN_OP_PLUS){
						s_type = "ADDF"; // ADDF for float if (operation = add)
					}
					else if($1->get_operation_type() == TOKEN_OP_MINS){
						s_type = "SUBF"; // SUBF for float if (operation = sub)
					}
				}
				//set op1
				if(($1->get_left_node())->get_node_type() == name_value){
					s_op1 = ($1->get_left_node())->get_name(); // if left nodes type is of name_value, set value for op1 from left node
				}
				else{
					s_op1 = ($1->get_left_node())->get_temp_count(); // else assign new temp var
				}
				//set op2
				if(($1->get_right_node())->get_node_type() == name_value){
					s_op2 = ($1->get_right_node())->get_name(); // if right nodes type is of name_value, set value for op1 from right node
				}
				else{
					s_op2 = ($1->get_right_node())->get_temp_count();	 // else assign new temp var
				}
				std::string temp_counter_str = std::to_string(static_cast<long long>(++temp_counter));	 // get temp_counter in string
				s_result = temp_name + temp_counter_str; // join it with temp_name
				//set the temp counter in node factor
				$1->change_temp_count(s_result);
				// create 3AC for above operation (add / sub)
				std::IR_code * add_code = new IR_code(s_type, s_op1, s_op2, s_result, temp_counter);
				IR_vector.push_back(add_code); // push to IR_vector
				//cout << "if factor called " << $1->get_temp_count() << endl;
			}
			else{
				//wrong type (op1 and op2 should contain same var type)
			}
		$$ = $1;	// return expr_prefix
	}
};

// grammar for expr_prefix
expr_prefix:	expr_prefix factor addop{
		if($1 == NULL){
			// if expr_prefix is null, add factor as left child of addop node
			$3 -> add_left_child($2);
			$3 -> change_int_or_float($2->get_int_or_float());	 // set int_or_float value for addop node
		}
		else{
			//$1 -> add_right_child($2);
			//$3 -> add_left_child($1);
			std::string s_op1 = "";// op1
			std::string s_op2 = "" ;// op2
			std::string s_result = "" ;// dest operand
			std::string s_type = "" ;// operation type
			if($1->get_int_or_float() == $2->get_int_or_float()){	// if both var types match
					$1 -> add_right_child($2);	// assign right child to expr_prefix node
					$3 -> add_left_child($1);	// assign left child
					$3 -> change_int_or_float($1->get_int_or_float());	 // set int / float value

					if($1->get_int_or_float()){
						//int op
						if($1->get_operation_type() == TOKEN_OP_PLUS){
							s_type = "ADDI"; // ADDI for int if (operation = add)
						}
						else if($1->get_operation_type() == TOKEN_OP_MINS){
							s_type = "SUBI"; // SUBI for int if (operation = sub)
						}
					}
					else{
						//float op
						if($1->get_operation_type() == TOKEN_OP_PLUS){
							s_type = "ADDF";	 // ADDF for float
						}
						else if($1->get_operation_type() == TOKEN_OP_MINS){
							s_type = "SUBF";	// SUBF for float
						}
					}

					if(($1->get_left_node())->get_node_type() == name_value){	 // if left nodes type is of name_value, set value for op1 from left node
						s_op1 = ($1->get_left_node())->get_name();	 // set op1 name
					}
					else{
						s_op1 = ($1->get_left_node())->get_temp_count(); // else set new temp var for op1
						//cout << "test factor_prefix op1 " << s_type << " temp: " << s_op1 <<endl;
					}
					if(($1->get_right_node())->get_node_type() == name_value){
						s_op2 = ($1->get_right_node())->get_name();	 // set op2 name of name_value is equal to right node type
					}
					else{
						s_op2 = ($1->get_right_node())->get_temp_count();	// else set temp var for op2
						//cout << "test factor_prefix op2 " << s_type << " temp: " << s_op2 <<endl;
					}
					std::string temp_counter_str = std::to_string(static_cast<long long>(++temp_counter)); // get new temp value and cast it to string
					s_result = temp_name + temp_counter_str;	// join with temp_name
					//set the temp counter in node factor
					$1->change_temp_count(s_result);
					std::IR_code * add_code = new IR_code(s_type, s_op1, s_op2, s_result, temp_counter); // create 3AC for above operation
					IR_vector.push_back(add_code);	// push to IR_vector

			}
			else{
				//return error cant add int with float
			}
		}
		$$ = $3;
		// return addop node
	}
	|	{
		$$ = NULL;
};
// grammar for factor
factor:			factor_prefix postfix_expr{
	if ($1 == NULL){
		$$ = $2;	 // if factor_prefix is null, return postfix_expr
	}
	else{
		std::string s_op1 = "";	// op1
		std::string s_op2 = "" ; // op2
		std::string s_result = "" ;	// dest operand
		std::string s_type = "" ;	// operation type
		if($1->get_int_or_float() == $2->get_int_or_float()){ // if both var are of same type
			$1 -> add_right_child($2);	// assign right child for factor_prefix
			if($1->get_int_or_float()){
				//int op
				if($1->get_operation_type() == TOKEN_OP_STAR){
					s_type = "MULI";	// mult for INT type
				}
				else if($1->get_operation_type() == TOKEN_OP_SLASH){
					s_type = "DIVI";	// division for INT type
				}
			}
			else{
				//float op
				if($1->get_operation_type() == TOKEN_OP_STAR){
					s_type = "MULF"; 	// mult for FLOAT type
				}
				else if($1->get_operation_type() == TOKEN_OP_SLASH){
					s_type = "DIVF";	// division for FLOAT type
				}
			}
			//set op1
			if(($1->get_left_node())->get_node_type() == name_value){ 
				s_op1 = ($1->get_left_node())->get_name(); // if name_value is same as node type, set name for op1
			}
			else{
				s_op1 = ($1->get_left_node())->get_temp_count();	// else set new temp var
			}
			//set op2
			if(($1->get_right_node())->get_node_type() == name_value){
				s_op2 = ($1->get_right_node())->get_name();	// if name_value is same as node type, set name for op1
			}
			else{
				s_op2 = ($1->get_right_node())->get_temp_count();	// else set new temp var
			}
			std::string temp_counter_str = std::to_string(static_cast<long long>(++temp_counter)); // get new temp var as string
			s_result = temp_name + temp_counter_str;	// join with temp_name
			//set the temp counter in node factor
			$1->change_temp_count(s_result);	// set temp count in node factor_prefix
			std::IR_code * factor_code = new IR_code(s_type, s_op1, s_op2, s_result, temp_counter); // create 3AC for above operation
			IR_vector.push_back(factor_code); // add it to IR_vector
			//cout << "if factor called " << $1->get_temp_count() << endl;
		}
		else{
			//wrong type
		}
		$$ = $1;
	}
};

//grammar for factor_prefix
factor_prefix:	factor_prefix postfix_expr mulop{
		if($1 == NULL){
			// assign left child for mulop node
			$3 -> add_left_child($2);
			//set the node int_or_float type
			$3->change_int_or_float($2->get_int_or_float());

		}
		else{
			if($1->get_int_or_float() == $2->get_int_or_float()){	 // if both var are of same type
				$1 -> add_right_child($2);	 // assign right child
				$3 -> add_left_child($1);    // assign left child
				$3 -> change_int_or_float($1->get_int_or_float());	 // set int or float type for mulop node 

				std::string s_op1 = ""; //op1
				std::string s_op2 = "" ;	// op2
				std::string s_result = "" ;	// dest operand
				std::string s_type = "" ;	// operation type

				if($1->get_int_or_float()){	 // if var type is of INT
					//int op
					if($1->get_operation_type() == TOKEN_OP_STAR){
						s_type = "MULI"; // mult for INT type
					}
					else if($1->get_operation_type() == TOKEN_OP_SLASH){
						s_type = "DIVI"; // div for INT type
					}
				}
				else{
					//float op
					if($1->get_operation_type() == TOKEN_OP_STAR){
						s_type = "MULF";	// mult for FLOAT type
					}
					else if($1->get_operation_type() == TOKEN_OP_SLASH){
						s_type = "DIVF";	// div for FLOAT type
					}
				}

				if(($1->get_left_node())->get_node_type() == name_value){	// if name_value is same as left node_type 
					s_op1 = ($1->get_left_node())->get_name(); // set value for op1
				}
				else{
					s_op1 = ($1->get_left_node())->get_temp_count(); // set new temp var to op1
					//cout << "test factor_prefix op1 " << s_type << " temp: " << s_op1 <<endl;
				}
				if(($1->get_right_node())->get_node_type() == name_value){ // if name_value is same as right node_value
					s_op2 = ($1->get_right_node())->get_name();	// set value for op2
				}
				else{
					s_op2 = ($1->get_right_node())->get_temp_count();	// set new temp var to op2
					//cout << "test factor_prefix op2 " << s_type << " temp: " << s_op2 <<endl;
				}
				std::string temp_counter_str = std::to_string(static_cast<long long>(++temp_counter));	// get new temp var as string
				s_result = temp_name + temp_counter_str;	// join it with temp_name
				//set the temp counter in node factor
				$1->change_temp_count(s_result);	// set temp_count of factor_prefix node
				std::IR_code * factor_code = new IR_code(s_type, s_op1, s_op2, s_result, temp_counter);	// generate 3AC for above op
				IR_vector.push_back(factor_code);	// add it to IR_vector

			}
			else{
				//return error cant add int with float
			}
		}
		$$ = $3;
		//try to add IR code
	}
	|	{
		$$ = NULL;
};

// grammar for postfix_expr
postfix_expr:	
	primary{$$=$1;}	 // set corresponding child nodes
	|	call_expr{$$=$1;};

call_expr:	id TOKEN_OP_LP expr_list TOKEN_OP_RP {
	// create 3AC for PUSH and PUSHREG 
	std::IR_code * push_code = new IR_code("PUSH", "", "", "", temp_counter);
	std::IR_code * push_reg = new IR_code("PUSHREG", "", "", "", temp_counter);
	IR_vector.push_back(push_reg); // add 3AC to IR_vector
	IR_vector.push_back(push_code);	// add 3AC to IR_vector
	std::string s = "";
	// iterate over expression list of function
	for (int x = 0; x < $3->size(); x++)
	{
		if ((*$3)[x] -> get_node_type() == name_value) // if var is already declared, 
		{
			s = (*$3)[x] -> get_name();	// get name and store in variable s
		}
		else{
			//int temp_num = (*$3)[x-1] -> get_temp_count();
			//std::string temp_counter_str = std::to_string(static_cast<long long>(temp_num));
			s = (*$3)[x] -> get_temp_count(); // else decl new temp var 
		}
		// 3AC for pushing this value in activation block
		std::IR_code * push_para = new IR_code("PUSH", "", "", s, temp_counter);
		IR_vector.push_back(push_para);	// push this 3AC in IR_vector
	}
	//need to push the result of expr_list
	std::IR_code * jump_func = new IR_code("JSR", "", "", *$1, temp_counter);
	IR_vector.push_back(jump_func); // add 3AC for jump instruction to called function
	std::IR_code * pop_code = new IR_code("POP", "", "", "", temp_counter); // pop the space allocated for return value
	std::IR_code * pop_reg = new IR_code("POPREG", "", "", "", temp_counter);	// pop pushed registers

	IR_vector.push_back(pop_code); // add 3AC in IR_vector
	for (int x = 0; x < $3->size()-1; x++)
	{
		std::IR_code * pop_para = new IR_code("POP", "", "", "", temp_counter);	 // pop all arguments to function
		IR_vector.push_back(pop_para);	// add 3AC in IR_vector
	}
	std::string temp_counter_str = std::to_string(static_cast<long long>(++temp_counter)); // get new temp var in form of string
	s = temp_name + temp_counter_str;	// join it with temp_name
	std::IR_code * pop_ret = new IR_code("POP", "", "", s, temp_counter); // get return value using pop in temp var
	IR_vector.push_back(pop_ret);	 // add 3AC in IR_vector
	IR_vector.push_back(pop_reg);	// add 3AC in IR_vector
	//need to pop the result of function into an temp
	//and store the temp into the call_expr node with the type of the function
	std::ASTNode * caller_node = new ASTNode();
	caller_node -> change_node_type(name_value); // change node type to name_value
	caller_node -> add_name(s);	 // assign name to node
	caller_node -> change_int_or_float(func_type_map[*($1)]); // true of type is of INT else false
	$$ = caller_node;	// assign caller_node
};

expr_list:		expr expr_list_tail{
	//cout << $1->get_name() << "-------------" <<endl;
	//std::IR_code * push_code = new IR_code("PUSH", "", "", s, temp_counter);
	$$ = $2;	// set expr_list_tail vector as current vector
	$$ -> push_back($1);	// add expr in current vector of expressions
}
|	{ 
	// initiate empty vector and pass it upword ( up the tree )
	std::vector<std::ASTNode*>* temp = new std::vector<std::ASTNode*>; 
	$$ = temp;
};

expr_list_tail:	TOKEN_OP_COMMA expr expr_list_tail{
	$$ = $3;	// set expr_list_tail recursively
	/*add the expr to the expr vector*/
	$$ -> push_back($2);
}
|	{ 
	// initiate empty vector
	std::vector<std::ASTNode*>* temp = new std::vector<std::ASTNode*>; 
	$$ = temp; // pass it upward
};

primary: TOKEN_OP_LP expr TOKEN_OP_RP {
		$$=$2; 
	}
|	id {
	std::ASTNode * id_node = new ASTNode();	// create astnode
	id_node -> change_node_type(name_value);	// assign node type
	//id_node -> add_name(*($1));
	std::string s = (*($1));	// get temp var name of expr
	if(func_var_map[*($1)] == true){ // if already declared in cur function
		int stack_num = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[s] -> get_stack_pointer() );	// get stack position of var
		std::string stack_label = std::to_string(static_cast<long long>(stack_num));	// convert it to string
		s = stack_sign + stack_label; // join with stack_sign
		id_node -> add_name(s);	// set name of id_node
		//cout << "the primary: " << *$1 <<endl;
		//cout << "the size of the scope: " << SymTabHead.size() <<endl;
		//cout << (SymTabHead[SymTabHead.size() - 1]->get_tab())[*($1)] -> get_type() <<endl;
		int temp = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[*($1)] -> get_type() ); // get type of var (int / float)
		id_node -> change_int_or_float(temp == TOKEN_INT); // set type in id_node
	}
	else{
		int temp = ( (SymTabHead.front()->get_tab())[*($1)] -> get_type() ); // get var name
		id_node -> change_int_or_float(temp == TOKEN_INT);	// set id_node type (int / float)
		id_node -> add_name(s);	// set name of id_node
	}
	// set id_node and pass it upward the tree
	$$ = id_node;	
}
|	TOKEN_INTLITERAL {
	//AST node
	std::ASTNode * int_node = new ASTNode();
	int_node -> change_node_type(int_value); // change type INT
	int_node -> add_value(*(yylval.str));	 // set value of INT var
	int_node -> change_int_or_float(true);	// int_or_float to true
	$$ = int_node; // set node to return
	//try to store IR_code
	std::string temp_counter_str = std::to_string(static_cast<long long>(++temp_counter)); // get new temp var
	std::string s = temp_name + temp_counter_str;	// join it with temp_name
	std::IR_code * int_code = new IR_code("STOREI", *(yylval.str), "", s , temp_counter); // create 3AC for STOREI
	int_node -> change_temp_count(s);	// set tempcount of int_node
	IR_vector.push_back(int_code);	// push 3AC to IR_vector
}
|	TOKEN_FLOATLITERAL{
	//AST node
	std::ASTNode * float_node = new ASTNode();
	float_node -> change_node_type(float_value);	 // change type FLOAT
	float_node -> add_value(*(yylval.str));		// set value of FLOAT var
	float_node -> change_int_or_float(false);	// set int_or_float as false
	//cout << float_node -> get_value() << " this is f value" << endl;
	$$ = float_node; // set node to return
	//try to store IR_code
	std::string temp_counter_str = std::to_string(static_cast<long long>(++temp_counter)); // get new temp var
	std::string s = temp_name + temp_counter_str;	 // join it with temp_name
	std::IR_code * float_code = new IR_code("STOREF", *(yylval.str), "", s, temp_counter );	// create 3AC for STOREF
	//set the temp counter
	float_node -> change_temp_count(s);	// set tempcount of float_node
	IR_vector.push_back(float_code);	// push 3AC in IR_vector
};

//create ost node for add / sub
addop:	TOKEN_OP_PLUS {
	std::ASTNode * op_node = new ASTNode();	 // create ast node
	op_node -> change_node_type(operator_value);	// change node type to operator_value
	op_node -> change_operation_type(TOKEN_OP_PLUS);	// set operation type
	$$ = op_node; // set op_node
}
	|	TOKEN_OP_MINS{
	std::ASTNode * op_node = new ASTNode();// create ast node
	op_node -> change_node_type(operator_value);// change node type to operator_value
	op_node -> change_operation_type(TOKEN_OP_MINS);// set operation type
	$$ = op_node; // set op_node
};
//create ost node for mult / div
mulop:	TOKEN_OP_STAR{
	std::ASTNode * op_node = new ASTNode();// create ast node
	op_node -> change_node_type(operator_value);// change node type to operator_value
	op_node -> change_operation_type(TOKEN_OP_STAR);// set operation type
	$$ = op_node;// set op_node
}
|	TOKEN_OP_SLASH{
	std::ASTNode * op_node = new ASTNode();// create ast node
	op_node -> change_node_type(operator_value);// change node type to operator_value
	op_node -> change_operation_type(TOKEN_OP_SLASH);// set operation type
	$$ = op_node;// set op_node
};

if_stmt: TOKEN_IF {
	//add if block
	label_num = label_num + 2;	// increment label by 2
	label_counter.push(label_num - 1);	// push label in label counter
} TOKEN_OP_LP cond TOKEN_OP_RP decl stmt_list {	
	// get label from label_counter
	std::string jump_label = std::to_string(static_cast<long long>(label_counter.top()+1));
	// convert it to string and join with lable_name
	std::string jump_s = lable_name + jump_label;
	//create 3AC for JUMP
	std::IR_code * jump_IR = new IR_code("JUMP", "", "", jump_s, temp_counter);
	IR_vector.push_back(jump_IR); // add 3AC to IR_vector
	//label for the beginning of the else
	std::string else_label = std::to_string(static_cast<long long>(label_counter.top()));
	std::string else_s = lable_name + else_label; // join with label_name
	// create 3AC for LABEL
	std::IR_code * else_IR = new IR_code("LABEL", "", "", else_s, temp_counter);
	IR_vector.push_back(else_IR); // add 3AC to IR_vector
} else_part TOKEN_FI{
	// get token for end of IF
	std::string end_label = std::to_string(static_cast<long long>(label_counter.top()+1));
	std::string end_s = lable_name + end_label;	 // join with label_name
	// create 3AC for this label
	std::IR_code * end_IR = new IR_code("LABEL", "", "", end_s, temp_counter);
	IR_vector.push_back(end_IR);	 // add 3AC to IR_vector
	label_counter.pop(); // remove this label from label counter
};

// grammar for else part
else_part:	TOKEN_ELSE {
	//add else block
} decl stmt_list{}
			|	;

// grammar for conditional statement in if / for
cond:	expr compop expr {
	std::string compop_str = "";
	switch($2){
		case TOKEN_OP_LESS:
			compop_str = "GE"; // take >= operator for < in condition
			break;
		case TOKEN_OP_GREATER:
			compop_str = "LE"; // take <= operator for > in condition
			break;
		case TOKEN_OP_EQ:
			compop_str = "NE";	// take != operator for = in condition
			break;
		case TOKEN_OP_NEQ:
			compop_str = "EQ";	// take = operator for != in condition
			break;
		case TOKEN_OP_LE:
			compop_str = "GT";	// take > operator for <= in condition
			break;
		case TOKEN_OP_GE:
			compop_str = "LT";	// take < operator for >= in condition
			break;
	}
	std::string s1 = "";	// var1
	std::string s2 = "";	// var2
	int cmp_type = 0;
	if($1->get_int_or_float() == $3->get_int_or_float()){	 // if var types are same
		if($1->get_node_type() == name_value){ // if name_value is equal to node type
			s1 = $1->get_name();	// get name of var1 in s1
			if (func_var_map[s1]) // if var is declared in current function
			{
				// take stack position of var
				int stack_num = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[s1] -> get_stack_pointer() );
				// convert it to string
				std::string stack_label = std::to_string(static_cast<long long>(stack_num));
				// join with stack_sign
				s1 = stack_sign + stack_label;
			}
		}
		else{
			s1 = $1->get_temp_count(); // else get new var name
		}
		if($3->get_node_type() == name_value){	// if name_value is equal to node type
			s2 = $3->get_name();	 // get name of var2 in s2
			if (func_var_map[s2])	// if var is declared in current function
			{
				// take stack position of var
				int stack_num = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[s2] -> get_stack_pointer() );
				// convert it to string
				std::string stack_label = std::to_string(static_cast<long long>(stack_num));
				// join with stack_sign
				s2 = stack_sign + stack_label;
			}
		}
		else{
			s2 = $3->get_temp_count();	// else get new var name
		}
		if($1->get_int_or_float() == true) {
			cmp_type = 0; // if comparison is between ints, set cmp_type = 0;
		}
		else if($1->get_int_or_float() == false) {
			cmp_type = 1;	// else if its between floats, set cmp_type = 1;
		}
	}
	else{
		//compare different type data ERROR
	}
	// get top label from label_counter
	std::string jump_label = std::to_string(static_cast<long long>(label_counter.top()));
	std::string jump_s = lable_name + jump_label;	 // join with label_name
	// create 3AC for this label
	std::IR_code * cond_IR = new IR_code(compop_str, s1, s2, jump_s, cmp_type);
	IR_vector.push_back(cond_IR);	// add 3AC to IR_vector

};

compop:	 TOKEN_OP_LESS{$$ = TOKEN_OP_LESS;}	 // return LESS for <
	|	TOKEN_OP_GREATER{$$ = TOKEN_OP_GREATER;}	// return GREATER for >
	|	TOKEN_OP_EQ{$$ = TOKEN_OP_EQ;}		// return EQ for =
	|	TOKEN_OP_NEQ{$$ = TOKEN_OP_NEQ;}	// return NEQ for !=
	|	TOKEN_OP_LE{$$ = TOKEN_OP_LE;}		// return LE for <=
	|	TOKEN_OP_GE{$$ = TOKEN_OP_GE;};		//return GE for >=

init_stmt:		assign_expr {
	if(($1->get_right_node())->get_int_or_float() == ($1->get_left_node())->get_int_or_float()){ // check if var types are same
		if(($1->get_right_node())->get_int_or_float() == true){ // if var type is INT	
			// get tempcounter in string format
			std::string temp_counter_str = std::to_string(static_cast<long long>(temp_counter));
			// join it with temp_name
			std::string s = temp_name + temp_counter_str;
			// if name_value is equal to right node type
			if(($1->get_right_node())->get_node_type() == name_value){
				s = ($1->get_right_node())->get_name();	 // get name of variable
			}
			// generate 3AC for STOREI
			std::IR_code * assign_int = new IR_code("STOREI", s, "", (($1->get_left_node())->get_name()), temp_counter);
			// add 3AC to IR_vector
			IR_vector.push_back(assign_int);
		}
		else if(($1->get_right_node())->get_int_or_float() == false){	// if var type is float
			// get tempcounter in string format
			std::string temp_counter_str = std::to_string(static_cast<long long>(temp_counter));
			// join it with temp_name
			std::string s = temp_name + temp_counter_str;
			// if name_value is same as right node type
			if(($1->get_right_node())->get_node_type() == name_value){
				s = ($1->get_right_node())->get_name();		// get var name
			}
			// create 3AC for STOREF
			std::IR_code * assign_float = new IR_code("STOREF", s, "", (($1->get_left_node())->get_name()), temp_counter);
			// add 3AC to IR_vector
			IR_vector.push_back(assign_float);
		}
	}
	else{
		//assign type error
	}
}
|	;

incr_stmt:		assign_expr {
	if(($1->get_right_node())->get_int_or_float() == ($1->get_left_node())->get_int_or_float()){	// if var types are equal
		if(($1->get_right_node())->get_int_or_float() == true){	 // if var type is INT
			// get tempcounter in string format
			std::string temp_counter_str = std::to_string(static_cast<long long>(temp_counter));
			// join it with temp_name
			std::string s = temp_name + temp_counter_str;
			// if name_value is equal to right node type
			if(($1->get_right_node())->get_node_type() == name_value){
				s = ($1->get_right_node())->get_name();	// get var name
			}
			// create 3AC for STOREI
			std::IR_code * assign_int = new IR_code("STOREI", s, "", (($1->get_left_node())->get_name()), temp_counter);
			// add 3AC to IR_vector
			IR_vector.push_back(assign_int);
		}
		else if(($1->get_right_node())->get_int_or_float() == false){ // if var type is FLOAT
			// get tempcounter in string format
			std::string temp_counter_str = std::to_string(static_cast<long long>(temp_counter));
			// join it with temp_name
			std::string s = temp_name + temp_counter_str;
			// if name_value is equal to right node type
			if(($1->get_right_node())->get_node_type() == name_value){
				s = ($1->get_right_node())->get_name();	// get var name
			}
			// create 3AC for STOREF
			std::IR_code * assign_float = new IR_code("STOREF", s, "", (($1->get_left_node())->get_name()), temp_counter);
			// add 3AC to IR_vector
			IR_vector.push_back(assign_float);
		}
	}
	else{
		//assign type error
	}
}
|	;

// grammar for for 
for_stmt:		TOKEN_FOR{
	//add for block
} TOKEN_OP_LP init_stmt TOKEN_OP_SEMIC {
	// initially increment lable_num by 2
	label_num = label_num + 2;
	// add label_num to label_counter
	label_counter.push(label_num);
	// get label in string format
	std::string label_counter_str = std::to_string(static_cast<long long>(label_counter.top() - 1));
	// join with label_name
	std::string label_s = lable_name + label_counter_str;
	// create 3AC for LABEL
	std::IR_code * label_IR = new IR_code("LABEL", "", "", label_s, temp_counter);
	// add 3AC to IR_vector
	IR_vector.push_back(label_IR);
	// create 3AC for FOR_START label
	std::IR_code * label_for = new IR_code("FOR_START", "", "", "", temp_counter);
	// add 3AC to IR_vector
	IR_vector.push_back(label_for);
} cond TOKEN_OP_SEMIC{
	/*start for the incr_stmt*/
	std::IR_code * incr = new IR_code("INCR_START", "", "", "", temp_counter);
	// add 3AC to IR_vector
	IR_vector.push_back(incr);
} incr_stmt {
	/*end for the incr_stmt*/
	std::IR_code * jump_code = new IR_code("INCR_END", "", "", "", temp_counter);
	// add 3AC to IR_vector
	IR_vector.push_back(jump_code);
} TOKEN_OP_RP decl stmt_list {
	/*end of the for loop*/
	std::IR_code * end_sig = new IR_code("FOR_END", "", "", "", label_counter.top());
	// add 3AC to IR_vector
	IR_vector.push_back(end_sig);
	// get label in string format
	std::string end_label = std::to_string(static_cast<long long>(label_counter.top()));
	// join with label_name
	std::string end_lable_s = lable_name + end_label;
	// create 3AC for LABEL
	std::IR_code * end_code = new IR_code("LABEL", "", "", end_lable_s, temp_counter);
	// add 3AC to IR_vector
	IR_vector.push_back(end_code);
	// pop label from label_counter
	label_counter.pop();
} TOKEN_ROF {};
%%
