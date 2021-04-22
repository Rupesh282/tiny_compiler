/*
 * Acknowledgement: Qifan Chang and Zixian Lai 
 * acknowledgement for documentation : Abhishek Raj
 **/
#ifndef SCOPE_H
#define SCOPE_H
#include <string>
#include <utility>
#include <algorithm>
#include <map>
#include <vector>
#include "Symbol.h"


namespace std{
	class Scope {
		private:
			string name;							// name of scope
			std::map< string, Symbol*> ScopeTab;	// mapping from var_name to symbol object in current scope
			std::vector<std::string> err_checker; // to check error in declaration
		public:
			Scope(string name_v);					// contructor
			virtual ~Scope();						// destructor
			string get_name();						// returns name of scope
			std::map< string, Symbol*> get_tab();	// returns mapping ScopeTab
			void insert_record(string ,Symbol*);	// inserts a record in ScopeTab
	};
}
#endif
