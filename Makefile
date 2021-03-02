# makes final target named compiler
compiler : scanner.l microParser.y symboltable.cc
	bison -d microParser.y
	flex scanner.l
	g++ microParser.tab.c lex.yy.c -o compiler

dev:
	@echo Rupesh Kalantre
	@echo 180010029@iitdh.ac.in

clean:
	rm -f lex.yy.c
	rm -f compiler
	rm -f microParser.tab.c
	rm -f microParser.tab.h

tag:
	git tag -a pa3submission -m "submission for PA3"

pushtag:
	git push --tags

ftag:
	git tag -a -f pa3submission -m "submission for PA3"

fpushtag:
	git push -f --tags
