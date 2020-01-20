package sample;

import javafx.application.Application;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.concurrent.Worker.State;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.geometry.HPos;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.layout.*;
import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;
import javafx.scene.text.Text;
import javafx.scene.web.WebEngine;
import javafx.scene.web.WebView;
import javafx.stage.Stage;
import netscape.javascript.JSObject;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Map;

import static java.nio.file.Files.readAllBytes;


// using WebView component to view web pages inside JavaFX application (mini browser):
public class Main extends Application {

    String queryProtein;
    //"Q495C1";

    String filePath = "C:/Users/maria/OneDrive/Applied _Bioinformatics/Esteban/ProteinWebView/";
    String javascriptFile = filePath + "string.js";
    String visFile = filePath + "vis.js";
    String htmlFile = filePath + "string.html";
    Map geneProteinMap;
    JSONObject graph;
    int offset = 5;
    int loading = 0;

    @Override
    public void start(Stage primaryStage) throws JSONException, IOException {

        HelperClass helperClass = new HelperClass ();
        ReadJsonResult uniprotIDs = helperClass.readJson (); // uniprotIDs is an arrayList that contains refProteinsIDs and proteinsWithSE
        //refProteinsIDs: reference proteins from JSON file
        JSONArray refProteinsIDs = uniprotIDs.getRefProteins ();
        //proteinsWithSE: proteins with Splicing Events
        ArrayList<String> proteinsWithSE = uniprotIDs.getProteinsWithSE ();
        //Map geneProteinMap = helperClass.getListOfProteins (refProteinsIDs, offset, queryProtein );
        //JSONObject graph = helperClass.drawGraph ( geneProteinMap, proteinsWithSE );


        //The JavaFX WebView WebEngine is an internal component used by the WebView to load the data to be displayed inside
        //the WebView. To make the WebView WebEngine load data, you must first obtain the WebEngine instance from JavaFX WebView.
        WebView webView = new WebView ();
        WebEngine engine = webView.getEngine ();

        // add a vertical box (vBox object) where webView goes
        BorderPane border = new BorderPane (webView);
        //VBox vBox = new VBox ( webView );
        Text title = new Text ( "Network graph" );
        title.setFont ( Font.font ( "Arial", FontWeight.BOLD, 14 ) );
        border.setTop ( title );

        GridPane root = new GridPane();
        root.setPadding(new Insets(15));
        root.setHgap(5);
        root.setVgap(5);
        root.setAlignment(Pos.BASELINE_LEFT);
        border.setTop ( root );
        //vBox.setPadding ( new Insets ( 10 ) );
        //vBox.setSpacing ( 8 );

        //Add a horizontal box where buttons and labels go
        HBox hbox = new HBox ();
        border.setBottom ( hbox );
        hbox.setPadding ( new Insets ( 15, 12, 15, 12 ) );
        hbox.setSpacing ( 10 );
        hbox.setStyle ( "-fx-background-color: #336699;" );

        //Enter query protein
        // add a text field and button for user to enter the query protein
        Label label1 = new Label ( "Enter Uniprot ID: " );
        label1.setFont ( Font.font ( "Arial", FontWeight.BOLD, 12 ) );
        Button button1 = new Button ( "Retrieve interacting proteins" );
        button1.setStyle ( "-fx-text-fill: #0000ff" );
        button1.setMaxWidth ( 170 );
        //button1.setAlignment (Pos.TOP_LEFT);
        TextField textField = new TextField();
        //textField.setAlignment(Pos.BOTTOM_LEFT);//Align text
        textField.setMaxWidth (70);//Set width
        textField.setEditable(true);
        //root.setAlignment ( Pos.TOP_LEFT);
        //vBox.add( label1, 0, 1);
        //vBox.getChildren ().addAll ( label1, textField, button1);
        root.add (label1,0,0);
        root.add(textField, 1, 0);
        root.add (button1, 1, 1);

        //Add buttons and labels to load more/less proteins
        Label label2 = new Label ( "Load more proteins: " );
        label2.setFont ( Font.font ( "Arial", FontWeight.BOLD, 12 ) );
        Button button2 = new Button ( "+" );
        button2.setStyle ( "-fx-text-fill: #0000ff" );
        button2.setPrefSize ( 50, 20 );
        Label label3 = new Label ( "Load less proteins: " );
        label3.setFont ( Font.font ( "Arial", FontWeight.BOLD, 12 ) );
        Button button3 = new Button ( "-" );
        button3.setStyle ( "-fx-text-fill: #0000ff" );
        button3.setPrefSize ( 50, 20 );
        hbox.setAlignment ( Pos.CENTER );
        hbox.getChildren ().addAll ( label2, button2, label3, button3 );

        primaryStage.setTitle ( "Displaying interacting proteins" );
        Scene scene = new Scene ( border, 900, 500 );
        primaryStage.setScene ( scene);
        primaryStage.show ();

        //Set an action and attach an event listener to button1:
        button1.setOnAction ( new EventHandler<ActionEvent> () {
            @Override
            public void handle(ActionEvent event) {
                queryProtein = textField.getText ();

                //geneProteinMap: hash map that contains gene names and protein IDs

                    //Map geneProteinMap = null;
                    try {
                        geneProteinMap = helperClass.getListOfProteins ( refProteinsIDs, offset, queryProtein );
                    } catch (IOException e) {
                        e.printStackTrace ();
                    } catch (JSONException e) {
                        e.printStackTrace ();
                    }
                    JSONObject graph = null;
                    try {
                        graph = helperClass.drawGraph ( geneProteinMap, proteinsWithSE );
                    } catch (JSONException e) {
                        e.printStackTrace ();
                    }
                    // call the showGraph function:-
                    webView.getEngine ().executeScript ( "showGraph(" + graph.toString () + ")" );
            };
        } );


        // set up the listener
        engine.getLoadWorker ().stateProperty ().addListener ( new ChangeListener<State> () {
            @Override
            public void changed(ObservableValue<? extends State> ov, State oldState, State newState) {
                if (newState == State.SUCCEEDED) {
                    try {
                        // load javascript string.js
                        engine.executeScript ( new String ( readAllBytes ( Paths.get ( javascriptFile ) ) ) );
                        //load library vis.js:
                        engine.executeScript ( new String ( readAllBytes ( Paths.get ( visFile ) ) ) );
                    } catch (IOException e) {
                        e.printStackTrace ();
                    }

                    // call the showGraph function:-
                    //webView.getEngine ().executeScript ( "showGraph(" + graph.toString () + ")" );
                    // Enable Javascript.
                    engine.setJavaScriptEnabled ( true );
                    //Java To Javascript Bridge
                    JSObject window = (JSObject) engine.executeScript ( "window" );
                    window.setMember ( "clickController", new WebController () );
                };

            };
        });
        //load the empty html file (string.html)
        engine.load ( "file:///" + htmlFile );

        //Set an action and attach an event listener to button2:
        button2.setOnAction ( new EventHandler<ActionEvent> () {
            @Override
            public void handle(ActionEvent event) {
                offset += 5;
                loading += 1;
                try {
                    Map NewGeneProteinMap = helperClass.getListOfProteins ( refProteinsIDs, offset, queryProtein );
                    System.out.println ( "The offset is: " + offset );
                    JSONObject graph = helperClass.drawGraph ( NewGeneProteinMap, proteinsWithSE );
                    System.out.println ( "the new graph is: " + graph );
                    webView.getEngine ().executeScript ( "showGraph(" + graph.toString () + ")" );

                } catch (org.json.JSONException | IOException e) {
                    e.printStackTrace ();
                }
            }
        } );


        //Set an action and attach an event listener to button3:
        button3.setOnAction ( new EventHandler<ActionEvent> () {
            @Override
            public void handle(ActionEvent event) {
                offset = Math.max ( 0, offset - (5 * loading) );
                System.out.println ( "offset: " + offset );
                try {
                    JSONObject graph = helperClass.drawGraph ( geneProteinMap, proteinsWithSE );
                    System.out.println ( "the new graph is: " + graph );
                    webView.getEngine ().executeScript ( "showGraph(" + graph.toString () + ")" );
                } catch (JSONException e) {
                    e.printStackTrace ();
                }
            }
        } );
    }

    public static void main (String[]args) throws IOException {
        launch (args);
    }
}









