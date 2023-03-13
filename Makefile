OCAMLC = ocamlc
OCAMLYACC = ocamlyacc
OCAMLLEX = ocamllex

all: o

o: ast.cmo parser.cmo scanner.cmo semant.cmo sast.cmo toplevel.cmo
	$(OCAMLC) -o o ast.cmo parser.cmo scanner.cmo semant.cmo sast.cmo toplevel.cmo

ast.cmo: ast.ml
	$(OCAMLC) -c ast.ml

parser.mli parser.ml: parser.mly ast.cmo
	$(OCAMLYACC) parser.mly
	$(OCAMLC) -c parser.mli

parser.cmo: parser.ml parser.mli
	$(OCAMLC) -c parser.ml

scanner.cmo: scanner.ml parser.cmi
	$(OCAMLC) -c scanner.ml

scanner.ml: scanner.mll
	$(OCAMLLEX) scanner.mll

semant.cmo: semant.ml ast.cmo sast.cmo
	$(OCAMLC) -c semant.ml

sast.cmo: sast.ml ast.cmo
	$(OCAMLC) -c sast.ml

toplevel.cmo: toplevel.ml ast.cmo parser.cmo scanner.cmo semant.cmo sast.cmo
	$(OCAMLC) -c toplevel.ml

clean:
	rm -f *.cmo *.cmi parser.ml parser.mli scanner.ml o

.PHONY: all clean
