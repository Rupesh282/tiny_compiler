# pragma once
#include <iostream>
#include "symboltable.hpp"
#include <vector>
#include <string>
#include "codeStruct.hpp"
#include <map>


static std::string id_type;
class ASTNode {
    public :
        std::string type;
        ASTNode* left;
        ASTNode* right;

        virtual std::string getCode(wholeCode* code) {
            return "this is invalid";
        }
};



class ASTNode_ID: public ASTNode {
    public:
        std::string type = "ID";
        entry* ent;

        ASTNode_ID(entry* ent) {
            this->ent  = ent;
        } 
        std::string getCode(wholeCode* code) {
            return this->ent->name;
        }
};

class ASTNode_INT: public ASTNode {
    public:
        std::string type = "INT";
        int value = -1;

        ASTNode_INT(int value) {
            this->value = value;
        }

        std::string getCode(wholeCode* code) {
            std::string OP = "STOREI";
            std::string arg1 = std::to_string(value);
            std::string arg2 = code->getTempVar();

            code->codelines.push_back(new ERline(code->symbolTable->STstack.top()->scope, OP, arg1, arg2));

            return arg2;
        }
        
};

class ASTNode_FLOAT: public ASTNode {
    public:
        std::string type = "FLOAT";
        double value = -1;

        ASTNode_FLOAT(double value) {
            this->value = value;
        }

        std::string getCode(wholeCode* code) {
            std::string OP = "STOREF";
            std::string arg1 = std::to_string(value);
            std::string arg2 = code->getTempVar();
            code->codelines.push_back(new ERline(code->symbolTable->STstack.top()->scope, OP, arg1, arg2));

            return arg2;
        }
};


class ASTNode_ASSIGN: public ASTNode {
    public:
        std::string type = "ASSIGN";
        entry* ent;

        ASTNode_ASSIGN(entry* ent) {
            this->ent = ent;
            id_type = ent->type;
            this->left = new ASTNode_ID(ent);
        }

        std::string getCode(wholeCode* code) {
            //STOREI <exprevalue>(right) a(left)
            std::string OP = (id_type == "INT" ? "STOREI" : "STOREF");
            std::string arg1 = this->right->getCode(code);
            std::string arg2 = this->left->getCode(code);
            code->codelines.push_back(new ERline(code->symbolTable->STstack.top()->scope, OP, arg1, arg2));

            return "";
        }
};

class ASTNode_CALLEXPR: public ASTNode {
    public: 
        std::string type = "CALLEXPR";
        std::string funct_name = "";
        std::vector<ASTNode*>* parameter_list;

        ASTNode_CALLEXPR(std::string funct_name, std::vector<ASTNode*>* plist) {
            this->funct_name = funct_name;
            this->parameter_list = plist;

        }

        std::string getCode(wholeCode* code) {
            std::string comm = "PUSH";

            code->codelines.push_back(new ERline(code->symbolTable->STstack.top()->scope, comm, ""));

            for(auto& node : *parameter_list) {
                std::string para = node->getCode(code);
                code->codelines.push_back(new ERline(code->symbolTable->STstack.top()->scope, comm, para));
            }

            code->codelines.push_back(new ERline(code->symbolTable->STstack.top()->scope, comm + "R", ""));


            code->codelines.push_back(new ERline(code->symbolTable->STstack.top()->scope, "JSR", funct_name));

            code->codelines.push_back(new ERline(code->symbolTable->STstack.top()->scope, "POPR", ""));
            for(int i=0;i<(int)(*parameter_list).size();++i)
                code->codelines.push_back(new ERline(code->symbolTable->STstack.top()->scope, "POP", ""));

            std::string temp = code->getTempVar();

            code->codelines.push_back(new ERline(code->symbolTable->STstack.top()->scope, "POP", temp)); 


            return temp;
        }
};



class ASTNode_EXPR : public ASTNode {
    public: 
        std::string type = "EXPR";
        std::string opertr;
        std::map<std::pair<std::string, std::string>, std::string> OP_mapping = {
            {{"INT", "+"}, "ADDI"},
            {{"FLOAT", "+"}, "ADDF"},
            {{"INT", "-"}, "SUBI"},
            {{"FLOAT", "-"}, "SUBF"},
            {{"INT", "*"}, "MULI"},
            {{"FLOAT", "*"}, "MULF"},
            {{"INT", "/"}, "DIVI"},
            {{"FLOAT", "/"}, "DIVF"},
        };
        

        ASTNode_EXPR(std::string op) {
            opertr = op;
        }

        std::string getCode(wholeCode* code) {
            std::string OP = OP_mapping[{ id_type,opertr}];
            //std::cout << "OP : " << OP << " [ " << this->left->id_type << ", " << opertr << " ] " << "\n";
            std::string arg1 = this->left->getCode(code);
            std::string arg2 = this->right->getCode(code);
            std::string tempVar = code->getTempVar();
            code->codelines.push_back(new ERline(code->symbolTable->STstack.top()->scope, OP, arg1, arg2, tempVar));
            return tempVar;
        }
};

class ASTNode_COND : public ASTNode {
    public : 
        std::string comp;

        ASTNode_COND(std::string comp) {
            this->comp = comp;
        }

        std::string getCode(wholeCode* code) {
            std::string OP, label;
            std::string arg1 = this->left->getCode(code);
            //arg2 can be ID or temporary
            std::string arg2 = this->right->getCode(code);

            code->lb ++;
            code->lblist.push_back(code->lb);
            label = "LABEL" + std::to_string(code->lb);

            if(comp == ">") {
                OP = "LE";
            } else if(comp == ">=") {
                OP = "LT";
            } else if(comp == "<") {
                OP = "GE";
            } else if(comp == "<=") {
                OP = "GT";
            } else if(comp == "=") {
                OP = "NE";
            } else if(comp == "!=") {
                OP = "EQ";
            }

            code->codelines.push_back(new ERline(code->symbolTable->STstack.top()->scope, OP, arg1, arg2, label));

            return "";
        }
};
