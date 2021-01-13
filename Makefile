SRC = src

# makes final target named compiler
compiler: flexFile 
	gcc -o $(SRC)/compiler $(SRC)/lex.yy.c 

flexFile: $(SRC)/scanner.l
	flex -o $(SRC)/lex.yy.c $(SRC)/scanner.l  

# how to use : $ make check_diff file=fibonacci
check_diff: 
	@diff $(SRC)/output.txt outputs/$(file).out -s

dev:
	@echo Rupesh Kalantre
	@echo 180010029@iitdh.ac.in

clean:
	rm $(SRC)/compiler $(SRC)/lex.yy.c $(SRC)/output.txt

