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
public class RepoCheck {
    
   
    public static boolean check(String url, String algo, String br,String collection_id) throws MalformedURLException, IOException {
        boolean esta = false;
        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://"+Config.mysqlHost+"/"+Config.mysqlDatabase+"", Config.mysqlUser, Config.mysqlPassword);
            Statement st2 = con.createStatement();
            ResultSet rs = st2.executeQuery("select segmentation.id as sid from segmentation inner join pages on pages.id=segmentation.page_id inner join categories on categories.id=pages.category_id where segmentation.algo='"+algo+"' and segmentation.browser='"+br+"' and pages.url='"+url+"' and categories.collection_id='"+collection_id+"'");
            if (rs.next()) {
                esta = true;
            }
            
        } catch (SQLException ex) {
            Logger.getLogger(RepoCheck.class.getName()).log(Level.SEVERE, null, ex);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(RepoCheck.class.getName()).log(Level.SEVERE, null, ex);
        }
    return(esta);
    }
}
