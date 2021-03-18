# pragma once
#include <iostream>
#include "symboltable.hpp"
#include <vector>
#include <string>
#include "codeStruct.hpp"
#include <map>


class ASTNode {
    public :
        std::string type;
        inline static std::string testtype;
        ASTNode* left;
        ASTNode* right;
        ASTNode* middle;

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
            ASTNode::testtype = ent->type;
            this->left = new ASTNode_ID(ent);
        }

        std::string getCode(wholeCode* code) {
            //STOREI <exprevalue>(right) a(left)
            std::string OP = (ASTNode::testtype == "INT" ? "STOREI" : "STOREF");
            std::string arg1 = this->right->getCode(code);
            std::string arg2 = this->left->getCode(code);
            code->codelines.push_back(new ERline(code->symbolTable->STstack.top()->scope, OP, arg1, arg2));

            return "";
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
            {{"FLOAt", "-"}, "SUBF"},
            {{"INT", "*"}, "MULI"},
            {{"FLOAT", "*"}, "MULF"},
            {{"INT", "/"}, "DIVI"},
            {{"FLOAT", "/"}, "DIVF"},
        };
        

        ASTNode_EXPR(std::string op) {
            opertr = op;
        }

        std::string getCode(wholeCode* code) {
            std::string OP = OP_mapping[{ ASTNode::testtype,opertr}];
            //std::cout << "OP : " << OP << " [ " << this->left->testtype << ", " << opertr << " ] " << "\n";
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
            int labelcnt = code->getLabelcnt();
            std::string arg1 = this->left->getCode(code);
            std::string arg2 = this->right->getCode(code);

            label = "LABEL" + std::to_string(labelcnt);

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

            return label;
        }
};

class ASTNode_BRANCH : public ASTNode {
    public :
        std::string type = "BRANCH";
        std::string label1, label2;

        //child distr : 
        //left : cond
        //right : else body
        //middle : if body

        ASTNode_BRANCH() {
            //set label values
        }

        std::string getCode(wholeCode* code) {
            std::string curlabel = this->left->getCode(code);
        }
};
