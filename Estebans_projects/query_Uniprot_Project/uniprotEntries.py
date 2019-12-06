
#!/usr/bin/python

import uniprot
import requests
import urllib
import urllib.parse
import urllib.request
from urllib.request import urlopen

#send single request per proteinID 
#result = requests.get('https://www.uniprot.org/uniprot/?query=A0FGR8-2%20domain&columns=id%2Cfeature(DOMAIN%20EXTENT)%20go&sort=score&format=tab').text;

#print(result)

#Batch retrieval for all proteinIDs with a single request
url = 'https://www.uniprot.org/uploadlists/'
query = 'A0A0A0MS52'

params = {
    'from':'ACC+ID',
    'to':'ACC',
    'format':'tab',
    'columns':'id,feature(DOMAIN EXTENT),genes,go,go-id',
    'query':query,
}  
data = urllib.parse.urlencode(params)
data = data.encode('utf-8')
request = urllib.request.Request(url, data)  
#contact = "mariam.kourani@live.com"  
#request.add_header('User-Agent', 'Python contact') 
response = urllib.request.urlopen(request)
data_content = response.read()
print(data_content)

