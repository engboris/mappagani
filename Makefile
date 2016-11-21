CC=ocamlc
LIBS=graphics.cma
EXEC=mappagani.exe

all: $(EXEC)

mappagani.exe: voronoi.cmo mappagani.cmo
		$(CC) $(LIBS) -o $@ $^

%.cmo: %.ml %.mli
		$(CC) -c $<

clean:
		rm -rf *.cmi
		rm -rf *.cmo

mrproper: clean
		rm -rf $(EXEC)
