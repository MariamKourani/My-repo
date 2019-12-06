#!/usr/bin/python

#read line by line and go to each sequence:
with open("exampleFasta.txt", 'r') as contents:
    header_line = '';
    # open a file to write the sequences into:
    with open('sequenceFile.txt','w') as f:
        #loop around each line
        for line in contents:
            if line.startswith(">"):
            #if its a header line, append it to the header variable
                header_line += line;
            else:
            #if not a header line(if sequence), write the sequence into a file
                print(line, end="");
                f.write(line);
        print('\n');



#for letter in 'ACTG':
    #count = {letter:[0]*8};
with open("sequenceFile.txt", 'r') as myFile:
    #initialising an empty dict with keyes (letter) and values (empty lists):
    count = {letter: [0] * 8 for letter in 'ACGT'};

    for line in myFile.readlines():
        for i, letter in enumerate(line.strip()):
            count[letter][i] +=1;

    
    
    column_dict ={}
    consensusSeq = []
    #columnlist_List =[]
    #i=0;
    for i in range(8):
        for letter, row in count.items():       
            #add each column to a separate dict with its corresponding keys:
            column_dict[letter] = row[i];
            #get the KEY that correspond to the maximum value
            max_base = max(column_dict, key=column_dict.get);
        #append the maximum base(key) into a list
        consensusSeq.append(max_base);
        i +=1;
    #unpack the list-print elements without brackets:
    #print(*consensusSeq);
    #print list elements without whitespaces:
    print(''.join(str(i) for i in consensusSeq))
        
    for letter, row in count.items():
       #use * to unpack the list (remove brackets)
        print (letter,':', *row);
            
            
            
            
            
            
            #columnlist.append(row[i]);
        #print(columnList);
        #maxValue = max(columnList);
        #print(maxValue);
        #maxValues_dict.append(maxValue);
        #column_dict ={}
        #columnList =[];
    
    
    #print(maxValuesList)

    #for letter, row in count.items(): 

    
    
            
        #maxValues = max(columnList);
        #print(maxValues)
        #maxValuesList.append(maxValues);
        
    #print(maxValuesList)
       
    #print(maxValuesList);
    
    #print(letter, consensusBase)
    #print(count.keys)
        
       
            
