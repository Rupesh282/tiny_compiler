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
            if(temp[0] == '#') {
                temp[0] = '$';
                return temp;
            }
            if(temp[0] != '$')
                return temp;
            if(tempToReg.find(temp) != tempToReg.end())
                return tempToReg[temp];
            tempToReg[temp] = getNewReg();
            return tempToReg[temp];
        }

        std::string getRegForID(std::string ID) {
            tempToReg[ID] = getNewReg();
            return tempToReg[ID];
        }

        bool isTemp(std::string temp) {
            return temp[0] == '$';
        }

        assemblyCode(wholeCode* code, std::vector<symbol_table*> STvector) {
            auto getLower = [&](std::string s) -> std::string {
                for(char& i : s)
                    i |= ' ';
                if(s.back() == 'f')
                    s.back() = 'r';
                return s;
            };
            
            //for(symbol_table* table : STvector) {


                //if(table->scope == "GLOBAL") {
                    //;
                //}

                //std::cout << table->scope << "\n";


                for(ERline* line : code->codelines) {
                    std::string com = line->command;

                    //if(line->scope != table->scope)
                        //continue;

                    //line->print();
                    //std::cerr << "[ \n";

                    //move 0 r7
                    //move r7 $6
                    //unlnk
                    //ret

                    std::string farg1, farg2, farg3;

                    auto frameVar = [&](std::string s, std::string scope) -> std::string {
                        if(s[0] != '$') {
                            //search for local var
                            bool got = 0;
                            for(int i=STvector.size()-1;i>=0;--i) {
                                if(STvector[i]->scope == scope)
                                    got = 1;
                                if(got == 1 && STvector[i]->scope[0] != '$') {
                                    scope = STvector[i]->scope;
                                    break;
                                }
                            }
                            // std::cerr << "[***] [ " << scope << " ] :" << s << "\n";
                            symbol_table* curtable;
                            for(symbol_table* table : STvector) {
                                if(table->scope == scope) {
                                    curtable = table;
                                    break;
                                }
                            }

                            int no_parameters = 0;

                            for(int i=0;i<(int)curtable->orderedSym.size();++i) {
                                if(curtable->orderedSym[i].isPara == true)
                                    no_parameters ++;
                            }

                            //std::cerr << "no_para : " << "scope : " << scope << ", " << no_parameters << "\n";

                            for(int i=0;i<(int)curtable->orderedSym.size();++i) {
                                if(curtable->orderedSym[i].name == s) {
                                    if(curtable->orderedSym[i].isPara == true)
                                        return "#" + std::to_string(5 + i + 1);
                                    return "#-" + std::to_string(i + 1 - no_parameters);
                                }
                            }
                        }
                        return s;
                    };

                    farg1 = frameVar(line->arg1, line->scope);
                    farg2 = frameVar(line->arg2, line->scope);
                    farg3 = frameVar(line->arg3, line->scope);


                    std::string flag = "$";
                    int no_parameters = 0;

                    bool got = 0;
                    std::string scope = line->scope;
                    for(int i=STvector.size()-1;i>=0;--i) {
                        if(STvector[i]->scope == scope)
                            got = 1;
                        if(got == 1 && STvector[i]->scope[0] != '$') {
                            scope = STvector[i]->scope;
                            break;
                        }
                    }

                    symbol_table* curtable;
                    for(symbol_table* table : STvector) {
                        if(table->scope == scope) {
                            curtable = table;
                            break;
                        }
                    }
                    for(int i=0;i<(int)curtable->orderedSym.size();++i) {
                        if(curtable->orderedSym[i].isPara == true)
                            no_parameters ++;
                    }

                    flag += std::to_string(6 + no_parameters);
                    if(com == "RET") {
                        //assembly.push_back(ERline(line->scope, "move", line->arg1, getWhatever(farg1)));
                        if(farg1[0] == '$') {

                            assembly.push_back(ERline(line->scope, "move", getWhatever(farg1), flag));
                            assembly.push_back(ERline(line->scope, "unlnk", ""));
                            assembly.push_back(ERline(line->scope, "ret", ""));
                        } else {
                            std::string newR = getNewReg();
                            tempToReg[farg1] = newR;
                            assembly.push_back(ERline(line->scope, "move", getWhatever(farg1), newR));
                            assembly.push_back(ERline(line->scope, "move", newR, flag));
                            assembly.push_back(ERline(line->scope, "unlnk", ""));
                            assembly.push_back(ERline(line->scope, "ret", ""));
                        }
                    }
                    if(com == "PUSH") {
                        if(line->arg1 != "") {
                            assembly.push_back(ERline(line->scope, "push", getWhatever(farg1)));
                            //symbol_table* curtable;
                            //for(symbol_table* table : STvector) {
                                //if(table->scope == line->scope) {
                                    //curtable = table;
                                    //break;
                                //}
                            //}
                            //std::cerr << curtable->scope << "\n";
                            //for(auto i : curtable->symbolTable) {
                                //assembly.push_back(ERline(line->scope, "push", ever(i.first)));
                            //}
                        }
                        else {
                            //return value push
                            assembly.push_back(ERline(line->scope, "push", ""));

                        }
                    }
                    if(com == "PUSHR") {
                        assembly.push_back(ERline(line->scope, "push", "r0"));
                        assembly.push_back(ERline(line->scope, "push", "r1"));
                        assembly.push_back(ERline(line->scope, "push", "r2"));
                        assembly.push_back(ERline(line->scope, "push", "r3"));
                    }
                    if(com == "LINK") {
                        int cnt = 5;
                        assembly.push_back(ERline(line->scope, "link", std::to_string(cnt)));
                    }
                    if(com == "JSR") {
                        assembly.push_back(ERline(line->scope, "jsr", line->arg1));
                    }
                    if(com == "POP") {
                        if(line->arg1 == "") {

                            assembly.push_back(ERline(line->scope, "pop", ""));
                            //assembly.push_back(ERline(line->scope, "pop", ""));
                            //assembly.push_back(ERline(line->scope, "pop", ""));
                            //assembly.push_back(ERline(line->scope, "pop", ""));
                            //assembly.push_back(ERline(line->scope, "pop", ""));
                        }
                        else 
                            assembly.push_back(ERline(line->scope, "pop", getWhatever(farg1)));
                    }
                    if(com == "POPR") {
                        assembly.push_back(ERline(line->scope, "pop", "r3"));
                        assembly.push_back(ERline(line->scope, "pop", "r2"));
                        assembly.push_back(ERline(line->scope, "pop", "r1"));
                        assembly.push_back(ERline(line->scope, "pop", "r0"));
                    }
                    if(com == "STOREI" || com == "STOREF") {
                        assembly.push_back(ERline(line->scope, "move", getWhatever(farg1), getWhatever(farg2)));
                        //assembly.back().print();
                    } else if(com == "WRITEI" || com == "WRITEF" || com == "WRITES") {
                        assembly.push_back(ERline(line->scope, "sys", getLower(com), getWhatever(farg1)));
                        //assembly.back().print();
                    } else if(com == "READI" || com == "READF") {
                        assembly.push_back(ERline(line->scope, "sys", getLower(com), getWhatever(farg1)));
                        //assembly.back().print();
                    } else {
                        const std::string Ids[] = { "ADD", "SUB", "DIV", "MUL"};
                        const std::string cmps[] = { "GE", "GT", "LT", "LE", "NE", "EQ"};
                        bool presentinId = false;
                        for(std::string i : Ids) {
                            if(i == com.substr(0, 3)) {
                                assembly.push_back(ERline(line->scope, "move", getWhatever(farg1), getWhatever(farg3)));
                                //assembly.back().print();
                                assembly.push_back(ERline(line->scope, getLower(com), getWhatever(farg2), getWhatever(farg3)));
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
                                if(line->arg2[0] != '$') {
                                    // no temporary
                                    std::string temp = getRegForID(line->arg2);
                                    assembly.push_back(ERline(line->scope, "move", getWhatever(farg2), temp));
                                    assembly.push_back(ERline(line->scope, "cmpi", getWhatever(farg1), temp));
                                }
                                else {
                                    // std::cerr << "farg1 " << farg1 << "\n";
                                    assembly.push_back(ERline(line->scope, "cmpi", getWhatever(farg1), getWhatever(farg2)));
                                }
                                //assembly.back().print();
                                assembly.push_back(ERline(line->scope, "j" + getLower(com), getWhatever(farg3)));
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
                        //assert(presentinId == 1);
                        if(presentinId == 0) {
                            //std::cout << "missing : " << com << ", " << line->scope << "\n";
                        }
                    }
                    //std::cerr<< "] \n";
                }

                //std::cerr << "*******************\n";
                //for(auto i : tempToReg)
                    //std::cerr << i.first << " " << i.second << "\n";
                //std::cerr << "*******************\n";
            //}
        }

        void print() {
            for(auto line : assembly)
                line.print();
        }

};
