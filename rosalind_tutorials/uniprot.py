#!/usr/bin/python
import re
import urllib
from urllib.request import urlopen

#get the GO terms from Uniprot (this url gets all GO terms):
proteinData = urllib.request.urlopen("http://www.uniprot.org/uniprot/?query=Q8CWR2&format=tab&columns=go");
data = proteinData.read();
decodedData= data.decode("utf-8");
#print GO terms:
print(decodedData);


#get the required format:
firstPass = decodedData.split("\n")
secondPass = firstPass[1]
thirdPass = secondPass.split(";")
#keep only the biological processes:
del thirdPass[0:4]
for item in thirdPass:
    #strip by whitespaces:
    stripped = item.strip();
    #take from the stripped whitespace position up until the index of the square bracket[GOtermID]:
    GO_terms = stripped[:stripped.rfind(' ')] + "\n";
        #remove empty lines between each GO term:
    GO_terms = GO_terms.rstrip();
    print(GO_terms);
    
    


"""
#file.close()
"""