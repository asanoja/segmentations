/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package html5export;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author asanoja
 */
public class Html5export {
Connection con;
ArrayList<Page> pages;
Map<String, String> map = new HashMap<String, String>();
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        Html5export h = new Html5export();
        h.map = (new ReadXMLFile()).getMap();
        h.load();
        h.parse();
    }
    public Html5export() {
    try {
        Class.forName("com.mysql.jdbc.Driver").newInstance();
        this.con = DriverManager.getConnection("jdbc:mysql://"+Config.mysqlHost+"/"+Config.mysqlDatabase+"", Config.mysqlUser, Config.mysqlPassword);
    } catch (ClassNotFoundException ex) {
        Logger.getLogger(Html5export.class.getName()).log(Level.SEVERE, null, ex);
    } catch (InstantiationException ex) {
        Logger.getLogger(Html5export.class.getName()).log(Level.SEVERE, null, ex);
    } catch (IllegalAccessException ex) {
        Logger.getLogger(Html5export.class.getName()).log(Level.SEVERE, null, ex);
    } catch (SQLException ex) {
        Logger.getLogger(Html5export.class.getName()).log(Level.SEVERE, null, ex);
    }
    }
    
    public void load() {
    try {
        this.pages = new ArrayList<Page>();
        String sql = "select * from html5repo order by datafolder";
        PreparedStatement st = con.prepareStatement(sql);
        ResultSet rs = st.executeQuery();
        while (rs.next()) {
            Page p = new Page();
            p.setSrc(rs.getString("src"));
            p.setDescriptor(rs.getString("descriptor"));
            p.setDatafolder(rs.getString("datafolder"));
            p.setUrl(map.get(rs.getString("datafolder")));
            this.pages.add(p);
            Statement st2 = con.createStatement();
            st2.execute("update html5repo set url='"+map.get(rs.getString("datafolder"))+"' where datafolder='"+rs.getString("datafolder")+"'");
           
        }   
    } catch (SQLException ex) {
        Logger.getLogger(Html5export.class.getName()).log(Level.SEVERE, null, ex);
    }
         
    }
    
    public void parse() {
        String filename;
        for (Page p: this.pages) {
            PrintWriter out = null;
            try {
                filename = "/home/asanoja/Documentos/00_Tesis/work/dataset/dataset/data/"+p.getDatafolder()+"/"+p.getDatafolder()+".5.html";
                File file = new File(filename);
                if (!file.exists()) {
                        file.createNewFile();
                }
                FileOutputStream fop = new FileOutputStream(file);
                
                byte[] contentInBytes = p.getSrc().getBytes();
                fop.write(contentInBytes);
                fop.flush();
                fop.close();
                System.out.println(filename);
            } catch (FileNotFoundException ex) {
                Logger.getLogger(Html5export.class.getName()).log(Level.SEVERE, null, ex);
            } catch (IOException ex) {
                Logger.getLogger(Html5export.class.getName()).log(Level.SEVERE, null, ex);
            } finally {
                if (out!=null) out.close();
            }
        }
    }
    
}
