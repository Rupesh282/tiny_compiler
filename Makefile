SRC = src

# makes final target named compiler
compiler: flexFile 
	gcc -o $(SRC)/compiler $(SRC)/lex.yy.c 

flexFile: $(SRC)/scanner.l
	flex -o $(SRC)/lex.yy.c $(SRC)/scanner.l  

dev:
	@echo Rupesh Kalantre
	@echo 180010029@iitdh.ac.in

clean:
	rm $(SRC)/compiler $(SRC)/lex.yy.c 
