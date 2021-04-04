# makes final target named compiler
compiler : scanner.l microParser.y symboltable.hpp ast.hpp codeStruct.hpp assembly.hpp
	bison -d microParser.y
	flex scanner.l
	g++ -std=c++11 -g microParser.tab.c lex.yy.c -o  compiler 

dev:
	@echo Rupesh Kalantre
	@echo 180010029@iitdh.ac.in

clean:
	rm -f lex.yy.c
	rm -f compiler
	rm -f microParser.tab.c
	rm -f microParser.tab.h
	rm -f tiny
	rm -f tinyold

tag:
	git tag -a pa6submission -m "submission for PA6"

pushtag:
	git push --tags

ftag:
	git tag -a -f pa6submission -m "submission for PA6"

fpushtag:
	git push -f --tags


tiny:
	g++ -o tiny tiny.cc

tinyold:
	g++ -o tinyold tinyold.cc
