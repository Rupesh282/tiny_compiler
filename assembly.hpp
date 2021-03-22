# pragma once
#include <iostream>
#include <vector>
#include <map>
#include "ast.hpp"
#include <string>


class assemblyCode {
    public:
        int reg = 0;
        std::map<std::string, std::string> tempToReg;
        std::vector<ERline> assembly;

        std::string getNewReg() {
            reg ++;
            return "r" + std::to_string(reg);
        }

        std::string getWhatever(std::string temp) {
            if(temp[0] != '$')
                return temp;
            if(tempToReg.find(temp) != tempToReg.end())
                return tempToReg[temp];
            tempToReg[temp] = getNewReg();
            return tempToReg[temp];
        }

        bool isTemp(std::string temp) {
            return temp[0] == '$';
        }

        assemblyCode(wholeCode* code) {
            auto getLower = [&](std::string s) -> std::string {
                for(char& i : s)
                    i |= ' ';
                if(s.back() == 'f')
                    s.back() = 'r';
                return s;
            };
            for(ERline* line : code->codelines) {
                std::string com = line->command;
                //line->print();
                //std::cerr << "[ \n";
                if(com == "STOREI" || com == "STOREF") {
                    assembly.push_back(ERline(line->scope, "move", getWhatever(line->arg1), getWhatever(line->arg2)));
                    //assembly.back().print();
                } else if(com == "WRITEI" || com == "WRITEF" || com == "WRITES") {
                    assembly.push_back(ERline(line->scope, "sys", getLower(com), getWhatever(line->arg1)));
                    //assembly.back().print();
                } else if(com == "READI" || com == "READF") {
                    assembly.push_back(ERline(line->scope, "sys", getLower(com), getWhatever(line->arg1)));
                    //assembly.back().print();
                } else {
                    const std::string Ids[] = { "ADD", "SUB", "DIV", "MUL"};
                    const std::string cmps[] = { "GE", "GT", "LT", "LE", "NE", "EQ"};
                    bool presentinId = false;
                    for(std::string i : Ids) {
                        if(i == com.substr(0, 3)) {
                            assembly.push_back(ERline(line->scope, "move", getWhatever(line->arg1), getWhatever(line->arg3)));
                            //assembly.back().print();
                            assembly.push_back(ERline(line->scope, getLower(com), getWhatever(line->arg2), getWhatever(line->arg3)));
                            //assembly.back().print();
                            presentinId = true;
                            break;
                        }
                    }
                    //if(presentinId)
                        //continue;


                    // handle jump statements
                    for(std::string i : cmps) {
                        if(i == com) {
                        // TODO :// generate correct comp<i/r>
                            assembly.push_back(ERline(line->scope, "cmpi", getWhatever(line->arg1), getWhatever(line->arg2)));
                            //assembly.back().print();
                            assembly.push_back(ERline(line->scope, "j" + getLower(com), getWhatever(line->arg3)));
                            //assembly.back().print();
                            presentinId = true;
                            break;
                        }
                    }


                    if(com == "JUMP") {
                        assembly.push_back(ERline(line->scope, "jmp", line->arg1));
                        presentinId = true;
                    } else if(com == "LABEL") {
                        assembly.push_back(ERline(line->scope, "label", line->arg1));
                        presentinId = true;
                    }
                    assert(presentinId == 1);
                }
                //std::cerr<< "] \n";
            }

            //std::cerr << "*******************\n";
            //for(auto i : tempToReg)
                //std::cerr << i.first << " " << i.second << "\n";
            //std::cerr << "*******************\n";
        }

        void print() {
            for(auto line : assembly)
                line.print();
        }

};
