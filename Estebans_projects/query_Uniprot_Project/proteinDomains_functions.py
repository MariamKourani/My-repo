#!/usr/bin/python
import uniprot
import requests
import json
import urllib
import urllib.parse
import urllib.request
from urllib.request import urlopen

    
def sendRequest(url, params):
    data = urllib.parse.urlencode(params);
    data = data.encode('utf-8');
    request = urllib.request.Request(url, data);  
    contact = "mariam.kourani@live.com";  
    request.add_header('User-Agent', 'Python contact'); 
    response = urllib.request.urlopen(request);
    entries = response.read();
    return entries.decode('utf-8');

def getUniprotEntries(url, params):
    #This function gets the uniprot entries
    data = urllib.parse.urlencode(params);
    data = data.encode('utf-8');
    request = urllib.request.Request(url, data);  
    contact = "mariam.kourani@live.com";  
    request.add_header('User-Agent', 'Python contact'); 
    response = urllib.request.urlopen(request);
    entries = response.read();
    return entries.decode('utf-8');
    

def entryProperties(entry):
    domain = entry.split('\t')[1];   
    #This function gets the domain, gene name & GO Ids and terms from each uniprot entry:
    geneName = entry.split("\t")[2];
    goIds = entry.split("\t")[3];
    goTerms = entry.split("\t")[4];
    return domain, geneName, goIds, goTerms
   

def domainsInDict(domain):
    #This function makes a dictionary from domain details (start, end and description):   
    domain = domain.split();
    domainDict = {};
    domainDict = {"start": domain[1], "end": domain[2], "description":  " ".join(domain[3:])}
   

def sortingDomains(domain):
    #This function checks if we have one, more or non domains in the ref protein:
    Domains =[];
    if domain.count("DOMAIN") == 1:
        Domains = domainsInDict(domain);
    elif domain.count("DOMAIN") > 1:
        domainList = domain.split(".; ");   
        Domains = [domainsInDict(domain) for domain in domainList];
    else:
        return Domains;

def main():

    mapping_url = 'https://www.uniprot.org/uploadlists/';
    
    #open and load the file:
    with open('results_NoIsoforms_Copy.json', 'r') as input_file:
        json_decode=json.load(input_file);

        query = '';
        for key, value in json_decode['reference'].items():
            key = key + (' ');
            query += key;
        params = {'from':'ACC+ID', 'to':'ACC', 'format':'tab', 'columns':'id,feature(DOMAIN EXTENT),genes,go-id,go', 'query': query}

        #get the entries:
        entries = getUniprotEntries(mapping_url, params);
        #split by (\n) to remove first row (headers) and get the entries:
        entries = entries.split('\n')[1:];
        for entry in entries:
            properties = entryProperties(entry);
            domains = sortingDomains(properties[0]);
            #update JsonFile:
            key = entry.split('\t')[0];
            json_decode['reference'][key].update({'Domains': domains,'Gene Names': properties[1], 'GOterms': properties[2]});
            print (key, "updated")
            
            with open('results_NoIsoforms_Copy.json', 'w') as updated_jsonFile:
                json.dump(json_decode, updated_jsonFile, indent=2);

if __name__=="__main__":
    #if loaded as a program, call the main function:
    main();




        
