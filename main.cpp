/*
 * Acknowledgement: Qifan Chang and Zixian Lai 
 * acknowledgement for documentation : Abhishek Raj
 **/
#include <iostream>
#include <stdio.h>
#include <vector>
#include <map>
#include <string>
#include <set>
#include <vector>
#include "main.h"
#include "parser.hpp"
using namespace std;

// Define Global Variables
int var_ct = 0;
bool reg_only_flag = false;
std::map<string, string> var_dict;
std::map<string, string> reg_dict;

// extern yyin for taking file input
extern FILE* yyin;

int main(int argc, char **argv)
{
	FILE *scanfile = fopen( argv[1], "r");			// take file name as command line argument
	if(!scanfile)
	{
		// if error while opening file, exit
		printf("Can't open the file\n");
		return -1;
	}
	yyin = scanfile;	// set yyin variable for bison to tokenize Micro program from scanfile

	int check = yyparse();	 // parse scanfile 

	if(check == 0)
	{
		//printf("Accepted");
	}
	// if check == 1 , our micro code may have some syntax errors.

	std::set<string> tempVarSet;				// set of global variable we are going to use for this program as temporaries
	/*
		Basically we are scanning through 3 AC code and taking all temporary 
		variables and declaring them as global.
		this way we use lot of memory but we don't need to allocate register for them
	*/
	for (int i = 0; i < IR_vector.size(); i++)
	{
		cout << ";";							// comment in mirco language
		cout << IR_vector[i]->get_op_type();
		if(IR_vector[i]->get_op1() != "") {	// check for temp variable in op1
			std::cout << " op1:" << IR_vector[i]->get_op1();
			if((IR_vector[i]->get_op1()).find('T') != std::string::npos){
				tempVarSet.insert(IR_vector[i]->get_op1());
			}
		}
		if(IR_vector[i]->get_op2() != ""){		// check for temp var in op2
			std::cout << " op2:" << IR_vector[i]->get_op2();
			if((IR_vector[i]->get_op2()).find('T') != std::string::npos){
				tempVarSet.insert(IR_vector[i]->get_op2());
			}
		}
		if(IR_vector[i]->get_result() != ""){	// check for temp var in destination position
			cout << " result:" << IR_vector[i]->get_result();
			if((IR_vector[i]->get_result()).find('T') != std::string::npos){
				tempVarSet.insert(IR_vector[i]->get_result());
			}
		}
		cout << endl;
	}
	cout << endl;

	//now we start writing assembly for micro language 

	set<string>::iterator iter;
	//declare global variables in micro language using 'var' keyword
	for(iter=tempVarSet.begin(); iter!=tempVarSet.end();++iter) {
		cout << "var " << *iter << endl;
	}

	// generate assembly code from intermediate 3AC.
	std::Tiny* optTiny = new std::Tiny(IR_vector);
	optTiny -> genTiny();		// print assembly

	return 0;
}
