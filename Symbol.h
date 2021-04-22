/*
 * Acknowledgement: Qifan Chang and Zixian Lai 
 * acknowledgement for documentation : Abhishek Raj
 **/
#ifndef SYMBOL_H
#define SYMBOL_H
#include <string>

// class for variable
namespace std{
	class Symbol {
		private:
			string * name;				// name of var
			string * value_s;			// value of var
			int value_i;				// int value of var
			float value_f;				// float value of var
			int type;					// int or float or string
			int stack_pointer;			// stack pointer in which this var is present
		public:
			Symbol(string* name_v, string* value_v, int type_t, int stack_p);		// constructor
			virtual ~Symbol();			// destructor for class
			string * get_name();		// returns name of var
			string * get_value();		// returns value of var in string format
			int get_type();				// return type of var
			int get_stack_pointer();	// return stack pointer
	};
}
#endif
