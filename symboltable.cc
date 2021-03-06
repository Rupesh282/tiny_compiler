#include <iostream>
#include <algorithm>
#include <stack>
#include <assert.h>
#include <unordered_map>
#include <vector>


class entry {
    public :
        std::string name, type, value;
        bool isPara = 0;

        entry() {
            ;
        }

        entry(std::string name, std::string type, std::string value) {
            this->name = name;
            this->type = type;
            this->value = value;
        }

        entry(std::string name, std::string type) {
            this->name = name;
            this->type = type;
        }

        entry(std::string name, std::string type, bool isPara) {
            this->name = name;
            this->type = type;
            this->isPara = isPara;
        }
};


class symbol_table {
    public:
        std::string scope;
        std::unordered_map<std::string, entry> symbolTable;
        std::vector<entry> orderedSym;

        symbol_table(std::string scope) {
            this->scope = scope;
        }

        bool isUsed(std::string name) {
            if(symbolTable.find(name) != symbolTable.end())
                return 1;
            return 0;
        }

        bool add(std::string name, std::string type, std::string value) {
            entry declaration(name, type, value);
            if(!isUsed(declaration.name)) {
                symbolTable[declaration.name] = declaration;
                orderedSym.push_back(declaration);
                return 1;
            }
            return 0;
        }

        bool add(std::string name, std::string type) {
            entry declaration(name, type);
            if(!isUsed(declaration.name)) {
                symbolTable[declaration.name] = declaration;
                orderedSym.push_back(declaration);
                return 1;
            }
            return 0;
        }

        bool add(std::string name, std::string type, bool isPara) {
            entry declaration(name, type, isPara);
            if(!isUsed(declaration.name)) {
                symbolTable[declaration.name] = declaration;
                orderedSym.push_back(declaration);
                return 1;
            }
            return 0;
        }


        void printTable() {
            std::cout << "Symbol table " << scope << "\n";
            for(auto item : orderedSym) {
                std::cout << "name " << item.name << " type " << item.type;
                if(item.value.size()) {
                    std::cout << " value " << item.value ; 
                }
                std::cout << "\n";
            }
        }
};


class ST_stack {
    public: 
        std::string error = "";
        std::stack<symbol_table*> STstack;    
        std::vector<symbol_table*> STvector;
        int block_cnt = 1;

        void addTable(std::string name) {
            symbol_table* table = new symbol_table(name);
            STstack.push(table);
            STvector.push_back(table);
        }

        void addTable() {
            std::string name = "BLOCK " + std::to_string(block_cnt);
            symbol_table* table = new symbol_table(name);
            STstack.push(table);
            STvector.push_back(table);
            block_cnt ++;
        }

        void addDecl(std::string name, std::string type) {
            bool status = STstack.top()->add(name, type);
            if(!status && error == "") {
                error = name;
            }
        }

        void addDecl(std::string name, std::string type, std::string value) {
            bool status = STstack.top()->add(name, type, value);
            if(!status && error == "") {
                error = name;
            }
        }

        void addDecl(std::string name, std::string type, bool isPara) {
            bool status = STstack.top()->add(name, type, isPara);
            if(!status && error == "") {
                error = name;
            }
        }

        void pop_table() {
            assert(STstack.size() > 0);
            STstack.pop();
        }

        void printStack() {
            if(error != "") {
                std::cout << "DECLARATION ERROR " + error << std::endl;
                return;
            }
            //std::cout << "value of stackcnt : " << STstack.size() << "\n";
            for(int i = 0; i < (int)STvector.size(); ++i) {
                STvector[i]->printTable();
                if(i != (int)STvector.size()-1)
                    std::cout << "\n";
            }
        }
};
