# Makefile for asgn 2 Scanner

GPP      = g++ -g -O0 -Wall -Wextra -std=gnu++14   
MKDEPS   = g++ -std=gnu++14 -MM

MKFILE   = Makefile
DEPSFILE = Makefile.dep
SOURCES  = aux_lib.cpp string_set.cpp oc.cpp lyutils.cpp astree.cpp
HEADERS  = aux_lib.h string_set.h
OBJECTS  = ${SOURCES:.cpp=.o} ${CLGEN:.cpp=.o} ${CYGEN:.cpp=.o}
EXECBIN  = oc
SRCFILES = ${HEADERS} ${SOURCES} ${MKFILE}

LSOURCES = scanner.l
YSOURCES = parser.y
CLGEN    = yylex.cpp
HYGEN    = yyparse.h
CYGEN    = yyparse.cpp
LREPORT  = yylex.output
YREPORT  = yyparse.output

all : ${HYGEN} ${EXECBIN}

${EXECBIN} : ${OBJECTS}
	${GPP} ${OBJECTS} -o ${EXECBIN}

%.o : %.cpp
	${GPP} -c $<

ci :
	cid + ${SRCFILES}

clean :
	-rm ${OBJECTS} ${DEPSFILE} ${CLGEN} ${HYGEN} ${CYGEN} \
	${LREPORT} ${YREPORT}

spotless : clean
	- rm ${EXECBIN}

${CLGEN} : ${LSOURCES}
	flex --outfile=${CLGEN} ${LSOURCES} 2>${LREPORT}


${CYGEN} ${HYGEN} : ${YSOURCES}
	bison --defines=${HYGEN} --output=${CYGEN} ${YSOURCES} \
        2>${YREPORT}

${DEPFILE} :
	${MKDEP} ${SOURCES} >${DEPFILE}

deps :
	-rm {DEPFILE}
	${MAKE} --no-print-directory ${DEPFILE}


include ${DEPFILE}

