#!/usr/bin/python
from collections import OrderedDict
from itertools import chain

listOfMotifs = [];

header ='';
# open a file to read the protein accession numbers:
with open('motif_1_fasta.txt','r') as f:
#get fasta sequence from uniprot for each protein:
        contents = f.readlines();
        for line in contents:
            if line.startswith(">"):
                header += line;
            else:
                line = line.strip('\n');
                listOfMotifs.append(line);
        #transpose each motif to generat a string of each index
        transposedIndex = [''.join(s) for s in zip(*listOfMotifs)]
        #find unique characters in each transposed string:
        stringConcat = '';
        for string in transposedIndex:
            
            #fromkeys method: creates a dictionary 
            #access the keys of the dictionary
            #OrderedDict keeps the order of the keys and values
            od = OrderedDict.fromkeys(string).keys();        
            if len(od)> 1:
            
            #add square brackets if more than one AA could exist at a certain index:
            #newlist = [];
                stringConcat = "[";
                for key in od:
                    stringConcat = stringConcat + key;
                stringConcat = stringConcat + "]";
                #stringConcat = key;
            else:
                for key in od:
                    stringConcat = key;
            print(stringConcat, end ="");