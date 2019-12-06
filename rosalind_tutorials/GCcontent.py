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
    head=""
    for line in contents:
        # Get the line with sequence ID:
        if line.startswith(">"):

            if lineCount ==0:
                head=line.strip('>')
            if lineCount == 1:
                GCcontent_percentage= (countGC/countTotal)*100;
                #print(GCcontent_percentage);
                #add the sequence ID (line) and GCcontent_percentage into  the list: 
                GCcontentList.append((head, GCcontent_percentage));

            
            #head=line.strip('>');
            #GCcontentList.append(line.strip('>'));
            # Get total count and GC count of previous sequences:
            if lineCount > 1:
                # get the % of GC count
                GCcontent_percentage= (countGC/countTotal)*100;
                #print(GCcontent_percentage);
                #add the sequence ID (line) and GCcontent_percentage into  the list: 
                GCcontentList.append((line.strip('>'), GCcontent_percentage));
            lineCount+=1
            #print('\n', line, end="");
            # reset the count variables to 0 inorder to count for the next sequence
            countTotal = 0;
            countGC = 0;
        else:
            for nucleotide in line:
                if nucleotide == 'G' or nucleotide == 'C':
                    countGC += 1;
                #count any nucleotide the loop loops through(total nucleotides)
                countTotal +=1;


    # Print the % of GC count of last sequence (because the loop is terminated-
    # no more lines for the loop to carry on looping!)
    GCcontent_percentage= (countGC/countTotal)*100;
    #GCcontentList.append((line.strip('>'), GCcontent_percentage));
    #print(GCcontent_percentage);
     
    #sort the list in descending order:
    # print the list
    print(GCcontentList);
    highestGC = max(GCcontentList,key=lambda item:item[1])
    #print(highestGC);

    # print the sequence ID with the highest GC content with GC content %:
    print(highestGC[0], end="");
    print(highestGC[1]);
   

    
        