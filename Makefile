SRC = src

scanner: flexFile $(SRC)/scanner.h $(SRC)/scanner.c 
	gcc -o $(SRC)/out $(SRC)/scanner.c $(SRC)/lex.yy.c 

flexFile: $(SRC)/scanner.l
	flex -o $(SRC)/lex.yy.c $(SRC)/scanner.l  

test: 
	@./src/out < inputs/$(file).micro > src/out1
	@diff src/out1 outputs/$(file).out -s

dev:
	@echo Rupesh Kalantre
	@echo 180010029@iitdh.ac.in

clean:
	rm $(SRC)/out $(SRC)/lex.yy.c

