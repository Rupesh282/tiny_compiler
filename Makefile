# makes final target named compiler
compiler: flexFile.c
	gcc -o $@ $^

flexFile.c: scanner.l
	flex -o $@ $^  

dev:
	@echo Rupesh Kalantre
	@echo 180010029@iitdh.ac.in

clean:
	rm flexFile.c

re:
	rm compiler
