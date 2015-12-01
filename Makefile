CAML_LIBS = -package yojson

C_LIBS = -lcurl

SOURCES = caml_http.c http.ml apiTypes.ml convert.ml print.ml request.ml main.ml

OUT_NAME = lendc

build: $(SOURCES)
	ocamlfind ocamlopt -o $(OUT_NAME) $(CAML_LIBS) -linkpkg \
          unix.cmxa $(SOURCES) -cclib $(C_LIBS)
	strip $(OUT_NAME)

clean:
	rm *.cm* *.o
