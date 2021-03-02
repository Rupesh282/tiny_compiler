%{
    void yyerror(char const *s);
    extern char* yytext;
    extern "C" int yylex();
    #include "symboltable.cc"
    ST_stack ST;
%}

%code requires {
    #include<iostream>
    #include<string>
    #include<vector>
    #include<utility>
}

%token PROGRAM _BEGIN END IDENTIFIER STRINGLITERAL STRING FLOAT FLOATLITERAL INT INTLITERAL VOID FUNCTION READ WRITE RETURN IF FI ELSE FOR ROF ADD SUB MULT DIV EQUAL NEQUAL EXCL LESSTHAN GREATERTHAN LESSTHANEQ GREATERTHANEQ BRACKET_OPEN BRACKET_CLOSE SEMICOLON COLON ASSIGNMENT 

%union {
    int intval;
    float floatval;
    std::string* strval;
    std::vector<std::string*>* strlist;
}

%type <strval> str id IDENTIFIER STRINGLITERAL 
%type <strlist> id_list id_tail 
%type <intval> var_type INT any_type VOID
%type <floatval> FLOAT

%%

// Program
program :   PROGRAM id _BEGIN 
            { ST.addTable("GLOBAL"); }
            pgm_body END
            { ST.pop_table(); } 
            ;
id : IDENTIFIER
    ;
pgm_body : decl func_declarations
    ;
decl : 
    %empty
    | string_decl decl
    | var_decl decl
    ;

// Global String Declaration
string_decl : STRING id ASSIGNMENT str SEMICOLON 
            { ST.addDecl(*($2), "STRING", *($4)); }
    ;
str : STRINGLITERAL
    ;

// Variable Declaration
var_decl : var_type id_list SEMICOLON {
            std::vector<std::string*> list = *($2);
            for(int i=(int)list.size()-1;i>=0;--i) {
                if($1 == INT)
                    ST.addDecl(*list[i], "INT");
                else 
                    ST.addDecl(*list[i], "FLOAT");
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
       ST.addDecl(*($2), ($1 == INT) ? "INT" : "FLOAT", 1);
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
                ST.addTable(*($3));
            }
            BRACKET_OPEN param_decl_list BRACKET_CLOSE _BEGIN func_body END
            {
                ST.pop_table();
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
assign_expr : id ASSIGNMENT expr
    ;
read_stmt : READ BRACKET_OPEN id_list BRACKET_CLOSE SEMICOLON 
    ;
write_stmt : WRITE BRACKET_OPEN id_list BRACKET_CLOSE SEMICOLON
    ;
return_stmt : RETURN expr SEMICOLON
    ;

// Expressions
expr: expr_prefix factor
    ;
expr_prefix: %empty
    | expr_prefix factor addop
    ;
factor: factor_prefix postfix_expr
    ;
factor_prefix: %empty
    | factor_prefix postfix_expr mulop
    ;
postfix_expr: primary
    | call_expr
    ;
call_expr : id BRACKET_OPEN expr_list BRACKET_CLOSE
    ;
expr_list: %empty
    | expr expr_list_tail
    ;
expr_list_tail: %empty
    | COLON expr expr_list_tail
    ;
primary: BRACKET_OPEN expr BRACKET_CLOSE 
    | id
    | INTLITERAL
    | FLOATLITERAL
    ;
addop: ADD
    | SUB
    ;
mulop: MULT
    | DIV
    ;

//Complex Statements
if_stmt : IF 
        {
            ST.addTable();
        }
        BRACKET_OPEN cond BRACKET_CLOSE decl stmt_list 
        {
            ST.pop_table();
        }
        else_part FI 
    ;
else_part : %empty 
    | ELSE {
        ST.addTable();
    } 
    decl stmt_list 
    {
        ST.pop_table();
    }
    ;
cond : expr compop expr
    ;
compop : LESSTHAN 
    | GREATERTHAN 
    | EQUAL 
    | NEQUAL 
    | LESSTHANEQ 
    | GREATERTHANEQ
    ;
init_stmt : %empty 
    | assign_expr 
    ;
incr_stmt : %empty
    | assign_expr 
    ;
for_stmt : FOR 
    {
        ST.addTable();
    }
    BRACKET_OPEN init_stmt SEMICOLON cond SEMICOLON incr_stmt BRACKET_CLOSE decl stmt_list ROF
    {
        ST.pop_table();
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
    ST.printStack();
    return 0;
}
