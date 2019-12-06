#!/usr/bin/python
import requests as r
import urllib
from urllib.request import urlopen
import re

# open a file to read the protein accession numbers:
with open('rosalind_mprt.txt','r') as f:
#get fasta sequence from uniprot for each protein:
    line = f.readlines();
    for proteinAccession in line:
        proteinAccession = proteinAccession.strip('\n');
        # Get the protein sequence from uniprot through its url:
        sequence = urllib.request.urlopen("http://www.uniprot.org/uniprot/" + str(proteinAccession) + ".fasta");
        print(sequence);
        seq ='';
        for xline in sequence:
            if xline.decode('utf8').startswith(">"):
                header = xline;
            else:
                xline = xline.decode('utf8').rstrip('\n');
                seq +=xline;
        print(proteinAccession);
        #print(seq);
        #remove non alpha characters from the protein sequence:
        seq = re.sub("[^a-zA-Z]+", "", seq);
        #get the index of the location of the N-glycosylation motif:
        #for i in seq.index(seq, beg = 1 end = len(seq)):
        for i in range(0, len(seq), 1):
            if seq[i] == 'N':
                if seq[i+1] != 'P':
                    if seq[i+2] == 'S' or seq[i+2] == 'T':
                        if seq[i+3] != 'P':
                            print (i+1, end=" ");

