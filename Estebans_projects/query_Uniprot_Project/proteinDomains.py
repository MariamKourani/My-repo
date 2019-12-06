#!/usr/bin/python
import uniprot
import requests
import json
import urllib
import urllib.parse
import urllib.request
from urllib.request import urlopen

#open and load .json file:
with open('ResultsOriginal.json', 'r') as input_file:
    json_decode=json.load(input_file);
    # extract Uniprot IDs for each reference protein from results.json file and store in 'query':
    query = '';
    for key, value in json_decode['reference'].items():
        key = key + (' ');
        query += key;
    #run request for all the protein IDs to get their entries from Uniprot(batch retrieval):
    url = 'https://www.uniprot.org/uploadlists/' 

    params = {
        'from':'ACC+ID',
        'to':'ACC',
        'format':'tab',
        'columns':'id,feature(DOMAIN EXTENT),genes,go-id,go',
        'query': query,
    }
 
    data = urllib.parse.urlencode(params);
    data = data.encode('utf-8');
#try:
    request = urllib.request.Request(url, data);  
    contact = "mariam.kourani@live.com";  
    request.add_header('User-Agent', 'Python contact'); 
    response = urllib.request.urlopen(request);
    entries = response.read();
    entries = entries.decode('utf-8');
    
    #split by (\n) to remove first row (headers) and get the entries:
    entries = entries.split('\n')[1:];
    #for key, value in json_decode['reference'].items():
    for entry in entries:         
        key = entry.split('\t')[0]
        # get protein domains from Uniprot entries":    
        if len(entry) != 0:
            if 'DOMAIN' not in entry:
                #key = entry.split('\t')[5]
                domain = [];
                #add gene names
                geneNames = entry.split("\t")[2];
                #add GO terms
                goTermsDict = {}
                goIds = entry.split("\t")[3];
                goTerms = entry.split("\t")[4];
                goTermsDict = {"GO IDs" :goIds, "GO terms":goTerms}
                #append to .json file:
                json_decode['reference'][key].update({'Domains': domain, 'Gene Names': geneNames, 'GOterms': goTermsDict});
                #print(domain)
                #key = key.strip(' ')
                print(key, "updatedA")
            elif entry.count("DOMAIN") == 1:
                #key = entry.split('\t')[5]
                domainList = entry.split("\t")[1];
                domain = domainList.split();
                #populate the dictionary with domain details: 
                domainDict = {};
                domainDict = {"start": domain[1], "end": domain[2], "description":  " ".join(domain[3:])}                
                #add domainDict into a list:
                domainList =[];
                domainList.append(domainDict);
                #add gene names
                geneNames = entry.split("\t")[2];
                #add GO terms
                goTermDict = {}
                goIds = entry.split("\t")[3];
                goTerms = entry.split("\t")[4];
                goTermsDict = {"GO IDs" :goIds, "GO terms":goTerms}
                #append to .json file:
                json_decode['reference'][key].update({'Domains': domainList, 'Gene Names': geneNames,'GOterms': goTermsDict});
                print(key, "updatedB")           
            else:
                listOfDic= [];
                #for domain in domainList:
                domainList = entry.split("\t")[1];
                domainList = domainList.split(".; ");
                for domain in domainList:   
                    domain = domain.split();
                    #populate the dictionary with domain details:
                    domainDict = {};
                    domainDict = {"start": domain[1], "end": domain[2], "description":  " ".join(domain[3:])}
                    listOfDic.append(domainDict);
                #add gene names
                geneNames = entry.split("\t")[2];
                #add GO terms
                GOTermDict = {}
                goIds = entry.split("\t")[3];
                goTerms = entry.split("\t")[4];
                goTermsDict = {"GO IDs" :goIds, "GO terms":goTerms}
                #append to .json file:
                json_decode['reference'][key].update({'Domains': listOfDic,'Gene Names': geneNames, 'GOterms': goTermsDict});
                print(key, "updatedC")
                listOfDic= [];
        else:
            #obsoleteID = ''
            #obsoleteID = proteinID + ":" + "This entry is obsolete as returned by Uniprot";
            #json_decode['reference'][key].update({'domain': obsoleteID});
            json_decode['reference'][key].update({'domain': "no entry on uniprot"});
            print(key, "updatedD")
#except: 
    #print ("waiting for Uniprot");
#edit .json file           
        with open('ResultsOriginal.json', 'w') as updated_jsonFile:
            json.dump(json_decode, updated_jsonFile, indent=2);

        

    




        
