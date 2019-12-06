#!/usr/bin/python
import itertools;
from itertools import product;

s = 'A B C D E F G H I J';
#remove spaces between characters:
s = s.replace(" ", "");
#generating all possible substrings including repitions(duplicates):
for p in product(s, repeat = 2):

    #convert the tuples into a string and strip paranthesis:
    myString = ' '.join(map(str, (p)));
    #remove spaces between characters:
    myString = myString.replace(" ", "");
    print(myString);
