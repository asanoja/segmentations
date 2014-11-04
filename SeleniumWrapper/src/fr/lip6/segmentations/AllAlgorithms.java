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
import java.net.URLConnection;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author sanojaa
 */

public class AllAlgorithms {
    // 1: category 2: url
    public void run(String args[]) {
        String surl, browser, kind, category,algo;
        URLConnection connection;
        InputStream inStream;
        algo = args[0];
        String collection_id = args[1];
        URL url;
        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://"+Config.mysqlHost+"/"+Config.mysqlDatabase+"", Config.mysqlUser, Config.mysqlPassword);
            Statement st2 = con.createStatement();
            ResultSet urls = st2.executeQuery("select pages.id,pages.url from pages inner join categories on categories.id=pages.category_id where collection_id='"+collection_id+"'");
            
            while (urls.next()){
                ResultSet df = (con.createStatement()).executeQuery("select datafolder from html5repo where url='"+urls.getString("url")+"'");
                String datafolder="";
                if (df.next()) {
                    datafolder = df.getString("datafolder");
                }
                surl = urls.getString("url");
                if ((algo.equals("jvips"))) {browser="cssbox";} else {browser = "chrome";}
                boolean check = RepoCheck.check(surl, algo, browser,collection_id);
                    if (check) {
                        System.out.println("URL already exists: "+algo+"@"+browser+" for "+surl);
                    } else {
                        try {
                            if ((algo.equals("BOM")))    (new BOMAlgo()).run(urls.getInt("id"),surl,datafolder); //hacked
                            if ((algo.equals("BF")))     (new BFAlgo()).run(surl,browser);
                            if ((algo.equals("JVIPS")))  (new JVIPSAlgo()).run( surl,browser);
                        } catch(Exception e) {
                            System.out.println("An error with selenium. Continuing with next");
                            //do nothing continue with newt
                        }
                    }
            }
        } catch (MalformedURLException ex) {
            Logger.getLogger(AllAlgorithms.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(AllAlgorithms.class.getName()).log(Level.SEVERE, null, ex);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(AllAlgorithms.class.getName()).log(Level.SEVERE, null, ex);
        } catch (SQLException ex) {
            Logger.getLogger(AllAlgorithms.class.getName()).log(Level.SEVERE, null, ex);
        } 
    }
}
