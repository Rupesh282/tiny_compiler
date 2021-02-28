# makes final target named compiler
compiler : scanner.l microParser.y
	bison -d microParser.y
	flex scanner.l
	gcc microParser.tab.c lex.yy.c -o compiler

dev:
	@echo Rupesh Kalantre
	@echo 180010029@iitdh.ac.in

clean:
	rm -f lex.yy.c
	rm -f compiler
	rm -f microParser.tab.c
	rm -f microParser.tab.h
