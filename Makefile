
all: flex bison program
	
flex: malloytrendley.l
	flex malloytrendley.l
	
bison:
	bison malloytrendley.y
	
program:
	g++ malloytrendley.tab.c -o parser
	

	
