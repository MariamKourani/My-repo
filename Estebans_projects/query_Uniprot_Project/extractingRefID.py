#!/usr/bin/python

import json

#open .json file and output results into a new .json file:
input_file=open('results_NoIsoforms_Copy.json', 'r')
output_file=open('refIDs.json', 'w')
json_decode=json.load(input_file)

# extract the Uniprot IDs for each reference protein from results.json file
for key , values in json_decode['reference'].items():
    #print (key)
    print (key, file = output_file);

   