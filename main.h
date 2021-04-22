/*
 * Acknowledgement: Qifan Chang and Zixian Lai 
 * acknowledgement for documentation : Abhishek Raj
 **/
#include <stdio.h>
#include <stdlib.h>
#include <list>
#include <map>
#include <utility>
#include <algorithm>
#include "Symbol.h"
#include "Scope.h"
#include "ASTNode.h"
#include "Tiny.h"

extern std::vector<std::Scope*> SymTabHead;            // store all scope as they occur in program
extern std::vector<std::IR_code*> IR_vector;           // to save all intermediate 3AC
