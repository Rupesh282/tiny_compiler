# pragma once
#include <iostream>
#include <string>
#include <vector>
#include "symboltable.hpp"
#include <deque>


class ERline {
public:
    std::string command, arg1 ,arg2, arg3;
    std::string scope;

    ERline(std::string scope, std::string command, std::string arg1) {
        this->scope = scope;
        this->command = command;
        this->arg1 = arg1;
        this->arg2 = "";
        this->arg3 = "";
    }

    ERline(std::string scope, std::string command, std::string arg1, std::string arg2) {
        this->scope = scope;
        this->command = command;
        this->arg1 = arg1;
        this->arg2 = arg2;
        this->arg3 = "";
    }

    ERline(std::string scope, std::string command, std::string arg1, std::string arg2, std::string arg3) {
        this->scope = scope;
        this->command = command;
        this->arg1 = arg1;
        this->arg2 = arg2;
        this->arg3 = arg3;
    }

    void print() {
        std::string print_val =  command + " " + arg1;
        if (arg2 != "")
            print_val += " " + arg2;
        if (arg3 != "")
            print_val += " " + arg3;
        std::cout << print_val << std::endl;
    }
};


class wholeCode {
    public :
        std::vector<ERline*> codelines;
        ST_stack* symbolTable;
        int T = 1; // this is value for temporary register
        int lb = 0;
        std::deque<int> lblist;
 
        wholeCode(ST_stack* symbolTable) {
            this->symbolTable = symbolTable;
        }

        std::string getTempVar() {
            return "$T" + std::to_string(T++);
        }

        void ERwrite(std::string type, std::string name) {
            if(type == "INT") {
                this->codelines.push_back(new ERline(this->symbolTable->STstack.top()->scope, "WRITEI", name));
            } else if(type == "FLOAT") {
                this->codelines.push_back(new ERline(this->symbolTable->STstack.top()->scope, "WRITEF", name));
            } else if(type == "STRING") {
                this->codelines.push_back(new ERline(this->symbolTable->STstack.top()->scope, "WRITES", name));
            }
        }

        void ERread(std::string type, std::string name) {
            if(type == "INT") {
                this->codelines.push_back(new ERline(this->symbolTable->STstack.top()->scope, "READI", name));
            } else if(type == "FLOAT") {
                this->codelines.push_back(new ERline(this->symbolTable->STstack.top()->scope, "READF", name));
            }
        }

        void print() {
            std::cout << "size : " << (int)codelines.size() << "\n";
            for(auto line : codelines) 
                line->print();
        }
};
