#!/usr/bin/python
import itertools
from itertools import combinations
from itertools import permutations

s ='D N A';
listS= list(s);
#remove spaces between characters:
s = s.replace(" ", "");

finalOutput = [];
#for i in s:
for r in range(1,4):
    #get all the possible combinations:
    perms = itertools.product(s, repeat = r);
    # print them:
    for j in perms:
    # convert the tuples into a string and strip paranthesis:
        myString = ' '.join(map(str, (j)));
        myString = myString.replace(" ", "");
        finalOutput.append(myString)
print(finalOutput);
        
        
        
        
        
        
        
        
        
        #finalOutput.append(myString);
        #finalOutput.append(myString);
        #print(myString);
"""print(listS);
print(finalOutput);
#sorted = sorted(finalOutput);
#print(sorted);

for findable in listS:
    for element in finalOutput:
        if findable in element:
            print (element); 
#c = sorted(finalOutput, key = lambda e: listS.index(e[0]));
#print(c);
       
           
           # print(myString);

#f.close()


for c1 in s:
    for c2 in s:
        for c3 in s:
            print(c1 + c2, c3);
        
"""


#permList = list(range(1, length+1));
#print (list(s));

      


    #print(i);
   
        
#pool = tuple(s);
#length = len(pool);
#print(perms);




# print(perms);
#myString = ' '.join(map(str, (perms)));
#print(myString);
