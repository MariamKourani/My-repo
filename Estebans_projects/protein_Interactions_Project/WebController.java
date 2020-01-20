package sample;

import java.awt.*;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URISyntaxException;
import java.net.URL;

public class WebController {
    //private AlphaComposite HostServicesFactory;

    public void loadURL(String url) throws IOException, URISyntaxException, MalformedURLException, URISyntaxException {
        //open url in the browser
        //Desktop.getDesktop().browse(new URL (url).toURI());
        try {
            Desktop.getDesktop().browse(new URL(url).toURI());
            System.out.println ("javascript connected");
        } catch (IOException e) {
            e.printStackTrace ();
        } catch (URISyntaxException e) {
            e.printStackTrace ();
        }
    }
}

