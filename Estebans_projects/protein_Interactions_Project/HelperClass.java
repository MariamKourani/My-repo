package sample;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;

public class HelperClass {
    String jsonFile = "C:/Users/maria/OneDrive/Applied _Bioinformatics/Esteban/query_Uniprot_Project/OriginalFiles/results_NoIsoforms.json";

    //readJson() reads JSON file and extracts reference protein IDS and proteins with splicing events
    public ReadJsonResult readJson() throws IOException, JSONException {

        // read json file into a json object:
        JSONObject jsonObj = new JSONObject ( Files.readString ( Paths.get ( jsonFile) ) );

        //get the reference proteins IDs and the transcript ids (the keys of "reference" and "orf" objects
        JSONArray proteinIds = jsonObj.getJSONObject ( "reference" ).names ();
        JSONArray IdsObj = jsonObj.getJSONObject ( "orf" ).names ();

        // initialising an empty arrayList to add the proteins with splicing events:
        ArrayList<String> proteinsWithSE = new ArrayList<> ();
        try {
            for (int i=0; i < IdsObj.length (); ++i) {
                // get transcript ids:
                String key = IdsObj.getString ( i );
                // get JSONObject "orf":
                JSONObject obj1 = jsonObj.getJSONObject ( "orf" );
                // get JSONObjects transcript's Ids:
                JSONObject obj2 = obj1.getJSONObject ( key );
                // get the "match" property:
                String match = obj2.getString ( "match" );
                // get "variations" array:
                JSONArray variationsArray = obj2.getJSONArray ( "variations" );
                //check if variations array is not empty:
                if (variationsArray != null && variationsArray.length () > 0) {
                    //get proteins with splicing event type=SAP:
                    for (int j = 0; j < variationsArray.length (); j++) {
                        String type = variationsArray.getJSONObject ( j ).getString ( "type" );
                        if (type.equals ( "SAP" )) {
                            //check if the protein has not been already added to proteinsWithSE arrayList
                            if ((proteinsWithSE.indexOf ( match ) < 0)) {
                                proteinsWithSE.add ( match );
                            }
                        }
                    }
                }
            }
            System.out.println ( "proteinsWithSE: " + proteinsWithSE );
        } catch (org.json.JSONException ex) {
            ex.printStackTrace ();
        }
        // make an instance of return of ReadJsonResults class and return it (in one step)
        return new ReadJsonResult ( proteinIds, proteinsWithSE );
    }

    public Map getListOfProteins(JSONArray uniprotIDs, int offset, String queryProtein) throws IOException, JSONException {

        //convert the arrayList elements to String
        String allProteins = uniprotIDs.toString ();
        //remove quotes from the arrayList elements:
        allProteins = allProteins.replace("\"", "");
        //strip the outside brackets:
        allProteins = allProteins.substring(1, allProteins.length() - 1);

        //send a request to the server to query the database
        //create a connection to a given url using GET method:
        URL url = new URL ("http://127.0.0.1:5000?offset="+offset+"&uniprot_id="+queryProtein+"&allProteins="+allProteins);
        HttpURLConnection con = (HttpURLConnection) url.openConnection ();
        con.setRequestMethod ("GET");

        //Reading the message from the client
        InputStream inputStream = con.getInputStream ();

        //Reading the response of the request can be done by parsing the InputStream of the HttpUrlConnection instance
        //reading the response of the request and placing it in a String
        BufferedReader in = new BufferedReader (new InputStreamReader (inputStream));

        String inputLine;
        StringBuffer content = new StringBuffer ();
        while ((inputLine = in.readLine ()) != null) {
            content.append (inputLine);
        }
        System.out.println ("Message received from client is " + content);
        in.close ();
        //To close the connection
        con.disconnect ();

        //convert String -json (content) into JSONObject
        JSONObject jsonObject = new JSONObject ( content.toString () );
        //save JSONObject in a Hash map
        HashMap<String, String> geneProteinMap = new HashMap<> (  );
        Iterator<?> keys = jsonObject.keys();
        while (keys.hasNext())
        {
            String key = (String) keys.next();
            String value = jsonObject.getString(key);
            geneProteinMap.put(key, value);
        }
        return geneProteinMap;
    }
    //drawGraph() method draws the graph of interacting proteins
    public JSONObject drawGraph(Map geneProteinMap, ArrayList<String> proteinsWithSE) throws JSONException {

        JSONArray graphNodes = new JSONArray ();
        JSONArray edges = new JSONArray ();
        //iterate through the hash map entries to get the keys (gene names) and values(proteinID)
        int i =0;
        Set<Map.Entry<String, String>> entrySet = geneProteinMap.entrySet ();
        for(Map.Entry<String, String> entry : entrySet) {
            String key = entry.getKey ();
            String value = entry.getValue ();
            String url = "https://www.uniprot.org/uniprot/" + value;

            // make the nodes:
            JSONObject nodeObj = new JSONObject ();
            nodeObj.put ( "id", i);
            nodeObj.put ( "label", key );
            nodeObj.put ( "url", url );
            // color the nodes that correspond to proteins with splicing events
            if ((proteinsWithSE.indexOf ( value ) > 0)) {
                nodeObj.put ( "color", "#00ff00" );
            } else {
            }
            graphNodes.put ( nodeObj );

            //make the edges
            JSONObject edgeObj = new JSONObject ();
            edgeObj.put ( "from", i );
            edgeObj.put ( "to", entrySet.size () -1 );
            edges.put ( edgeObj );
            i++;
        }
        // make the graph and add the nodes and edges to it
        JSONObject graph = new JSONObject ();
        graph.put ( "nodes", graphNodes );
        graph.put ( "edges", edges );

        return graph;
    }
}
