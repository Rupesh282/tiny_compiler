compiler:
	bison -d -t -o parser.cpp parser.yy
	flex scanner.ll
	g++ -std=c++11 -o compiler main.cpp lex.yy.c parser.cpp Scope.cpp Symbol.cpp ASTNode.cpp Tiny.cpp 

clean:
	@rm -f *.o parser.cpp lex.yy.c compiler *.out parser.hpp

dev:
	@echo Rupesh Kalantre
	@echo 180010029@iitdh.ac.in

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
