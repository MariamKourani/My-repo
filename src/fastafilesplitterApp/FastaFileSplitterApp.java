/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package fastafilesplitterApp;

/**
 *
 * @author Mariam
 */
public class FastaFileSplitterApp {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        
        String path = "C:\\Users\\Mariam\\Desktop\\Group project\\potato\\potato\\PGSC_DM_v3_scaffolds.fasta\\PGSC_DM_v3_scaffolds.fasta";
        String outputPath = "C:\\Users\\Mariam\\Desktop\\Group project\\potato\\potato\\output\\";
        
       //creating new instance of FastaFileSplitter
        FastaFileSplitter fastaFileSplitter = new FastaFileSplitter();
        
        //calling SplitFastaFile method:
        fastaFileSplitter.SplitFastaFile(path, outputPath);
    }
    
}
