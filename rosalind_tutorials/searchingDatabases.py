#!/usr/bin/python

from Bio import Entrez

Entrez.email = "mariam.kourani@cranfield.ac.uk";
handle = Entrez.esearch(db="nucleotide", term='"Cautleya"[Organism] OR "Cautleya"[All Fields] AND (plants[filter] AND ("2000/01/12"[PDAT] : "2012/08/28"[PDAT]))');
record = Entrez.read(handle);
print(record["Count"]);