CC      ?= cc
SOURCES = player
OBJS    = $(SOURCES:%=%.o)
FLAGS   = -lSDL2 -lSDL2_ttf

main_c: main.c $(OBJS)
	$(CC) $(FLAGS) -o $@ $^

game.native: game.ml entity.ml player.ml renderer.ml results.ml sprite.ml sprite_entity.ml text.ml
	ocamlbuild -use-ocamlfind $@

$(OBJS): %.o: %.c %.h
	$(CC) $(FLAGS) -c $^

clean:
	-rm $(OBJS) main_c
	-rm game.native

.PHONY: clean
