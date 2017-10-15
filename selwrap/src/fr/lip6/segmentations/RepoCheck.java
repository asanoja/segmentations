/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package fr.lip6.segmentations;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;

/**
 *
 * @author sanojaa
 */
public class RepoCheck {
    
   
    public static boolean check(String url, String kind, String br) throws MalformedURLException, IOException {
        String itis;
        InputStream is;
        BufferedReader reader;
        boolean esta = false;
        itis = "http://www-poleia.lip6.fr/~sanojaa/BOM/remotecheck.php?url="+url+"&kind="+kind+"&browser="+br;
        URL curl = new URL(itis);
        is = curl.openStream();
        reader = new BufferedReader(new InputStreamReader(is));
        StringBuilder out = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            out.append(line);
        }
        reader.close();
        //System.out.print(itis);
        //System.out.print(out.toString());
        if (out.toString().equals("YES")) {
            //System.out.println("URL already processed. Skipping");
            esta = true;
        }
        return(esta);
    }
}
