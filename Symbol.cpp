/*
 * Acknowledgement: Qifan Chang and Zixian Lai 
 * acknowledgement for documentation : Abhishek Raj
 **/
#include "Symbol.h"

namespace std{
	Symbol::Symbol(string* name_v, string* value_v, int type_t, int stack_p){
		name = name_v;			// set value of name
		value_s = value_v;		// set value of variable
		type = type_t;			// set type
		stack_pointer = stack_p;// set stack ptr
	}
	Symbol::~Symbol(){
		//nothing
	}

	string * Symbol::get_name(){	// return name of var
		return name;
	}
	string * Symbol::get_value(){	// returns value of var in string format
		return value_s;
	}
	int Symbol::get_type(){			// return type of var
		return type;
	}
	int Symbol::get_stack_pointer(){	// return stack pointer
		return stack_pointer;
	}
}
