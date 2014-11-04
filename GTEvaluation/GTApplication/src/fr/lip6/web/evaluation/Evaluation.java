/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package fr.lip6.web.evaluation;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DecimalFormat;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author asanoja
 */
public class Evaluation {
    private Segmentation g;
    private Segmentation p;
    private BCG bcg;
    private int cc;
    private int cm;
    private int cf;
    private int co;
    private int cu;
    private int cq;
    private int icc;
    private int ico;
    private int icu;
    private int icm;
    private int icf;
    private int icq;
    private double prec;
    private double iprec;
    
    public Evaluation(Segmentation g,Segmentation p) {
        this.g = g;
        this.p = p;
        this.bcg = new BCG(g,p);
        this.cc = 0;
        this.cm = 0;
        this.cf = 0;
        this.co = 0;
        this.cu = 0;
        this.cq = 0;
        
        this.icc = 0;
        this.ico = 0;
        this.icu = 0;
        this.icm = 0;
        this.icf = 0;
        this.icq = 0;
        this.prec = 0;
        this.iprec = 0;
        
    }
    
    public void createBCG(double tr,int tt) {
        boolean goNext = false;
        for (Node ni : bcg.getNodesG()) {
            goNext=false;
            for (Node nj : bcg.getNodesP()) {
                if (ni.getBlock().equals(nj.getBlock(), 0)) {
                    bcg.addEdge(ni, nj);
                    goNext = true;
                    break;
                } else {
                    if (ni.getBlock().equals(nj.getBlock(), tt)) {
                        if (bcg.computeWeight(ni, nj)>tr) {
                            bcg.addEdge(ni, nj);
                            goNext = true;
                            break;
                        }
                    } else {
                        if (ni.getBlock().contains(nj.getBlock(), tt)) {
                            if (bcg.computeWeight(ni, nj)>tr) {
                                bcg.addEdge(ni, nj);
                            }
                        } else {
                            if (nj.getBlock().contains(ni.getBlock(), tt)) {
                                if (bcg.computeWeight(nj, ni)>tr) {
                                    bcg.addEdge(nj, ni);
                                }
                            }
                        }
                    }
                }
                if (goNext) break;
            }
            
        }
        
    }
    
    
    public void measure(double ti) {
        for (Edge e : bcg.getEdges()) {
            Node ni = e.getStartNode();
            Node nj = e.getEndNode();
            Node gtnode;
            
            if ("GT".equals(ni.getBlock().getParent().getAlgo())) {
                gtnode = ni;
            } else {
                gtnode = nj;
            }
            
            if (ni.getOut()==1 && nj.getIn()==1) {
                cc++;
                if (gtnode.getBlock().getAverageImportance()>ti) {
                    icc++;
                }
            }
        }
        for (Node n : bcg.getNodesG()) {
            if (n.getOut()>1) {
                co++;
                if (n.getBlock().getAverageImportance()>ti) {
                    ico++;
                }
            } else {
                if (n.getOut()==0 && n.getIn()==0) {
                    cm++;
                    if (n.getBlock().getAverageImportance()>ti) {
                        icm++;
                    }
                }
            }
            if (n.getBlock().getAverageImportance()>ti) {
                n.setImportant(true);
            }
        }
        for (Node n : bcg.getNodesP()) {
            if (n.getOut()>1) {
                cu++;
                if (n.getBlock().getAverageImportance()>ti) {
                    icu++;
                }
            } else {
                if (n.getOut()==0 && n.getIn()==0) {
                    cf++;
                    if (n.getBlock().getAverageImportance()>ti) {
                        icf++;
                    }
                }
            }
            if (n.getBlock().getAverageImportance()>ti) {
                n.setImportant(true);
            }
        }
        cq=cc+co+cu;
        icq = icc+ico+icu;
        prec = (double) cq / (double) g.getBlocks().size();
        iprec = (double) cq / (double) g.getImportantBlocks(ti).size();
    }
    
    public BCG evaluate(double tr,int tt, double ti) {
        createBCG(tr, tt);
        measure(ti);
        return bcg;
        
    }
    
    public int getCc() {
        return cc;
    }

    /**
     * @return the cm
     */
    public int getCm() {
        return cm;
    }

    /**
     * @return the cf
     */
    public int getCf() {
        return cf;
    }

    /**
     * @return the co
     */
    public int getCo() {
        return co;
    }

    /**
     * @return the cu
     */
    public int getCu() {
        return cu;
    }

    /**
     * @return the cq
     */
    public int getCq() {
        return cq;
    }

    /**
     * @return the prec
     */
    public String getPrec() {
         DecimalFormat df = new DecimalFormat("#.00");
        return df.format(prec);
    }
    
    public void save(int tt,double tr,double ti) {
        try {
            Class.forName("com.mysql.jdbc.Driver").newInstance();
            Connection con = DriverManager.getConnection("jdbc:mysql://"+Config.mysqlHost+"/"+Config.mysqlDatabase+"", Config.mysqlUser, Config.mysqlPassword);
            Statement st = con.createStatement();
            String sql = ("insert into metrics(page_id,cc,co,cu,cm,cf,cq,icc,ico,icu,icm,icf,icq,tt,tr,ti,gtb,ptb,igtb,iptb,segmentation1_id,segmentation2_id) values ('"+g.getPage_id()+"','"+getCc()+"','"+getCo()+"','"+getCu()+"','"+getCm()+"','"+getCf()+"','"+getCq()+"','"+getICc()+"','"+getICo()+"','"+getICu()+"','"+getICm()+"','"+getICf()+"','"+getICq()+"','"+tt+"','"+tr+"','"+ti+"','"+g.getBlocks().size()+"','"+p.getBlocks().size()+"','"+g.getImportantBlocks(ti).size()+"','"+p.getImportantBlocks(ti).size()+"','"+g.getId()+"','"+p.getId()+"');");
            st.executeUpdate(sql);
            con.close();
        } catch (ClassNotFoundException | SQLException | InstantiationException | IllegalAccessException ex) {
            Logger.getLogger(GTApplication.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    /**
     * @return the ico
     */
    public int getICo() {
        return ico;
    }

    /**
     * @return the icu
     */
    public int getICu() {
        return icu;
    }

    /**
     * @return the icm
     */
    public int getICm() {
        return icm;
    }

    /**
     * @return the icf
     */
    public int getICf() {
        return icf;
    }

    /**
     * @return the icq
     */
    public int getICq() {
        return icq;
    }

    public int getICc() {
       return icc;
    }
}
