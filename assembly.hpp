# pragma once
#include <iostream>
#include <vector>
#include <map>
#include "ast.hpp"
#include <string>
#include <queue>
#define REGN 4


class assemblyCode {
    public:
        int reg = 0;
        std::map<std::string, std::string> tempToReg;
        std::vector<ERline> assembly;
        std::deque<int> reg_Q; // last reg : recently used , first reg : least recently used


        std::string frameVar(std::vector<symbol_table*> STvector, std::string s, std::string scope) {
            if(s[0] != '$') {
                //search for local var
                /*
                 *bool got = 0;
                 *for(int i=STvector.size()-1;i>=0;--i) {
                 *    if(STvector[i]->scope == scope)
                 *        got = 1;
                 *    if(got == 1 && STvector[i]->scope[0] != '$') {
                 *        scope = STvector[i]->scope;
                 *        break;
                 *    }
                 *}
                 */

                std::string Nscope;
                int curind = -1;
                for(int i=0;i<(int)STvector.size();++i) {
                    if(STvector[i]->scope[0] != '$')
                        Nscope = STvector[i]->scope, curind = i;
                    if(STvector[i]->scope == scope)
                        break;
                }

                // std::cerr << "[***] [ " << scope << " ] :" << s << "\n";
                symbol_table* curtable;
                for(symbol_table* table : STvector) {
                    if(table->scope == Nscope) {
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
                std::vector<entry> allentries;

                for(int i=curind ; ; ++i) {

                    for(int j=0;j<STvector[i]->orderedSym.size();++j)
                        allentries.push_back(STvector[i]->orderedSym[j]);

                    if(STvector[i]->scope == scope)
                        break;
                }

                for(int i=0;i<(int)allentries.size();++i) {
                    if(allentries[i].name == s) {
                        if(allentries[i].isPara == true)
                            return "#" + std::to_string(5 + i + 1);
                        return "#-" + std::to_string(i + 1 - no_parameters);
                    }
                }
            }
            return s;
        }


        std::string getNewReg(std::vector<symbol_table*> STvector, std::string scope) {
            if(reg_Q.size() == REGN) {
                //perform LRU
                int reg_to_evict = reg_Q.front();
                
                //first move the reg value to memory
                std::string sr = "r" + std::to_string(reg_to_evict);
                std::string toMove;
                for (auto e : tempToReg) {
                    if(e.second == sr) {
                        toMove = e.first;
                        break;
                    }
                }
                if(toMove[0] != '$') {
                    toMove = frameVar(STvector, toMove, scope);
                    if(toMove[0] == '#')
                        toMove[0] = '$';
                    assembly.push_back(ERline("EVICTING", "move", sr, toMove));
                }

                //then remove from map and queue
                tempToReg.erase(toMove);
                reg_Q.pop_front();

                //move the to_evict reg to end of queue
                reg_Q.push_back(reg_to_evict);

                //return evacuated register
                return sr;
            } else {
                //allocate new reg
                if(reg == REGN) reg = 0;
                return "r" + std::to_string(reg++);
            }
            //reg ++;
            //return "r" + std::to_string(reg);
        }

        std::string getWhatever(std::vector<symbol_table*> STvector, std::string scope, std::string temp) {
            if(temp[0] == '#') {
                temp[0] = '$';
                return temp;
            }
            if(temp[0] != '$')
                return temp;
            if(tempToReg.find(temp) != tempToReg.end()) {
                //reg is used here ,so update the reg_Q
                int R = std::stoi(tempToReg[temp].substr(1));
                for(std::deque<int> :: iterator it = reg_Q.begin(); it != reg_Q.end(); ++it) {
                    if(*it == R) {
                        reg_Q.erase(it);
                        break;
                    }
                }
                reg_Q.push_back(R);
                return tempToReg[temp];
            }
            tempToReg[temp] = getNewReg(STvector, scope);
            return tempToReg[temp];
        }

        std::string getRegForID(std::vector<symbol_table*> STvector, std::string scope, std::string ID) {
            tempToReg[ID] = getNewReg(STvector, scope);
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

            /*
             *for(int i=0;i<(int)STvector.size();++i) {
             *    std::cerr << STvector[i]->scope << ": \n";
             *    for(int j=0;j<(int)STvector[i]->orderedSym.size();++j)
             *        std::cerr << STvector[i]->orderedSym[j].name << ", " << STvector[i]->orderedSym[j].type << "\n";
             *}
             */

            for(ERline* line : code->codelines) {
                std::string com = line->command;

                std::string farg1, farg2, farg3;

/*
 *                auto frameVar = [&](std::string s, std::string scope) -> std::string {
 *                    if(s[0] != '$') {
 *                        //search for local var
 *                        bool got = 0;
 *                        for(int i=STvector.size()-1;i>=0;--i) {
 *                            if(STvector[i]->scope == scope)
 *                                got = 1;
 *                            if(got == 1 && STvector[i]->scope[0] != '$') {
 *                                scope = STvector[i]->scope;
 *                                break;
 *                            }
 *                        }
 *                        // std::cerr << "[***] [ " << scope << " ] :" << s << "\n";
 *                        symbol_table* curtable;
 *                        for(symbol_table* table : STvector) {
 *                            if(table->scope == scope) {
 *                                curtable = table;
 *                                break;
 *                            }
 *                        }
 *
 *                        int no_parameters = 0;
 *
 *                        for(int i=0;i<(int)curtable->orderedSym.size();++i) {
 *                            if(curtable->orderedSym[i].isPara == true)
 *                                no_parameters ++;
 *                        }
 *
 *                        //std::cerr << "no_para : " << "scope : " << scope << ", " << no_parameters << "\n";
 *
 *                        for(int i=0;i<(int)curtable->orderedSym.size();++i) {
 *                            if(curtable->orderedSym[i].name == s) {
 *                                if(curtable->orderedSym[i].isPara == true)
 *                                    return "#" + std::to_string(5 + i + 1);
 *                                return "#-" + std::to_string(i + 1 - no_parameters);
 *                            }
 *                        }
 *                    }
 *                    return s;
 *                };
 *
 */
                farg1 = frameVar(STvector, line->arg1, line->scope);
                farg2 = frameVar(STvector, line->arg2, line->scope);
                farg3 = frameVar(STvector, line->arg3, line->scope);


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

                        assembly.push_back(ERline(line->scope, "move", getWhatever(STvector, line->scope, farg1), flag));
                        assembly.push_back(ERline(line->scope, "unlnk", ""));
                        assembly.push_back(ERline(line->scope, "ret", ""));
                    } else {
                        std::string newR = getNewReg(STvector, line->scope);
                        tempToReg[farg1] = newR;
                        assembly.push_back(ERline(line->scope, "move", getWhatever(STvector, line->scope, farg1), newR));
                        assembly.push_back(ERline(line->scope, "move", newR, flag));
                        assembly.push_back(ERline(line->scope, "unlnk", ""));
                        assembly.push_back(ERline(line->scope, "ret", ""));
                    }
                }
                if(com == "PUSH") {
                    if(line->arg1 != "") {
                        assembly.push_back(ERline(line->scope, "push", getWhatever(STvector, line->scope, farg1)));
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
                    int cnt = 0;
                    bool got = 0;
                    for(int i=0;i<(int)STvector.size();++i) {
                        if(STvector[i]->scope == line->scope) {
                            got = 1;
                            cnt += STvector[i]->symbolTable.size();
                        }
                        else if(got && STvector[i]->scope[0] == '$') {
                            cnt += STvector[i]->symbolTable.size();
                        }
                        else if(got)
                            break;
                    }
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
                        assembly.push_back(ERline(line->scope, "pop", getWhatever(STvector, line->scope, farg1)));
                }
                if(com == "POPR") {
                    assembly.push_back(ERline(line->scope, "pop", "r3"));
                    assembly.push_back(ERline(line->scope, "pop", "r2"));
                    assembly.push_back(ERline(line->scope, "pop", "r1"));
                    assembly.push_back(ERline(line->scope, "pop", "r0"));
                }
                if(com == "STOREI" || com == "STOREF") {
                    assembly.push_back(ERline(line->scope, "move", getWhatever(STvector, line->scope,farg1), getWhatever(STvector, line->scope,farg2)));
                    //assembly.back().print();
                } else if(com == "WRITEI" || com == "WRITEF" || com == "WRITES") {
                    assembly.push_back(ERline(line->scope, "sys", getLower(com), getWhatever(STvector, line->scope,farg1)));
                    //assembly.back().print();
                } else if(com == "READI" || com == "READF") {
                    assembly.push_back(ERline(line->scope, "sys", getLower(com), getWhatever(STvector, line->scope,farg1)));
                    //assembly.back().print();
                } else {
                    const std::string Ids[] = { "ADD", "SUB", "DIV", "MUL"};
                    const std::string cmps[] = { "GE", "GT", "LT", "LE", "NE", "EQ"};
                    bool presentinId = false;
                    for(std::string i : Ids) {
                        if(i == com.substr(0, 3)) {
                            assembly.push_back(ERline(line->scope, "move", getWhatever(STvector, line->scope,farg1), getWhatever(STvector, line->scope,farg3)));
                            //assembly.back().print();
                            assembly.push_back(ERline(line->scope, getLower(com), getWhatever(STvector, line->scope,farg2), getWhatever(STvector, line->scope,farg3)));
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
                            //std::cerr << line->scope << "\n";
                            if(line->arg2[0] != '$') {
                                // no temporary
                                std::string temp = getRegForID(STvector, line->scope, line->arg2);
                                assembly.push_back(ERline(line->scope, "move", getWhatever(STvector, line->scope,farg2), temp));
                                // TODO;
                                std::string cmp = "cmp";
                                bool got = 0, G = 0;
                                for(int id=(int)STvector.size()-1;id>=0;--id) {
                                    if(STvector[id]->scope == line->scope) {
                                        //for(int jd=0;jd<(int)STvector[id]->orderedSym.size();++jd) {
                                            //if(STvector[id]->orderedSym[jd].name == line->arg1) {
                                                //cmp += (STvector[id]->orderedSym[jd].type == "INT" ? "i" : "r");
                                                //G = 1;
                                                //break;
                                            //}
                                        //}
                                        got = 1;
                                        //if(G)
                                            //break;
                                    }
                                    if(got && STvector[id]->scope[0] != '$') {
                                        for(int jd=0;jd<(int)STvector[id]->orderedSym.size();++jd) {
                                            if(STvector[id]->orderedSym[jd].name == line->arg1) {
                                                cmp += (STvector[id]->orderedSym[jd].type == "INT" ? "i" : "r");
                                                break;
                                            }
                                        }
                                        break;
                                    }
                                }
                                if(cmp.size() != 4)
                                    cmp += "r";

                                assembly.push_back(ERline(line->scope, cmp, getWhatever(STvector, line->scope,farg1), temp));
                            }
                            else {
                                // std::cerr << "farg1 " << farg1 << "\n";
                                // TODO;
std::string cmp = "cmp";
                                bool got = 0, G = 0;
                                for(int id=(int)STvector.size()-1;id>=0;--id) {
                                    if(STvector[id]->scope == line->scope) {
                                        //for(int jd=0;jd<(int)STvector[id]->orderedSym.size();++jd) {
                                            //if(STvector[id]->orderedSym[jd].name == line->arg1) {
                                                //cmp += (STvector[id]->orderedSym[jd].type == "INT" ? "i" : "r");
                                                //G = 1;
                                                //break;
                                            //}
                                        //}
                                        got = 1;
                                        //if(G)
                                            //break;
                                    }
                                    if(got && STvector[id]->scope[0] != '$') {
                                        for(int jd=0;jd<(int)STvector[id]->orderedSym.size();++jd) {
                                            if(STvector[id]->orderedSym[jd].name == line->arg1) {
                                                cmp += (STvector[id]->orderedSym[jd].type == "INT" ? "i" : "r");
                                                break;
                                            }
                                        }
                                        break;
                                    }
                                }
                                if(cmp.size() != 4)
                                    cmp += "r";
                                assembly.push_back(ERline(line->scope, cmp, getWhatever(STvector, line->scope,farg1), getWhatever(STvector, line->scope,farg2)));
                            }
                            //assembly.back().print();
                            assembly.push_back(ERline(line->scope, "j" + getLower(com), getWhatever(STvector, line->scope,farg3)));
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
