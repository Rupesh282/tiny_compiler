/*
 * Acknowledgement: Qifan Chang and Zixian Lai 
 * acknowledgement for documentation : Abhishek Raj
 **/
#include "ASTNode.h"

namespace std{
	ASTNode::ASTNode(){
		type = undefinded;			// initialize type as undifined	
		left_node = NULL;			// set left node to null
		right_node = NULL;			// set right node to null
		Operation_type = 0;			// operation type to 0
		value = "";					// value = "" (string format)
		id_name = "";				// var_name is empty
		int_or_float = true;		// by default set int_or_float to true (int type)
		temp_count = "";			// stores current new temp var 
	}

	ASTNode::~ASTNode(){
	}

	void ASTNode::change_node_type(AST_Node_type n_type){	// set AST_Node type
		type = n_type;
	}

	AST_Node_type ASTNode::get_node_type(){					// return AST_Node type
		return type;
	}

	void ASTNode::change_operation_type(int op_type){		// set operation type
		Operation_type = op_type;
	}

	int ASTNode::get_operation_type(){						// return operation type
		return Operation_type;
	}

	void ASTNode::add_name(string name_string){				// set id_name as name_string 
		id_name = name_string;
	}

	void ASTNode::add_value(string var_value){				// set value as var_value
		value = var_value;
	}

	string ASTNode::get_name(){								// return id_name
		return id_name;
	}

	string ASTNode::get_value(){							// return value
		return value;
	}

	void ASTNode::add_left_child(ASTNode* left){			// set left child of current node
		left_node = left;
	}

	void ASTNode::add_right_child(ASTNode* right){			// set right child of current node
		right_node = right;
	}

	ASTNode* ASTNode::get_left_node(){						// get left child of current node
		return left_node;
	}

	ASTNode* ASTNode::get_right_node(){						// get right child of current node
		return right_node;
	}

	void ASTNode::change_int_or_float(bool set){			// to change value of int_or_float
		int_or_float = set;
	}

	bool ASTNode::get_int_or_float(){						// return value of int_or_float
		return int_or_float;
	}

	void ASTNode::change_temp_count(string number){			// set temp_count as number 
		temp_count = number;
	}

	string ASTNode::get_temp_count(){						// return  temp count
		return temp_count;
	}

	IR_code::IR_code(string op_type, string op1, string op2, string result, int count){
		op_type_code = op_type;   		// set operation type
		op1_code = op1;					// set op1
		op2_code = op2;					// set op2
		result_code = result;			// set result code
		reg_counter = count;			// set register counter
	}
	IR_code::~IR_code(){

	}
	string IR_code::get_op_type(){		// return operation type
		return op_type_code;	
	}
	string IR_code::get_op1(){			// return op1 code
		return op1_code;
	}
	string IR_code::get_op2(){			// return op2 code		
		return op2_code;
	}
	string IR_code::get_result(){		// return result code
		return result_code;
	}
	int IR_code::get_reg_counter(){		// return reg counter
		return reg_counter;
	}


}
