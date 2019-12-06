#!/usr/bin/python
#firstValue= 1;
#secondValue = 1;

def fibRabbits(n,k):
    if n ==0:
        return 0;
    elif n<3:
        return 1;
    else:
        return fibRabbits(n-2,k)*k + fibRabbits(n-1,k);

n= int(input("Enter the value of n: "));
k= int(input("Enter the value of k: "));
print(fibRabbits(n,k));

#def rabbits(n,k):
    #if n == 1 or n== 2:
        #return 1; 
    #else:
        #return (fibValue(n));
    #print(rabbits(5,3));