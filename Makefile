
test:
	echo "This is a test..."

build:
	echo "This is a build..."

graph.svg: graph.dot
	dot -Tsvg $^ > graph.svg
graph.dot: *.tf
	terraform graph > graph.dot
