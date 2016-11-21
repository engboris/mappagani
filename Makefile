CC=ocamlc
LIBS=graphics.cma
EXEC=mappagani.exe
SRC=voronoi.cmo mappagani.cmo

all: $(EXEC)

mappagani.exe: 
		$(CC) $(LIBS) -o $@ $(SRC)

%.mli:
		$(CC) -c $<

%.ml: %.mli
		$(CC) -c $<

clean:
		rm -rf *.cmi
		rm -rf *.cmo

mrproper: clean
		rm -rf $(EXEC)