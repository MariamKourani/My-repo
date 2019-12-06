#!/usr/bin/python

import re
import Bio
from Bio import SeqIO
import requests
import urllib
from urllib.request import urlopen

#read uniprot record in an xml file and print part of that file:
handle = urllib.request.urlopen("http://www.uniprot.org/uniprot/Q8CWR2.xml")
record = SeqIO.read(handle, "uniprot-xml")
#print(record);
print(record.annotations['comment_catalyticactivity']);