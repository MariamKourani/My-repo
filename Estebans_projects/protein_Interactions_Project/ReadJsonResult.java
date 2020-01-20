package sample;

import org.json.JSONArray;

import java.util.ArrayList;

public class ReadJsonResult {

        JSONArray refProteins;
        ArrayList<String> proteinsWithSE;

        //constructor
        public ReadJsonResult(JSONArray refProteins, ArrayList<String> proteinsWithSE){
            this.refProteins = refProteins;
            this.proteinsWithSE = proteinsWithSE;
        }

        public JSONArray getRefProteins(){
            return refProteins;
        }

        public ArrayList<String> getProteinsWithSE(){
            return proteinsWithSE;
        }
}
