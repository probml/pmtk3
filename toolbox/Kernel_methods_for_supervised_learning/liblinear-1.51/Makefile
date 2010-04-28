CXX ?= g++
CC ?= gcc
CFLAGS = -Wall -Wconversion -O3 -fPIC
LIBS = blas/blas.a
#LIBS = -lblas

all: libLinearTrain libLinearPredict

libLinearTrain: tron.o linear.o libLinearTrain.c blas/blas.a
	$(CXX) $(CFLAGS) -o libLinearTrain libLinearTrain.c tron.o linear.o $(LIBS)

predict: tron.o linear.o libLinearPredict.c blas/blas.a
	$(CXX) $(CFLAGS) -o libLinearPredict libLinearPredict.c tron.o linear.o $(LIBS)

tron.o: tron.cpp tron.h
	$(CXX) $(CFLAGS) -c -o tron.o tron.cpp

linear.o: linear.cpp linear.h
	$(CXX) $(CFLAGS) -c -o linear.o linear.cpp

blas/blas.a:
	cd blas; make OPTFLAGS='$(CFLAGS)' CC='$(CC)';

clean:
	cd blas;	make clean
	cd matlab;	make clean
	rm -f *~ tron.o linear.o libLinearTrain libLinearPredict
