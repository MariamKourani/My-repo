#!/usr/bin/python

from Bio import Entrez
from Bio import SeqIO
import textwrap

lengthList =[]
shortestSeq = ''
shortestSeqInFasta =''
sequence = ''

# Fetching DNA sequence from ncbi in FASTA format:
Entrez.email = "mariam.kourani@cranfield.ac.uk"
handle = Entrez.efetch(db="nucleotide", id=["NM_001251956, JX308815, HM595636, NM_001159758, NM_001079732, JX295575, JX317624, JQ011270, JN698988, NM_131329"], rettype="fasta");

# Get the list of SeqIO objects in FASTA format:
records = list (SeqIO.parse(handle, "fasta"));

# Get the length of each sequence:
for record in records:
    seqLength = len(record.seq);
    lengthList.append(seqLength);
print(lengthList);

# Shortest Length:
shortestLength = min(lengthList);
print(shortestLength);


# Get the shortest sequence in fasta format:
for record in records:
    if len(record.seq) == shortestLength:
        shortestSeq = record;   
        shortestSeqInFasta = (">%s %s\n%s\n" % (
            shortestSeq.id,
            shortestSeq.description,
            shortestSeq.seq));
        #print(shortestSeqInFasta)

# write 70 characters per line:
with open('out.txt', 'w') as f:
    for line in shortestSeqInFasta.splitlines():
        if line.startswith(">"):
            print (line, file=f);
        else:
            line = line.strip('\n');
            sequence = "".join(line)
            print ('\n'.join(textwrap.wrap(sequence, 70)), file=f);

