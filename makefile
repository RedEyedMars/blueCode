self:
	bison main.y
	g++ -g -o main main.tab.c
	./main < test.z

edit: 
	nano test.z
	make self
