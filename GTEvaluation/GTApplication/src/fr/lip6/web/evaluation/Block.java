/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package fr.lip6.web.evaluation;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;

import java.awt.geom.Point2D;
import uk.co.geolib.geolib.C2DRect;

/**
 *
 * @author asanoja
 */
public class Block {
    private String id;
    private double nx;
    private double ny;
    private double nw;
    private double nh;
    private String bid;
    private Segmentation parent;
    private int tcount;
    private int ecount;
    private double computedImportance;
    private double averageImportance;

    Block(String id,Segmentation parent) {
        try {
            Class.forName("com.mysql.jdbc.Driver").newInstance();
            try (Connection con = DriverManager.getConnection("jdbc:mysql://"+Config.mysqlHost+"/"+Config.mysqlDatabase+"", Config.mysqlUser, Config.mysqlPassword);) {
                Statement st = con.createStatement();
                String sql = ("SELECT * FROM blocks where id='"+id+"';");
                ResultSet rs = st.executeQuery(sql);
                if(rs.next()) {
                    this.id = rs.getString("id");
                    this.nx = Double.parseDouble(rs.getString("nx"));
                    this.ny = Double.parseDouble(rs.getString("ny"));
                    this.nw = Double.parseDouble(rs.getString("nw"));
                    this.nh = Double.parseDouble(rs.getString("nh"));
                    this.bid = rs.getString("bid");
                    this.tcount = rs.getInt("tcount");
                    this.ecount = rs.getInt("ecount");
                    this.computedImportance = rs.getInt("importance");
                    this.parent = parent;
                }
            }
        } catch (ClassNotFoundException | SQLException | InstantiationException | IllegalAccessException ex) {
            Logger.getLogger(GTApplication.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
    public int weight() {
        return(ecount+tcount);
    }
    
    public double getNx() {
        return(this.nx);
    }
    public double getNy() {
        return(this.ny);
    }
    public double getNw() {
        return(this.nw);
    }
    public double getNh() {
        return(this.nh);
    }

    public String getBid() {
        return this.bid;
    }
    public String getId() {
        return this.id;
    }

    public Segmentation getParent() {
        return parent;
    }
    
    public C2DRect getRectangle(int tt) {
        C2DRect rect = new C2DRect();
        rect.Set(getNx() - tt, getNy() - tt, getNw() + tt, getNh() + tt);
        return (rect);
    }

    public C2DRect getRectangle() {
        return (getRectangle(0));
    }
    
    boolean contains(Block b, int tt) {
        if ((getNx() - tt) >= b.getNx()) {
            return (false);
        }
        if ((getNy() - tt) >= b.getNy()) {
            return (false);
        }
        if ((getNw() + tt) <= b.getNw()) {
            return (false);
        }
        if ((getNh() + tt) <= b.getNh()) {
            return (false);
        }
        return (true);
    }

    boolean equals(Block b, int tt) {
        boolean ret = true;
        Point2D p1, p2, p3, p4;
//        if (!this.contains(b, tt)) {
//            ret = false;
//        } else {
            p1 = new Point2D.Float((int)(getNx() - tt),(int)(getNy() - tt));
            p2 = new Point2D.Float((int)(b.getNx()), (int)(b.getNy()));

            p3 = new Point2D.Float((int)(getNw() + tt),(int)(getNh() + tt));
            p4 = new Point2D.Float((int)(b.getNw()), (int)(b.getNh()));

            if (p1.distance(p2) > tt) {
                ret = false;
            }
            if (p3.distance(p4) > tt) {
                ret = false;
            }
        //}
        return(ret);
    }

    /**
     * @return the computedImportance
     */
    public double getComputedImportance() {
        return computedImportance;
    }

    /**
     * @param computedImportance the computedImportance to set
     */
    public void setComputedImportance(double computedImportance) {
        this.computedImportance = computedImportance;
    }

    /**
     * @return the averageImportance
     */
    public double getAverageImportance() {
        return averageImportance;
    }

    /**
     * @param averageImportance the averageImportance to set
     */
    public void setAverageImportance(double averageImportance) {
        this.averageImportance = averageImportance;
    }
   
}
