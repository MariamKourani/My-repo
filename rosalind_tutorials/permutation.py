#!/usr/bin/python
import itertools
from itertools import permutations
from math import factorial

n = int(input("Input number to generate permutation list: "));

#total number of permutations of length n:
factorial_func = factorial(n);
print("The total number of permutations of length n: ", factorial_func);

#generate a list of possible permutations of length n:
permList = list(range(1, n+1));

# print the permutation lists:
perm = itertools.permutations(permList);

f = open("permutationOutput.txt", "a");
print("The total number of permutations of length n: ", factorial_func, file=f);

for i in list(perm):
    #print(i);
    #convert the tuples into a string and strip paranthesis:
    myString = ' '.join(map(str, (i)));
    print(myString, file=f)
f.close()

