#!/usr/bin/python

import json

def SortDomains(start_domain, end_domain, description):
    #This function makes a dictionary from domain details (start, end and description):   
    domainDict = {"start": start_domain, "end": end_domain, "description": description}
    #populate the dictionary with domain details:
    domainList = [];
    domainList.append(domainDict);
    return domainList

#open and load .json file:
with open('results_NoIsoforms.json', 'r') as input_file:
    json_decode=json.load(input_file);

    for key, value in json_decode['orf'].items():
        refProtein = json_decode['orf'][key]["match"];
        #domains
        domains = json_decode['reference'][refProtein]["Domains"];       
        #List of variants:
        variantList = json_decode['orf'][key]["variations"];
        #If variant(s) exist(s):
        VariantCount = 0;
        if len(variantList) != 0:
            VariantCount = 0;
            for variant in variantList:
                pos = variant["pos"];
                Type = variant["type"];
                ref = variant["ref"];
                VariantCount +=1;   
                domainCount =0;
            #If domain(s) exist(s):           
            if len(domains) !=0: 
                for domain in domains:
                    start_domain = int(domain["start"]);
                    end_domain = int(domain["end"]);
                    description = domain["description"];
                    domainCount +=1;
                    #In case of insertion:                    
                    if (Type == "INS" and (start_domain <= pos <= end_domain)):
                        domainList = SortDomains(start_domain, end_domain, description);
                        json_decode['orf'][key]["variations"][VariantCount-1].update({'domains': domainList});
                        print (key, refProtein, "variant", VariantCount,  ":", "domain", domainCount, ":", "variation INS falls within a domain");

                    #in case of deletion:
                    elif (Type == "DEL" and ((start_domain <= pos <= end_domain) or (pos <= start_domain <= (pos + len(ref))))):
                        domainList = SortDomains(start_domain, end_domain, description)
                        json_decode['orf'][key]["variations"][VariantCount-1].update({'domains': domainList});
                        print (key, refProtein, "variant", VariantCount, ":", "domain", domainCount, ":", "variation DEL falls within a domain");
                        
                    #In case of SAP (single AA polymorphism):
                    elif (Type == "SAP" and (start_domain <= pos <= end_domain)):
                        domainList = SortDomains(start_domain, end_domain, description);
                        json_decode['orf'][key]["variations"][VariantCount-1].update({'domains': domainList});
                        print (key, refProtein, "variant", VariantCount, ":", "domain", domainCount, ":", "variation SAP falls within a domain");

                    #in case of substitution (ALT) or (merged):
                    elif (((Type == "ALT") or (Type == "merged")) and (start_domain <= pos <= end_domain) or (pos <= start_domain <= (pos + len(ref)))):                                                                                                    
                        domainList = SortDomains(start_domain, end_domain, description);
                        json_decode['orf'][key]["variations"][VariantCount-1].update({'domains': domainList});
                        print (key, refProtein, "variant", VariantCount, ":", "domain", domainCount, ":", "variation ALT falls within a domain");

    with open('results_NoIsoforms.json', 'w') as updated_jsonFile:
        json.dump(json_decode, updated_jsonFile, indent=2);

    