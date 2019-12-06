package sample;

//import Flask;

import javafx.application.Application;
import javafx.concurrent.Worker;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;
import javafx.scene.text.Text;
import javafx.scene.web.WebEngine;
import javafx.scene.web.WebView;
import javafx.stage.Stage;
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
import java.util.ArrayList;
import java.util.Arrays;

import static java.nio.file.Files.readAllBytes;


// using WebView component to view web pages inside JavaFX application (mini browser):
public class Main extends Application {

    private static JSONArray proteinIds;
    //private static ArrayList<String> otherIdsDisplayed;
    private String uniprot_id = "Q495C1";
    private int offset = 5;
    int loading = 0;

    @Override
    public void start(Stage primaryStage) throws JSONException, IOException {
        //this: for methods of this class
        this.readJson ();
        ArrayList<String> otherIdsDisplayed = this.getListOfProteins ();
        JSONObject graph = this.drawGraph (otherIdsDisplayed);

        primaryStage.setTitle ("Displaying interacting proteins");

        //The JavaFX WebView WebEngine is an internal component used by the WebView to load
        //the data that is to be displayed inside the WebView. To make the WebView WebEngine
        //load data, you must first obtain the WebEngine instance from JavaFX WebView.
        WebView webView = new WebView ();
        WebEngine webEngine = webView.getEngine ();

        // add a box  where the button and webView go and labels:
        BorderPane border = new BorderPane();
        Text title = new Text ("Network graph");
        title.setFont (Font.font ("Arial", FontWeight.BOLD, 14));
        border.setTop (title);

        VBox vBox = new VBox (webView);
        //vBox.getChildren ().add (title);
        border.setCenter (vBox);
        vBox.setPadding (new Insets (10));
        vBox.setSpacing (8);

        HBox hbox = new HBox ();
        border.setBottom (hbox);
        hbox.setPadding(new Insets(15, 12, 15, 12));
        hbox.setSpacing(10);
        hbox.setStyle("-fx-background-color: #336699;");

        Label label1 = new Label ("load more proteins: ");
        hbox.getChildren ().add (label1);
        label1.setFont (Font.font("Arial", FontWeight.BOLD, 12));
        Button button1 = new Button ("+");
        hbox.getChildren ().add (button1);
        button1.setStyle ("-fx-text-fill: #0000ff");
        button1.setPrefSize (50, 20);

        Label label2 = new Label ("load less proteins: ");
        hbox.getChildren ().add (label2);
        label2.setFont (Font.font("Arial", FontWeight.BOLD, 12));
        Button button2 = new Button ("-");
        hbox.getChildren ().add (button2);
        button2.setStyle ("-fx-text-fill: #0000ff");
        button2.setPrefSize (50, 20);
        hbox.setAlignment(Pos.CENTER);

        // set the scene:
        Scene scene = new Scene (border, 900, 500);
        primaryStage.setScene (scene);
        primaryStage.show ();

        //attach an event listener to the button1:
        button1.setOnAction(new EventHandler<ActionEvent> () {
            @Override
            public void handle(ActionEvent event) {
                offset += 5;
                loading +=1;
                try {
                    ArrayList<String> newProteinList = getListOfProteins ();
                    otherIdsDisplayed.addAll (newProteinList);
                    System.out.println ("The offset is: " + offset);
                    System.out.println ("new set of interacting proteins" + otherIdsDisplayed);
                    JSONObject graph = drawGraph (newProteinList);
                    System.out.println ("the new graph is: " + graph);
                    webView.getEngine ().executeScript ("showGraph(" + graph.toString (1) + ")");
                } catch (IOException e) {
                    e.printStackTrace ();
                } catch (JSONException e) {
                    e.printStackTrace ();
                }
            }
        });

        //attach an event listener to the button2:
        button2.setOnAction(new EventHandler<ActionEvent> () {
            @Override
            public void handle(ActionEvent event) {
                offset = Math.max(0, offset - (5 * loading));
                System.out.println ("loading times: " + loading);
                System.out.println (offset);

                try {
                    //otherIdsDisplayed = (ArrayList<String>) otherIdsDisplayed.subList(0, offset);
                    //Return portion of the list: remove the proteins that were added by clicking the (+) button:
                    ArrayList<String> newList = new ArrayList<String>(otherIdsDisplayed.subList(0, offset));

                    System.out.println ("The offset is: " + offset);
                    System.out.println ("new set of interacting proteins" + newList);
                    JSONObject graph = drawGraph (newList);
                    System.out.println ("the new graph is: " + graph);
                    webView.getEngine ().executeScript ("showGraph(" + graph.toString (1) + ")");
                } catch (JSONException e) {
                    e.printStackTrace ();
                }
            }
        });

        /* make an array of protein names:
        JSONArray proteinArray = new JSONArray ();
        proteinArray.put ("protein A");
        proteinArray.put ("protein B");
        proteinArray.put ("protein C");
        proteinArray.put ("protein D");
        proteinArray.put ("protein E");*/

        // set up the listener
        webEngine.getLoadWorker ().stateProperty ().addListener ((observable, oldState, newState) -> {
            if (newState == Worker.State.SUCCEEDED) {

                try {
                    // load javascript string.js
                    webEngine.executeScript (new String (readAllBytes (Paths.get ("C:/Users/maria/OneDrive/Applied _Bioinformatics/Esteban/WebViewExample/string.js"))));
                    //load library vis.js:
                    webEngine.executeScript (new String (readAllBytes (Paths.get ("C:/Users/maria/OneDrive/Applied _Bioinformatics/Esteban/WebViewExample/vis.js"))));
                } catch (IOException e) {
                    e.printStackTrace ();
                }

                // call the showGraph function:-
                try {
                    webView.getEngine ().executeScript ("showGraph(" + graph.toString (1) + ")");
                } catch (JSONException e) {
                    e.printStackTrace ();
                }
            }
        });

        //load the empty string.html:
        webEngine.load ("file:///C:/Users/maria/OneDrive/Applied _Bioinformatics/Esteban/WebViewExample/string.html");
    }


