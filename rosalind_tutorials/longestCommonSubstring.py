#!/usr/bin/python

#read line by line and go to each sequence:
with open("rosalind_lcsm.txt", 'r') as contents:
    fastaSequences = [];
    seq ='';
    #loop through each line and save each sequence as a string in a list:
    for line in contents:
        if not line.startswith(">"):
            line=line.rstrip('\n');
            seq +=line;
        else:
            #if seq not empty(to avoid appending an empty string to the list at the begining)
            if seq:
                fastaSequences.append(seq);
                seq=''; 
    #append last seq:
    fastaSequences.append(seq);
    #print(fastaSequences)
   
def long_substr(fastaSequences):
    substr = ''
    if len(fastaSequences) > 1 and len(fastaSequences[0]) > 0:
        for i in range(len(fastaSequences[0])):
            for j in range(len(fastaSequences[0])-i+1):
                if j > len(substr) and is_substr(fastaSequences[0][i:i+j], fastaSequences):
                    substr = fastaSequences[0][i:i+j]
    return substr

def is_substr(find, fastaSequences):
    if len(fastaSequences) < 1 and len(find) < 1:
        return False
    for i in range(len(fastaSequences)):
        if find not in fastaSequences[i]:
            return False
    return True


print (long_substr(fastaSequences));