#!/usr/bin/python

#read line by line and go to each sequence:
f = open("rosalind_gc.txt", "r")
if f.mode == "r":   
    contents = f.readlines();
    #initialize count variables:
    countTotal = 0;
    countGC =0;
    head ="";
    # initialise an Empty list to store the seq ID and theGC content %:
    GCcontentList = [];
    lineCount = 0;
    
    for line in contents:
        # Get the line with sequence ID:
        if line.startswith(">"):
            # 1st sequence:
            if lineCount ==0:
                head=line.strip('>')
            if lineCount > 0:
                # GC content of previous sequence:
                GCcontent_percentage= (countGC/countTotal)*100;
                #add the sequence ID (line) and GCcontent_percentage into the list: 
                GCcontentList.append((head, GCcontent_percentage));
                #re set the head to carry the new sequence line ID:
                head=line.strip('>');
            # sequence index
            lineCount+=1
            # reset the count variables to 0 inorder to count for the next sequence
            countTotal = 0;
            countGC = 0;
        else:
            line = line.rstrip('\n');
            for nucleotide in line:
                if nucleotide == 'G' or nucleotide == 'C':
                    countGC += 1;
                #count any nucleotide the loop loops through(total nucleotides)
                countTotal +=1;


    # Print the % of GC count of last sequence (because the loop is terminated-
    # no more lines for the loop to carry on looping!)
    GCcontent_percentage= (countGC/countTotal)*100;
    GCcontentList.append((head, GCcontent_percentage));
     
    #sort and print the list in descending order:
    #print(GCcontentList);
    highestGC = max(GCcontentList,key=lambda item:item[1]);

    # print the sequence ID with the highest GC content with GC content % (take 1st & 2nd index from tuple):
    print(highestGC[0], end="");
    print(highestGC[1]);
