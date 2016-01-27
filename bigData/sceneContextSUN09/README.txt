This directory contains data derived from
 http://web.mit.edu/~myungjin/www/HContext.html
which has N=4367 training and 4317 test images,
each annotated with D=111 categories.

We store the following files: each line is a row in the matrix,
columns separated by commas:

- presence.txt is a N*D bitvector representing
whether object d is present in image n

- maxscores.txt is an N*D real vector representing
the maximum score of detector class d in image n

- names.txt is a list of the 111 category names

The images themselves can be obtained from the above
web site.
