#!/usr/bin/python

a = ['c', 'd', 'B', 'a', 'e']
b = ['a001', 'B002', 'c003', 'd004', 'e005']
c = sorted(b, key = lambda x: a.index(x[0])) 
print(c)