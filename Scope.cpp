/*
 * Acknowledgement: Qifan Chang and Zixian Lai 
 * acknowledgement for documentation : Abhishek Raj
 **/
#include "Scope.h"
#include <iostream>

namespace std{
	Scope::Scope(string name_v){
		name = name_v;								// set name of scope
		static std::vector<std::string> newVector;	
		err_checker = newVector;					
		static std::map< string, Symbol*> newMap;	
		ScopeTab = newMap;							// initialize mapping
	}
	Scope::~Scope(){
		// destructor
	}

	string Scope::get_name(){	// return name of scope
		return name;
	}

	std::map< string, Symbol*> Scope::get_tab(){	// return ScopeTab
		return ScopeTab;
	}
	void Scope::insert_record(string key_name, Symbol* symRecord){

		string sym_name = *(symRecord -> get_name());	// get var name from symbol object
		if (std::find(err_checker.begin(), err_checker.end(), sym_name ) != err_checker.end()){
            // in case of declaration error, we stop 
			cout << "DECLARATION ERROR " << sym_name << "\r\n";
			exit(1);
		}
		ScopeTab[key_name] = symRecord;					// update mapping from var_name to symbol object in ScopeTab
		err_checker.push_back(*(symRecord -> get_name()));
	}
}
