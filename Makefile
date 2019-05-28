.SUFFIXES: .c .h .l .o .y
.PHONY: all clean dist install \
        oakc

OAKCOBJS = syntax.o parser.o lexer.o compiler.o oakc.o
OAKCLIBS = -ll -ly

all: oakc

clean:
	rm -f oakc parser.h ${OAKCOBJS}
	rm -f y.output

dist:
	@echo "Not supported yet"

install:
	@echo "Not supported yet"

oakc: ${OAKCOBJS}
	${CC} ${OAKCLDFLAGS} -o $@ $^ ${OAKCLIBS}

.y.c:
	${YACC} -dt --debug --verbose $<
	mv -f y.tab.h $*.h
	mv -f y.tab.c $@

.l.c:
	${LEX} -t $< > $@

.c.o:
	${CC} ${CFLAGS} -c $*.c
