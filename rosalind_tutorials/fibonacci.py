#!/usr/bin/python
i=1;
firstGen = 1;
secondGen = 1;
n=5;
while (i<=n):
    if (i <= 1):
        next = i;
    else: 
        next = firstGen + secondGen;
        firstGen = secondGen;
        secondGen = next;
    print(next);
    i = i + 1;

