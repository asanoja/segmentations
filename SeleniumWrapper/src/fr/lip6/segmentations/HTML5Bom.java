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

public class HTML5Bom {
    // 1: category 2: url
    public void run(String args[]) {
        String surl;
        URL url;
        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://"+Config.mysqlHost+"/"+Config.mysqlDatabase+"", Config.mysqlUser, Config.mysqlPassword);
            Statement st2 = con.createStatement();
            ResultSet rs =st2.executeQuery("select url from pages inner join categories on categories.id=pages.category_id where collection_id='MIG5' order by url");
            while (rs.next()) {
                url = new URL(rs.getString("url"));
                try {
                    (new BOMAlgo()).run5(url);
                } catch(Exception e) {
                    System.out.println("An error with selenium. Continuing with next");
                    //do nothing continue with newt
                }
            }
            
            
//            Statement s4 = con.createStatement();
//            ResultSet urls = s4.executeQuery("select url from html5repo where descriptorbom<>'' order by url");
//            while (urls.next()) {
//                System.out.println("URL: "+urls.getString("url"));
//                Statement s5=con.createStatement();
//                String xurl=urls.getString("url");
//                if (xurl.endsWith("/")) {
//                    xurl = xurl.substring(0, xurl.length() - 1);
//                }
//                ResultSet pag = s5.executeQuery("select pages.id pid,category_id,collection_id from pages inner join categories on categories.id=pages.category_id where collection_id='GOSH' and pages.url='"+xurl+"'");
//                int k=0;
//                while (pag.next()) {
//                    k=1;
//                    System.out.println("PAGE: "+pag.getString("pid"));
//                    String cat=pag.getString("category_id")+"5";
//                    if (pag.getString("category_id").equals("enterprise")) cat="enterpris5";
//                    ResultSet pcheck=(con.createStatement()).executeQuery("select id from pages where url='"+urls.getString("url")+"' and category_id='"+cat+"'");
//                    int currentPageMig=0;
//                    if (pcheck.first()) {
//                        currentPageMig = pcheck.getInt("id");
//                    } else {
//                        (con.createStatement()).executeUpdate("insert into pages(url,category_id) values('"+urls.getString("url")+"','"+cat+"')");
//                        ResultSet xrs = (con.createStatement()).executeQuery("select last_insert_id() as last_id from pages");
//                        if (xrs.next())  currentPageMig = xrs.getInt("last_id");
//                    }
//                    Statement s6=con.createStatement();
//                    ResultSet seg=s6.executeQuery("select * from segmentation where page_id='"+pag.getString("pid")+"' and algo='BOM'");
//                    int nsegid=0;
//                    while (seg.next()) {
//                        pcheck=(con.createStatement()).executeQuery("select id from segmentation where page_id='"+currentPageMig+"'");
//                        if (pcheck.first()) {
//                           nsegid = pcheck.getInt("id"); 
//                        } else {
//                            String sql="insert into segmentation(page_id,source1,algo,granularity,browser,doc_w,doc_h,tdcount) values('"+currentPageMig+"','"+seg.getString("source1")+"','GT','5','chrome','"+seg.getString("doc_w")+"','"+seg.getString("doc_h")+"','"+seg.getString("tdcount")+"')";
//                            (con.createStatement()).executeUpdate(sql);
//                            ResultSet xrs = (con.createStatement()).executeQuery("select last_insert_id() as last_id from segmentation");
//                            if (xrs.next()) {
//                                nsegid = xrs.getInt("last_id");
//                            } 
//                        }
//                        System.out.println("SEG: "+nsegid);
//                        Statement stn = con.createStatement();
//                        ResultSet b = stn.executeQuery("select * from blocks where segmentation_id='"+seg.getString("id")+"'");
//                        while (b.next()) {
//                            pcheck=(con.createStatement()).executeQuery("select id from blocks where segmentation_id='"+nsegid+"' and bid='"+b.getString("bid")+"' and importance='"+b.getString("importance")+"'");
//                            if (!pcheck.first()) {
//                                String sqlb = "insert into blocks(bid,x,y,w,h,segmentation_id,ecount,tcount,importance,nx,ny,nw,nh) values('"+b.getString("bid")+"','"+b.getString("x")+"','"+b.getString("y")+"','"+b.getString("w")+"','"+b.getString("h")+"','"+nsegid+"','"+b.getString("ecount")+"','"+b.getString("tcount")+"','"+b.getString("importance")+"','"+b.getString("nx")+"','"+b.getString("ny")+"','"+b.getString("nw")+"','"+b.getString("nh")+"')";
//                                (con.createStatement()).executeUpdate(sqlb);
//                            }
//                        }
//                    }
//                }
//                if (k==0) {
//                    System.out.println("URL SKIPED: "+urls.getString("url"));
//                }
//            }
    }   catch (SQLException ex) {
            Logger.getLogger(HTML5Bom.class.getName()).log(Level.SEVERE, null, ex);
    }   catch (ClassNotFoundException ex) {
            Logger.getLogger(HTML5Bom.class.getName()).log(Level.SEVERE, null, ex);
    }   catch (MalformedURLException ex) {
            Logger.getLogger(HTML5Bom.class.getName()).log(Level.SEVERE, null, ex);
        }
}
}