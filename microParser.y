%{
    void yyerror(char const *s);
    extern char* yytext;
    extern "C" int yylex();
    #include "symboltable.hpp"
    #include "codeStruct.hpp"
    ST_stack* ST = new ST_stack();
    wholeCode* WC = new wholeCode(ST);
%}

%code requires {
    #include<iostream>
    #include<string>
    #include<vector>
    #include<utility>
    #include "ast.hpp"
    #include "assembly.hpp"
}

%token PROGRAM _BEGIN END IDENTIFIER STRINGLITERAL STRING FLOAT FLOATLITERAL INT INTLITERAL VOID FUNCTION READ WRITE RETURN IF FI ELSE FOR ROF ADD SUB MULT DIV EQUAL NEQUAL EXCL LESSTHAN GREATERTHAN LESSTHANEQ GREATERTHANEQ BRACKET_OPEN BRACKET_CLOSE SEMICOLON COLON ASSIGNMENT 

%union {
    int intval;
    float floatval;
    std::string* strval;
    std::vector<std::string*>* strlist;
    ASTNode* astnode;
}

%type <strval> str id IDENTIFIER STRINGLITERAL 
%type <strlist> id_list id_tail 
%type <intval> var_type INT any_type VOID INTLITERAL
%type <floatval> FLOAT FLOATLITERAL
%type <astnode> mulop addop primary postfix_expr factor_prefix factor expr_prefix expr compop
//%type <astlist> expr_list expr_list_tail 

%%

// Program
program :   PROGRAM id _BEGIN 
            { ST->addTable("GLOBAL"); }
            pgm_body END
            { ST->pop_table(); } 
            ;
id : IDENTIFIER     ;
pgm_body : decl func_declarations
    ;
decl : 
    %empty
    | string_decl decl
    | var_decl decl
    ;

// Global String Declaration
string_decl : STRING id ASSIGNMENT str SEMICOLON 
            { ST->addDecl(*($2), "STRING", *($4)); }
    ;
str : STRINGLITERAL
    ;

// Variable Declaration
var_decl : var_type id_list SEMICOLON {
            std::vector<std::string*> list = *($2);
            for(int i=(int)list.size()-1;i>=0;--i) {
                if($1 == INT)
                    ST->addDecl(*list[i], "INT");
                else 
                    ST->addDecl(*list[i], "FLOAT");
            }
         }
    ;
var_type : FLOAT { $$ = FLOAT; }
    | INT  { $$ = INT; }
    ;
any_type : var_type {
            $$ = $1;
         }
    | VOID {
        $$ = $1;
    }
    ;
id_list : id id_tail {
            $$ = $2;
            $$->push_back($1);
        }
    ;
id_tail : %empty {
        std::vector<std::string*>* tmp = new std::vector<std::string*>;
        $$ = tmp;
    }
    | COLON id id_tail {
        $$ = $3;
        $$->push_back($2);
    }
    ;

// Function Paramater list
param_decl_list : %empty  
    | param_decl param_decl_tail  
    ;
param_decl : var_type id {
       ST->addDecl(*($2), ($1 == INT) ? "INT" : "FLOAT", 1);
   }
    ;
param_decl_tail : %empty 
    | COLON param_decl param_decl_tail 
    ;

// Function Declarations
func_declarations : %empty 
    | func_decl func_declarations
    ;
func_decl : FUNCTION any_type id
            {
                ST->addTable(*($3));
            }
            BRACKET_OPEN param_decl_list BRACKET_CLOSE _BEGIN func_body END
            {
                ST->pop_table();
            }
    ;
func_body : decl stmt_list 
    ;

// Statement List
stmt_list : %empty 
    | stmt stmt_list
    ;
stmt : base_stmt 
    | if_stmt  
    | for_stmt 
    ;
base_stmt : assign_stmt 
    | read_stmt  
    | write_stmt  
    | return_stmt
    ;

//Basic Statements
assign_stmt : assign_expr SEMICOLON  
    ;
assign_expr : id ASSIGNMENT expr {
            ASTNode* node = new ASTNode_ASSIGN(ST->findEntry(*$1));
            node->right = $3;
            node->getCode(WC);
        }
    ;
read_stmt : READ BRACKET_OPEN id_list BRACKET_CLOSE SEMICOLON {
            std::vector<std::string*> ids = *$3;
            for(int i=(int)ids.size()-1;i>=0;--i) {
                std::string type;
                entry* entr = ST->findEntry(*ids[i]);
                type = entr->type;
                WC->ERread(type, *ids[i]);
            }
      }
    ;
write_stmt : WRITE BRACKET_OPEN id_list BRACKET_CLOSE SEMICOLON { 
            std::vector<std::string*> ids = *$3;
            for(int i=(int)ids.size()-1;i>=0;--i) {
                std::string type;
                if(*ids[i] == "newline") {
                    type = "STRING";
                } else {
                    entry* entr = ST->findEntry(*ids[i]);
                    type = entr->type;
                }
                WC->ERwrite(type, *ids[i]);
            }
       }
    ;