    public  JSONArray readJson() throws IOException {

        // read json file:
        //JSONArray proteinIds;
        try {
            // read json file into a json object:
            JSONObject jsonObj = new JSONObject (Files.readString (Paths.get ("C://Users//maria//OneDrive//Applied _Bioinformatics//Esteban//query_Uniprot_Project//OriginalFiles//ResultsOriginal.json")));
            //get the referenceIDs (values):
            proteinIds = jsonObj.getJSONObject ("reference").names ();
            System.out.println(proteinIds);

        } catch (JSONException e) {
            e.printStackTrace ();
        }
        return proteinIds;
    }

    public ArrayList<String> getListOfProteins() throws IOException {
        // send request to the server to query the database:
        String allProteins = proteinIds.toString ();
        //remove quotes from the arrayList elements:
        allProteins = allProteins.replace("\"", "");
        //strip the outside brackets:
        allProteins = allProteins.substring(1, allProteins.length() - 1);

        //String uniprot_id= "Q495C1";
        //int offset = 5;
        
        //send a request to the server
        //create a connection to a given url using GET method:
        URL url = new URL ("http://127.0.0.1:5000?offset="+offset+"&uniprot_id="+uniprot_id+"&allProteins="+allProteins);
        HttpURLConnection con = (HttpURLConnection) url.openConnection ();
        con.setRequestMethod ("GET");

            //Reading the message from the client:
            InputStream inputStream = con.getInputStream ();

            //Reading the response of the request can be done by parsing the InputStream of the HttpUrlConnection instance:
            //reading the response of the request and placing it in a content String:
            BufferedReader in = new BufferedReader (new InputStreamReader (inputStream));

            String inputLine;
            StringBuffer content = new StringBuffer ();
            while ((inputLine = in.readLine ()) != null) {
                content.append (inputLine);
            }
            System.out.println ("Message received from client is " + content);
            in.close ();
        // To close the connection:
            con.disconnect ();

            //initialising the variable otherIdsDisplayed:
            ArrayList<String> otherIdsDisplayed = new ArrayList<String>();
            otherIdsDisplayed.addAll (Arrays.asList (content.toString ().split (",")));   //return otherIdsDisplayed;
            return otherIdsDisplayed;
            //System.out.println ("first set of interacting proteins" + otherIdsDisplayed);

    }
    public JSONObject drawGraph(ArrayList<String> otherIdsDisplayed) throws JSONException {
        // make the nodes:
        JSONArray graphNodes = new JSONArray ();
        for (int i = 0; i < otherIdsDisplayed.size (); i++) {
            JSONObject nodeObj = new JSONObject ();
            nodeObj.put ("id", i);
            nodeObj.put ("label", otherIdsDisplayed.get (i));
            graphNodes.put (nodeObj);
        }
        //make the edges and add them to the graph
        JSONArray edges = new JSONArray ();
        for (int i = 0; i < otherIdsDisplayed.size (); i++) {
            JSONObject edgeObj = new JSONObject ();
            edgeObj.put ("from", i);
            edgeObj.put ("to", otherIdsDisplayed.size () - 1);
            edges.put (edgeObj);
        }

        // make the graph and add the nodes to the graph
        JSONObject graph = new JSONObject ();
        graph.put ("nodes", graphNodes);
        graph.put ("edges", edges);
        return graph;
    }

    public static void main (String[]args) throws IOException {
        launch (args);
    }

}







