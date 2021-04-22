/*
 * Acknowledgement: Qifan Chang and Zixian Lai 
 * acknowledgement for documentation : Abhishek Raj
 **/
#include "Tiny.h"

namespace std
{
	Tiny::Tiny(std::vector<std::IR_code *> IR_vector_in)
	{
		IR_vector = IR_vector_in;		// set IR_vector for current object
	}

	Tiny::~Tiny() {}

	void Tiny::genTiny()
	{
		std::stack<int> IR_ct_stack;	// for implementing FOR statements
		std::stack<std::string> label_stack;	// for managing labels
	//--------------------------generate assembly code-----------------------
		for (int i = 0; i < IR_vector.size(); i++)
		{
			// store current iterator 3AC code in curr3ac obj
			std::IR_code* curr3ac = IR_vector[i];
			// get op_type of current 3AC code
			string curr_op_type = IR_vector[i] -> get_op_type();
			// if op_type is INT_DECL
			if( curr_op_type == "INT_DECL"){
				cout << "var " << IR_vector[i] -> get_op1() << endl;	// print var declaration for global vars
			}
			// if op_type is FLOAT_DECL
			if( curr_op_type == "FLOAT_DECL"){
				cout << "var " << IR_vector[i] -> get_op1() << endl;	// print var declaration for global vars
			}
			// if op_type is STRING_DECL
			if( curr_op_type == "STRING_DECL"){
				cout << "str " << IR_vector[i] -> get_op1() << " " << IR_vector[i] -> get_result() << endl;	// print var declaration for global vars
			}

			// if op_type is ADDI
			else if( curr_op_type == "ADDI"){
				// move op2 to r0
				cout << "move " << curr3ac->get_op2() << " r0" << endl;
				// add op1 and r0, then store result in r0
				cout << "addi " << curr3ac->get_op1() << " r0" << endl;
				// store result of operation in result_op
				cout << "move r0 " << curr3ac->get_result() << endl;
			}

			// if op_type is SUBI
			else if( curr_op_type == "SUBI"){
				// move op1 to register r0
				cout << "move " << curr3ac->get_op1() << " r0" << endl;
				// assembly code for subi(subtract integers) operaion
				cout << "subi " << curr3ac->get_op2() << " r0" << endl;
				// store result of operation in result_op
				cout << "move r0 " << curr3ac->get_result() << endl;
			}

			// if op_type is MULI
			else if( curr_op_type == "MULI"){
				// move op2 to register r0
				cout << "move " << curr3ac->get_op2() << " r0" << endl;
				// assembly code for muli(multiply integers) operation
				cout << "muli " << curr3ac->get_op1() << " r0" << endl;
				// store result of operation in result_op
				cout << "move r0 " << curr3ac->get_result() << endl;
			}

			// if op_type is DIVI
			else if( curr_op_type == "DIVI"){
				// move op1 to register r0
				cout << "move " << curr3ac->get_op1() << " r0" << endl;
				// assembly code for divi(divide integers) operation
				cout << "divi " << curr3ac->get_op2() << " r0" << endl;
				// store result of operation in result_op
				cout << "move r0 " << curr3ac->get_result() << endl;
			}

			// if op_type is DIVI
			else if( curr_op_type == "ADDF"){
				// move op2 to register r0
				cout << "move " << curr3ac->get_op2() << " r0" << endl;
				// assembly code for addr(float addition) operation
				cout << "addr " << curr3ac->get_op1() << " r0" << endl;
				// store result of operation in result_op
				cout << "move r0 " << curr3ac->get_result() << endl;
			}

			// if op_type is SUBF
			else if( curr_op_type == "SUBF"){
				// move op1 to register r0
				cout << "move " << curr3ac->get_op1() << " r0" << endl;
				// assembly code for subr(float subtraction) opearation
				cout << "subr " << curr3ac->get_op2() << " r0" << endl;
				// store result of operation in result_op
				cout << "move r0 " << curr3ac->get_result() << endl;
			}

			// if op_type is MULF
			else if( curr_op_type == "MULF"){
				// move op2 to register r0
				cout << "move " << curr3ac->get_op2() << " r0" << endl;
				// assembly code for mulr(float multiplication) opearation
				cout << "mulr " << curr3ac->get_op1() << " r0" << endl;
				// store result of operation in result_op
				cout << "move r0 " << curr3ac->get_result() << endl;
			}

			// if op_type is DIVF
			else if( curr_op_type == "DIVF"){
				// move op1 to register r0
				cout << "move " << curr3ac->get_op1() << " r0" << endl;
				// assembly code for divr(float division) operation
				cout << "divr " << curr3ac->get_op2() << " r0" << endl;
				// store result of operation in result_op
				cout << "move r0 " << curr3ac->get_result() << endl;
			}

			// if op_type is LABEL
			else if( curr_op_type == "LABEL"){
				// if label is main, print 'label main'
				if (curr3ac -> get_op1() == "main") {
					cout << "label " << curr3ac -> get_op1() << endl;
				}
				else{
					// print label with label name (result_op)
					cout << "label " << curr3ac -> get_result() << endl;
					// if next 3AC code is for loop statement, then push current 3AC code's result_op in label_stack
					if (i + 1< IR_vector.size()){
						if (IR_vector[i+1] -> get_op_type() == "FOR_START"){label_stack.push(curr3ac -> get_result());}
					}
				}
			}

			// if op_type is JUMP
			else if( curr_op_type == "JUMP"){
				// print jmp statement for label
				cout << "jmp " << curr3ac->get_result() << endl;
			}

			// if op_type is FOR_START
			else if( curr_op_type == "FOR_START"){ 
				// do nothing
			}

			// if op_type is FOR_END
			else if( curr_op_type == "FOR_END"){
				int temp_i = i;
				// get top element of the IR_ct_stack
				i = IR_ct_stack.top();
				// pop the top element
				IR_ct_stack.pop();
				// push current iterator i value in the IR_ct_stack
				IR_ct_stack.push(temp_i);
				
			}

			// if op_type is INCR_START
			else if( curr_op_type == "INCR_START"){
				// push current iterator i value in the IR_ct_stack
				IR_ct_stack.push(i);
				int j = i;	// copy i value in j
				// increment j till op_type is INCR_END
				while(IR_vector[j]->get_op_type() != "INCR_END"){j++;}
				// update i value with j value
				i = j;
			}

			// if op_type is INCR_END
			else if( curr_op_type == "INCR_END"){
				// get top element from IR_ct_stack
				i = IR_ct_stack.top();
				// pop the top element from IR_ct_stack
				IR_ct_stack.pop();
				// print jmp statement for top label_stack element
				cout << "jmp " << label_stack.top() << endl;
				// pop top element from label_stack 
				label_stack.pop();
			}

			// if op_type is GT
			else if( curr_op_type == "GT"){
				// move op2 to register r0
				cout << "move " << curr3ac->get_op2() << " r0" << endl;
				if (curr3ac->get_reg_counter() == 1){
					//comparing float
					cout << "cmpr " << curr3ac->get_op1() << " r0" << endl;
				}
				else if (curr3ac->get_reg_counter() == 0){
					//comparing int
					cout << "cmpi " << curr3ac->get_op1() << " r0" << endl;
				}
				// jump to result_op if op1 > op2
				cout << "jgt " << curr3ac->get_result() << endl;
			}

			// if op_type is GE
			else if( curr_op_type == "GE"){
				// move op2 to register r0
				cout << "move " << curr3ac->get_op2() << " r0" << endl;
				if (curr3ac->get_reg_counter() == 1){
					//comparing float
					cout << "cmpr " << curr3ac->get_op1() << " r0" << endl;
				}
				else if (curr3ac->get_reg_counter() == 0){
					//comparing int
					cout << "cmpi " << curr3ac->get_op1() << " r0" << endl;
				}
				// jump to result_op if op1 >= op2
				cout << "jge " << curr3ac->get_result() << endl;
			}

			// if op_type is LT
			else if( curr_op_type == "LT"){
				// move op2 to register r0
				cout << "move " << curr3ac->get_op2() << " r0" << endl;
				if (curr3ac->get_reg_counter() == 1){
					//comparing float
					cout << "cmpr " << curr3ac->get_op1() << " r0" << endl;
				}
				else if (curr3ac->get_reg_counter() == 0){
					//comparing int
					cout << "cmpi " << curr3ac->get_op1() << " r0" << endl;
				}
				// jump to result_op if op1 < op2
				cout << "jlt " << curr3ac->get_result() << endl;
			}

			// if op_type is LE
			else if( curr_op_type == "LE"){
				// move op2 to register r0
				cout << "move " << curr3ac->get_op2() << " r0" << endl;
				if (curr3ac->get_reg_counter() == 1){
					//comparing float
					cout << "cmpr " << curr3ac->get_op1() << " r0" << endl;
				}
				else if (curr3ac->get_reg_counter() == 0){
					//comparing int
					cout << "cmpi " << curr3ac->get_op1() << " r0" << endl;
				}
				// jump to result_op if op1 <= op2
				cout << "jle " << curr3ac->get_result() << endl;
			}

			// if op_type is EQ
			else if( curr_op_type == "EQ"){
				// move op2 to register r0
				cout << "move " << curr3ac->get_op2() << " r0" << endl;
				if (curr3ac->get_reg_counter() == 1){
					//comparing float
					cout << "cmpr " << curr3ac->get_op1() << " r0" << endl;
				}
				else if (curr3ac->get_reg_counter() == 0){
					//comparing int
					cout << "cmpi " << curr3ac->get_op1() << " r0" << endl;
				}
				// jump to result_op if op1 = op2
				cout << "jeq " << curr3ac->get_result() << endl;
			}

			// if op_type is NE
			else if( curr_op_type == "NE"){
				// move op2 to register r0
				cout << "move " << curr3ac->get_op2() << " r0" << endl;
				if (curr3ac->get_reg_counter() == 1){
					//comparing float
					cout << "cmpr " << curr3ac->get_op1() << " r0" << endl;
				}
				else if (curr3ac->get_reg_counter() == 0){
					//comparing int
					cout << "cmpi " << curr3ac->get_op1() << " r0" << endl;
				}
				// jump to result_op if op1 = op2
				cout << "jne " << curr3ac->get_result() << endl;
			}

			// if op_type is PUSH
			else if( curr_op_type == "PUSH"){
				// if result_op is empty, just push empty space into the stack
				if ( curr3ac->get_result().empty() ){
					cout << "push" << endl;
				}
				else{
					// else print push result_op into the stack
					cout << "push " << curr3ac->get_result() << endl;
				}
			}

			// if op_type is POP
			else if( curr_op_type == "POP"){
				// if result_op is empty, just print pop
				if ( curr3ac->get_result().empty() ){
					cout << "pop" << endl;
				}
				else{
					// else print pop result_op from the stack
					cout << "pop " << curr3ac->get_result() << endl;
				}
			}

			// if op_type is PUSHREG
			else if( curr_op_type == "PUSHREG"){
				// push r0 into the stack, since we are only using one register
				cout << "push r0\n";
			}

			// if op_type is POPREG
			else if( curr_op_type == "POPREG"){
				// pop r0 from the stack
				cout << "pop r0\n";
			}

			// if op_type is LINK
			else if( curr_op_type == "LINK"){
				// link op1 number of spaces for local variables into the stack
				cout << "link" << " " << curr3ac->get_op1() << endl;
			}

			// if op_type is UNLINK
			else if( curr_op_type == "UNLINK"){
				// unlink all the spaces for local variables from the stack
				cout << "unlnk" << endl;
			}

			// if op_type is JSR
			else if( curr_op_type == "JSR"){
				// print jump statement for function
				cout << "jsr " << curr3ac->get_result() << endl;
			}

			// if op_type is RET
			else if( curr_op_type == "RET"){
				// print return statement for function
				cout << "ret" << endl;
			}

			// if op_type is HALT
			else if( curr_op_type == "HALT"){
				// print sys halt indicating end of program execution
				cout << "sys halt" << endl;
			}

			// if op_type is STOREI, store integer value
			else if( curr_op_type == "STOREI"){
				// move op1 to register r0
				cout << "move " << curr3ac->get_op1() << " r0" << endl;
				// store r0 into result_op
				cout << "move r0 " << curr3ac->get_result() << endl;
			}

			// if op_type is STOREF, store float value
			else if( curr_op_type == "STOREF"){
				// move op1 to register r0
				cout << "move " << curr3ac->get_op1() << " r0" << endl;
				// store r0 into result_op
				cout << "move r0 " << curr3ac->get_result() << endl;
			}

			// if op_type is READI, print assembly for integer input
			else if( curr_op_type == "READI"){
				cout << "sys readi " << IR_vector[i]->get_result() <<endl;
			}

			// if op_type is READF, print assembly for float input
			else if( curr_op_type == "READF"){
				cout << "sys readr " << IR_vector[i]->get_result() <<endl;
			}

			// if op_type is WRITEI, print assembly for integer output
			else if( curr_op_type == "WRITEI"){
				cout << "sys writei " << IR_vector[i]->get_op1() <<endl;
			}

			// if op_type is WRITEF, print assembly for float output
			else if( curr_op_type == "WRITEF"){
				cout << "sys writer " << IR_vector[i]->get_op1() <<endl;
			}

			// if op_type is WRITES, print assembly for string output
			else if( curr_op_type == "WRITES"){
				cout << "sys writes " << IR_vector[i]->get_op1() <<endl;
			}

			// if op_type of 3AC code after two instructions is comparision type and op_type after this instruction is STORE, then increment iterator i
			else if (IR_vector[i+2]->get_op_type() == "GT" ||
					IR_vector[i+2]->get_op_type() == "GE" ||
					IR_vector[i+2]->get_op_type() == "LT" ||
					IR_vector[i+2]->get_op_type() == "LE" ||
					IR_vector[i+2]->get_op_type() == "NE" ||
					IR_vector[i+2]->get_op_type() == "EQ"   ) {
						if ( IR_vector[i+1]->get_op_type() == "STOREI" || IR_vector[i+1]->get_op_type() == "STOREF"){i++;}
			}
		}
		// print sys halt at the end
		cout << "sys halt" <<endl;

	}


}
