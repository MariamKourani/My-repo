#!/usr/bin/python
import uniprot
import requests
import json
import urllib
import urllib.parse
import urllib.request
from urllib.request import urlopen

class QueryUniprot():
    def __init__(self, url, params):
        self.url = url; 
        self.params = params;  
        
    def sendRequest(url, params):
        data = urllib.parse.urlencode(params);
        data = data.encode('utf-8');
        request = urllib.request.Request(url, data);  
        contact = "mariam.kourani@live.com";  
        request.add_header('User-Agent', 'Python contact'); 
        response = urllib.request.urlopen(request);
        entries = response.read();
        return entries.decode('utf-8');

class SortEntries():
    def __init__(self, entry):
        self.entry = entry; 
        
    def entryInfo(entry):
        x = entry.split('\t');
        domain = x[1];   
        #This function gets the domain, gene name & GO Ids and terms from each uniprot entry:
        geneName = x[2];
        goIds = x[3];
        goTerms = x[4];
        #goTermsList =[];
        if goTerms.count('GO') > 1:
            goTerms = goTerms.split(';')
        else:
            goTermsList = []
            goTermsList = goTermsList.append(goTerms);
        return domain, geneName, goIds, goTerms;

    def domainsInDict(self,domain):
        #This function makes a dictionary from domain details (start, end and description):   
        domain = domain.split();
        domainDict = {"start": domain[1], "end": domain[2], "description":  " ".join(domain[3:])}
        return domainDict;
        
    def sortingDomains(self,domain):
        #This function checks if we have one, more or non domains in the ref protein:
        Domains =[];
        if domain.count("DOMAIN") == 1:
            Domains = [self.domainsInDict(domain)];
        elif domain.count("DOMAIN") > 1:
            domainList = domain.split(".; ");   
            Domains = [self.domainsInDict(domain) for domain in domainList];
        else:
            Domains =[];
        return Domains;
 
def main():
    with open('results_NoIsoforms.json', "r") as jsonFile:
        json_decode=json.load(jsonFile);
        
        url = 'https://www.uniprot.org/uploadlists/';
        query = '';
        for key, value in json_decode['reference'].items():
            key = key + (' ');
            query += key;
            params = {'from':'ACC+ID', 'to':'ACC', 'format':'tab', 'columns':'id,feature(DOMAIN EXTENT),genes,go-id,go', 'query': query}
        #query uniprot:
        returnedEntries = QueryUniprot.sendRequest(url, params);
        #remove headers:
        returnedEntries = returnedEntries.split('\n')[1:-1];
        #get entry's selected properties:
        for entry in returnedEntries:
            #print (entry)
            entryDetails = SortEntries.entryInfo(entry);
            #create an instance of SortEntries class:
            sortEntriesInstance = SortEntries(entry)
            domain = entryDetails[0];
            domains = sortEntriesInstance.sortingDomains(domain);
            #goTermsList = [];
            geneName = entryDetails[1];
            goIds = entryDetails[2];
            goTerms = entryDetails[3];
           #update JsonFile:
            key = entry.split('\t')[0];
            json_decode['reference'][key].update({'Domains': domains,'Gene Names': geneName, 'GO Ids': goIds, 'GOterms': goTerms});
           
            print (key, "updated")
            
        with open('results_NoIsoforms.json', "w") as updated_jsonFile:
            json.dump(json_decode, updated_jsonFile, indent=2);           

if __name__ == "__main__":
    main()
