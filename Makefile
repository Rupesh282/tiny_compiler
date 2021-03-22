# makes final target named compiler
compiler : scanner.l microParser.y symboltable.hpp ast.hpp codeStruct.hpp assembly.hpp
	bison -d microParser.y
	flex scanner.l
	g++ -std=c++11 microParser.tab.c lex.yy.c -o compiler

dev:
	@echo Rupesh Kalantre
	@echo 180010029@iitdh.ac.in

clean:
	rm -f lex.yy.c
	rm -f compiler
	rm -f microParser.tab.c
	rm -f microParser.tab.h
	rm -f tiny

tag:
	git tag -a pa5submission -m "submission for PA5"

pushtag:
	git push --tags

ftag:
	git tag -a -f pa5submission -m "submission for PA5"

fpushtag:
	git push -f --tags


tiny:
	g++ -o tiny tinyNew.c
