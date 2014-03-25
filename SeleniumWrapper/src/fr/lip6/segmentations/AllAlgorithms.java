/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package fr.lip6.segmentations;

import java.io.IOException;
import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author sanojaa
 */

public class AllAlgorithms {
    // 1: category 2: url
    public static void main(String args[]) {
        String url, browser, kind, category,algo;
        algo = args[0];
        url = args[2];
        kind = algo.toUpperCase()+"data";
        if ((algo.equals("jvips"))) {browser="cssbox";} else {browser = args[3];}
        category = args[1];
        try {
            boolean check = RepoCheck.check(url, kind, browser);
            //check=false; //ojo quitar
            if (check) {
                System.out.println("URL already exists: "+kind+"@"+browser+" for "+url);
            } else {
                if ((algo.equals("bom")))    (new BOMAlgo()).run(category, url,browser);
                if ((algo.equals("bf")))     (new BFAlgo()).run(category, url,browser);
                if ((algo.equals("jvips")))  (new JVIPSAlgo()).run(category, url,browser);
            }
            
        } catch (IOException ex) {
            Logger.getLogger(AllAlgorithms.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
