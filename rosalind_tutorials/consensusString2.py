#!/usr/bin/python

#read line by line and go to each sequence:
with open("singleLineFasta.txt", 'r') as contents:
    count = {letter: [0] * 917 for letter in 'ACGT'};
    column_dict ={}
    consensusSeq = []
    #loop through each line
    for line in contents:
        if not line.startswith(">"):
            for i, letter in enumerate(line.strip()):
                count[letter][i] +=1;

    for i in range(917):
        for letter, row in count.items():       
            #add each column to a separate dict with its corresponding keys:
            column_dict[letter] = row[i];
            #get the KEY that correspond to the maximum value
            max_base = max(column_dict, key=column_dict.get);
        #append the maximum base(key) into a list
        consensusSeq.append(max_base);
        i +=1;
    # open a file to write the sequences into:
    with open('consensusSequence.txt','w') as f:
    #print list elements without whitespaces:
        print(''.join(str(i) for i in consensusSeq), file=f);
        #print(''.join(letter), ':', *row)
      
        for letter, row in count.items():
        #use * to unpack the list (remove brackets)
            #letter.replace(' ', '')
            output = (letter,':', *row);
            print(letter,':', *row, file=f);
    f.close()
            #sprint(count)

            #f.write(str(count));
            #for tuple in output:
                #f.write(str(tuple)),'\n';
                #print('\n');
        #print (letter,':', *row);