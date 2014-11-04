package fr.lip6.segmentations;
import fr.lip6.segmentations.AllAlgorithms;
import fr.lip6.segmentations.BOMAlgo;
import fr.lip6.segmentations.Config;
import fr.lip6.segmentations.HTML5Bom;
import fr.lip6.segmentations.SeleniumWrapper;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.apache.commons.lang3.StringUtils;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 *
 * @author sanojaa
 */
public class ProcessHTML5 {
    public void run() {
        //ArrayList<String> s1 = new ArrayList<String>();
        //ArrayList<String> s2= new ArrayList<String>();;
        String s1="";
        String s2="";
        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://"+Config.mysqlHost+"/"+Config.mysqlDatabase+"", Config.mysqlUser, Config.mysqlPassword);
            Statement st2 = con.createStatement();
            ResultSet rs = st2.executeQuery("select * from html5repo where descriptorbom<>''");
            while (rs.next()) {
                s1="";
                s2="";
                String d1 = rs.getString("descriptor");
                String d2 = rs.getString("descriptorbom");
                int dsize = d1.split(",").length;
                int d2size = d2.split(",").length;
                for (String s : d1.split(",")) {
                    String[] part = s.split("=");
                    if (!part[0].equals("PAGE")) {
                            if (part[1].equals("SECTION")) s1+="S";
                            if (part[1].equals("ARTICLE")) s1+="A";
                            if (part[1].equals("ASIDE")) s1+="D";
                            if (part[1].equals("HEADER")) s1+="H";
                            if (part[1].equals("FOOTER")) s1+="F";
                            if (part[1].equals("NAV")) s1+="N";
                        }
                    }
                
                for (String s : d2.split(",")) {
                    String[] part = s.split("=");
                    if (!part[0].equals("PAGE")){
                            if (part[1].equals("SECTION")) s2+="S";
                            if (part[1].equals("ARTICLE")) s2+="A";
                            if (part[1].equals("ASIDE")) s2+="D";
                            if (part[1].equals("HEADER")) s2+="H";
                            if (part[1].equals("FOOTER")) s2+="F";
                            if (part[1].equals("NAV")) s2+="N";
                    }
                }
                int ed = StringUtils.getLevenshteinDistance(s1.toString(), s2.toString());
                int edtotal = Math.max(s1.length(), s2.length());
                HashSet<Character> h1 = new HashSet<Character>(), h2 = new HashSet<Character>();
                for(int i = 0; i < s1.length(); i++)                                            
                {
                  h1.add(s1.charAt(i));
                }
                for(int i = 0; i < s2.length(); i++)
                {
                  h2.add(s2.charAt(i));
                }
                h1.retainAll(h2);
                int inter = h1.size();
                
                char[] code1 = s1.toCharArray();
                char[] code2 = s2.toCharArray();
                
                Set set1 = new HashSet();
                
                for (char c : code1) {
                    set1.add(c);
                }
                
                Set set2 = new HashSet();
                
                for (char c : code2) {
                    set2.add(c);
                }
                
                int total = set1.size();
                
                System.out.println(set1);
                System.out.println(set2);
                System.out.println(s1);
                System.out.println(s2);
                System.out.println(rs.getString("id")+". "+rs.getString("datafolder")+"="+ed+"/"+edtotal+"="+((double)ed/edtotal)+","+inter+" of "+total+" Prec:("+((double)inter/total)+")");
                Statement st3 = con.createStatement();
                //base=distancemax
                st3.execute("update html5repo set distance='"+ed+"',base='"+edtotal+"',found='"+inter+"', expected='"+total+"' where datafolder='"+rs.getString("datafolder")+"'");
                File f = new File("/home/sanojaa/Documents/00_Tesis/work/dataset/dataset/data/"+rs.getString("datafolder")+"/"+rs.getString("datafolder")+".5.html");
                if (!f.exists()) {
                    f.createNewFile();
                }
                FileOutputStream fop = new FileOutputStream(f);
                fop.write(rs.getString("src").getBytes());
                fop.flush();
                fop.close();
                
            }
        } catch (SQLException ex) {
            Logger.getLogger(SeleniumWrapper.class.getName()).log(Level.SEVERE, null, ex);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(HTML5Bom.class.getName()).log(Level.SEVERE, null, ex);
        } catch (FileNotFoundException ex) {
            Logger.getLogger(ProcessHTML5.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(ProcessHTML5.class.getName()).log(Level.SEVERE, null, ex);
        } 
    }
}
