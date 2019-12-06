#!/usr/bin/python
import uniprot
import requests

mapping_url = 'https://www.uniprot.org/uploadlists/'
mapping_params = {'from':'ACC+ID', 'to':'ACC', 'format':'tab', 'query':'H3BUF6'}

uniprot_url = 'https://www.uniprot.org/uniprot/'
query_string = 'yourlist:{}'
search_params = {'columns':'id,feature(DOMAIN EXTENT),genes,go,go-id', 'format':'tab', 'query':query_string}
#, feature(DOMAIN EXTENT),genes
#get job number
def get_job_number():
    response = requests.get(mapping_url, params=mapping_params, allow_redirects=False)
    return response.headers['Location'].split('/')[-1].split('.')[0]
    
def get_filtered_uniprot_ids():
    job_num = get_job_number()
    search_params['query'] = query_string.format(job_num)
    response = requests.get(uniprot_url, search_params)
    return response.text

if __name__ == '__main__':
    print (get_filtered_uniprot_ids())
   
