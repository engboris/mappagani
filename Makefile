CC=ocamlc
LIBS=graphics.cma
EXEC=mappagani.exe
SRC=voronoi.cmo mappagani.cmo

all: $(EXEC)

mappagani.exe: %.cmo
		$(CC) $(LIBS) -o $@ $(SRC)

%.cmo: %ml %.mli
		$(CC) -c $<

clean:
		rm -rf *.cmi
		rm -rf *.cmo

mrproper: clean
		rm -rf $(EXEC)
