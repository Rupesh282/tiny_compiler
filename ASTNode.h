/*
 * Acknowledgement: Qifan Chang and Zixian Lai 
 * acknowledgement for documentation : Abhishek Raj
 **/
#ifndef ASTNODE_H
#define ASTNODE_H
#include <string>
#include <utility>
#include <algorithm>
#include <map>
#include <vector>

namespace std{

	// enum for AST_Node_type
	enum AST_Node_type
	{
		undefinded,		// 0
		operator_value, // 1
		int_value,		// 2
		float_value,    // 3
		func_value,		// 4
		name_value		// 5
	};

	class ASTNode
	{
	private:
		AST_Node_type type;		// type of AST_Node
		ASTNode* left_node;		// left child for current node
		ASTNode* right_node;	// right child for current node
		string id_name;			// stores name of node 
		string temp_count;		// stores temp var count of current node

		int Operation_type;		// stores operation type of node
		bool int_or_float;		//int = true float = false
		string value;			// stores value of node (int / float)

    // description of below methods is present in ASTNode.cpp file
	public:
		ASTNode();
		virtual ~ASTNode();
		void change_node_type(AST_Node_type n_type);
		void change_operation_type(int op_type);
		void add_name(string name_string);
		void add_value(string var_value);
		string get_name();
		string get_value();
		void add_left_child(ASTNode* left);
		void add_right_child(ASTNode* right);
		ASTNode* get_left_node();
		ASTNode* get_right_node();
		AST_Node_type get_node_type();
		int get_operation_type();
		void change_int_or_float(bool set);
		bool get_int_or_float();
		void change_temp_count(string number);
		string get_temp_count();
	};
	class IR_code
	{
	private:
		string op_type_code; // stores op_type
		string op1_code; // op1
		string op2_code; // op2
		string result_code; // dest operand
		int reg_counter;  // register counter
    // description of below methods is present in ASTNode.cpp file
	public:
		IR_code(string op_type, string op1, string op2, string result, int counter);
		virtual ~IR_code();
		string get_op_type();
		string get_op1();
		string get_op2();
		string get_result();
		int get_reg_counter();
	};
}
#endif
