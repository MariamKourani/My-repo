#!/usr/bin/python

# Import pairwise2 module
from Bio import pairwise2
# Import format_alignment method
from Bio.pairwise2 import format_alignment
from Bio import Entrez
from Bio import SeqIO

# Define two sequences to be aligned

#X = "AT"

#Y = "ACG"

#read the sequences line by line:
#open a file to read the seq into it:
headerSeq1 = ''
headerSeq2 = ''
lineList1= []
lineList2= []
str1 = ''
str2 = ''
alignmentAndScore =''
# Fetching DNA sequence from ncbi in FASTA format:
Entrez.email = "mariam.kourani@cranfield.ac.uk"
handle_seq1 = Entrez.efetch(db="nucleotide", id=["NM_131329.3"], rettype="fasta");

handle_seq2 = Entrez.efetch(db="nucleotide", id=["NM_000641.3"], rettype="fasta");


# Get the list of SeqIO objects in FASTA format:
records_seq1 = SeqIO.parse(handle_seq1, "fasta");
records_seq2 = SeqIO.parse(handle_seq2, "fasta");

#get the fasta format of each sequence:
for record in records_seq1:
    seq1 = record.format("fasta");
#print(seq1);

for record in records_seq2:
    seq2 = record.format("fasta")
#print(seq2);

#convert the sequence list into a string:
for line in seq1.splitlines():
    if line.startswith(">"):
        headerSeq1 += line;
    else:
        line = line.strip('\n');
        lineList1.append(line);
        #list into string:
    str1 = ''.join(str(e) for e in lineList1);

#convert the sequence list into a string:
for line in seq2.splitlines():
    if line.startswith(">"):
        headerSeq2 += line;
    else:
        line = line.strip('\n');
        lineList2.append(line);
    #list into string:
    str2 = ''.join(str(e) for e in lineList2);

# align the two strings
# A match score is the score of identical chars, else mismatch score.
# Same open and extend gap penalties for both sequences.

alignments = pairwise2.align.globalms(str1, str2, 5, -4, -10, -1)

# Use format_alignment method to format the alignments in the list
for a in alignments:
    alignmentAndScore = format_alignment(*a)
print (alignmentAndScore);