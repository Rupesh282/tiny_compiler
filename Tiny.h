/*
 * Acknowledgement: Qifan Chang and Zixian Lai 
 * acknowledgement for documentation : Abhishek Raj
 **/
#ifndef TINY_H
#define TINY_H
#include <string>
#include <utility>
#include <algorithm>
#include <map>
#include <vector>
#include <stack>
#include <iostream>
#include "main.h"

namespace std{
	class Tiny{
		private:
			std::vector<std::IR_code*> IR_vector;	// holds 3AC code
		public:
			Tiny(std::vector<std::IR_code*> IR_vector_in);		// costructor for tiny object
			virtual ~Tiny();		// destructor for tiny object
			void genTiny();			// print assembly code
	};

}
#endif
