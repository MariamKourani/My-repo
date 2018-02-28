/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package fastafilesplitterApp;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Mariam
 */
public class FastaFileSplitter {
    
    public void SplitFastaFile(String path, String outputPath) {
        
        try {
                // read the file line by line
                BufferedReader in;
                in = new BufferedReader(new FileReader(path));

                String line;
                boolean found=false;
                FileWriter fileWriter = null;
                while((line=in.readLine())!=null)
                {
                    if(line.startsWith(">"))
                    {
                        //found = true;
                        if (fileWriter != null) fileWriter.close();
                        
                        //creating the filepath
                        String filePath = outputPath + line.substring(1) + ".txt";
                        
                        File file = new File(filePath);
                        //creating new file
                        file.createNewFile();
                        
                        fileWriter = new FileWriter(file);
                        
                        
                        System.out.println(line);

                    }
                    else
                    {
                        if (fileWriter != null) fileWriter.write(line);
                    }
 
                }
                if (fileWriter != null) fileWriter.close();
                in.close();
            } catch (Exception ex) {
                Logger.getLogger(FastaFileSplitter.class.getName()).log(Level.SEVERE, null, ex);
            }
    }
}
