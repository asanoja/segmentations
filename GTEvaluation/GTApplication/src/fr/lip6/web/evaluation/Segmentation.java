/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package fr.lip6.web.evaluation;

import java.awt.Color;
import java.awt.Dimension;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.swing.JComponent;

/**
 *
 * @author asanoja
 */
public class Segmentation {
    private String url;
    private String id;
    private String algo;
    private ArrayList<Block> blocks = new ArrayList();
    private String page_id;
    public Color color;
//    private double docw;
//    private double doch;
    private String browser;
    
    public Segmentation(String page_id, String algo) {
        this.page_id = page_id;
        this.algo = algo;
        try {
            Class.forName("com.mysql.jdbc.Driver").newInstance();
            //Connection con = DriverManager.getConnection("jdbc:mysql://localhost/bom", "bom", "DL77ESuQZT2a3q6X");
            Connection con = DriverManager.getConnection("jdbc:mysql://"+Config.mysqlHost+"/"+Config.mysqlDatabase+"", Config.mysqlUser, Config.mysqlPassword);
            Statement st = con.createStatement();
            String sql = ("SELECT * FROM segmentation where page_id='"+this.page_id+"' and algo='"+this.algo+"';");
            ResultSet rs = st.executeQuery(sql);
            if(rs.next()) {
                this.id = rs.getString("id");
                this.algo = rs.getString("algo");
                this.browser = rs.getString("browser");
                this.page_id = rs.getString("page_id");
            }
            sql = ("SELECT * FROM blocks where segmentation_id='"+this.id+"' order by ny asc;");
            rs = st.executeQuery(sql);
            while(rs.next()) {
                this.blocks.add(new Block(rs.getString("id"),this));
            }
            double acum=0;
            for (Block b : this.blocks) {
                acum+=b.getComputedImportance();
            }
            for (Block b : this.blocks) {
                b.setAverageImportance(b.getComputedImportance()/acum);
            }
            con.close();
        } catch (ClassNotFoundException | SQLException | InstantiationException | IllegalAccessException ex) {
            Logger.getLogger(GTApplication.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
    public void setColor(Color color)  {
        this.color = color;
    }
    
    public Color getColor() {
        return(this.color);
    }
    public ArrayList<Block> getBlocks() {
        return(this.blocks);
    }
    public ArrayList<Block> getImportantBlocks(double ti) {
        ArrayList<Block> list=new ArrayList();
        for (Block b : this.blocks) {
            if (b.getAverageImportance()>ti) {
                list.add(b);
            }
        }
        return(list);
    }
     public String getAlgo() {
        return(this.algo);
    }

    /**
     * @return the id
     */
    public String getId() {
        return id;
    }

    String getCompositeId() {
        return "SEG:"+id+":"+algo+"@"+browser;
    }

    /**
     * @return the page_id
     */
    public String getPage_id() {
        return page_id;
    }
}