return_stmt : RETURN expr SEMICOLON
    ;

// Expressions
expr: expr_prefix factor {
    if($1 == nullptr) {
            $$ = $2;
        } else {
            $1->right = $2;
            $$ = $1;
        }
    }
    ;
expr_prefix: %empty { $$ = nullptr; }
           | expr_prefix factor addop {
            if ($1 == nullptr) {
                $3->left = $2;
            }
            else {
                $1->right = $2;
                $3->left = $1;
            }
            $$ = $3;
    }
    ;
factor: factor_prefix postfix_expr {
        if ($1 == nullptr)
            $$ = $2;
        else {
            $1->right = $2;
            $$ = $1;
        }
    } 
    ;
factor_prefix: %empty { $$ = nullptr; }
    | factor_prefix postfix_expr mulop {
        if($1 == nullptr) {
            $3->left = $2;
        } else {
            $1->right = $2;
            $3->left = $1;
        }
        $$ = $3;
    }
    ;
postfix_expr: primary { $$ = $1; }
    | call_expr { $$ = nullptr; }
    ;
call_expr : id BRACKET_OPEN expr_list BRACKET_CLOSE
    ;
expr_list: %empty
    | expr expr_list_tail
    ;
expr_list_tail: %empty
    | COLON expr expr_list_tail
    ;
primary: BRACKET_OPEN expr BRACKET_CLOSE  { $$ = $2; }
    | id { $$ = new ASTNode_ID(ST->findEntry(*$1)); }
    | INTLITERAL { $$ = new ASTNode_INT($1); }
    | FLOATLITERAL { $$ = new ASTNode_FLOAT($1); }
    ;
addop: ADD { $$ = new ASTNode_EXPR("+"); }
    | SUB { $$ = new ASTNode_EXPR("-"); }
    ;
mulop: MULT { $$ = new ASTNode_EXPR("*"); } 
    | DIV { $$ = new ASTNode_EXPR("/"); } 
    ;

//Complex Statements
if_stmt : IF 
        {
            ST->addTable();
        }
        BRACKET_OPEN cond BRACKET_CLOSE decl stmt_list 
        {
            WC->lb ++;
            WC->lblist.push_front(WC->lb);
            WC->codelines.push_back(new ERline(WC->symbolTable->STstack.top()->scope, "JUMP", "LABEL"+std::to_string(WC->lb)));
            int x = WC->lblist.back();
            WC->lblist.pop_back();
            WC->codelines.push_back(new ERline(WC->symbolTable->STstack.top()->scope, "LABEL", "LABEL"+std::to_string(x)));
            ST->pop_table();
        }
        else_part FI {
            int x = WC->lblist.front();
            WC->lblist.pop_front();
            WC->codelines.push_back(new ERline(WC->symbolTable->STstack.top()->scope, "LABEL", "LABEL"+std::to_string(x)));
        }
        ;
else_part : %empty 
    | ELSE {
        ST->addTable();
    } 
    decl stmt_list 
    {
        ST->pop_table();
    }
    ;
cond : expr compop expr {
        $2->left = $1;
        $2->right = $3;

        $2->getCode(WC);
     }
    ;
compop : LESSTHAN { $$ = new ASTNode_COND("<"); }
    | GREATERTHAN { $$ = new ASTNode_COND(">"); } 
    | EQUAL { $$ = new ASTNode_COND("="); } 
    | NEQUAL { $$ = new ASTNode_COND("!="); } 
    | LESSTHANEQ { $$ = new ASTNode_COND("<="); } 
    | GREATERTHANEQ { $$ = new ASTNode_COND(">="); } 
    ;
init_stmt : %empty 
    | assign_expr 
    ;
incr_stmt : %empty
    | assign_expr 
    ;
for_stmt : FOR 
    {
        ST->addTable();
    }
    BRACKET_OPEN init_stmt SEMICOLON cond SEMICOLON incr_stmt BRACKET_CLOSE decl stmt_list ROF
    {
        ST->pop_table();
    }
    ;
%%

void yyerror(char const* s){
    /*printf("Not accepted\n");*/
    exit(1);
}

int main() {
    yyparse();
    /*printf("Accepted\n");*/
    //ST->printStack();
    /*WC->print();*/
    /*std::cout << "\n";*/
    for(symbol_table* table : WC->symbolTable->STvector) {
        for(auto i : table->symbolTable) {
            if(i.second.type == "STRING")
                std::cout << "str " << i.first << " " << i.second.value << "\n";
            else 
                std::cout << "var " << i.first << "\n";
        }
    }
    assemblyCode assmCode(WC);
    assmCode.print();
    std::cout << "sys halt\n";
    return 0;
}
