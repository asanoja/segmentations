/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package fr.lip6.web.evaluation;

import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;
import java.lang.reflect.InvocationTargetException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Locale;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextField;
import javax.swing.SwingUtilities;
import javax.swing.SwingWorker;

/**
 *
 * @author sanojaa
 */
public class GTApplication {
    JFrame mainFrame = new JFrame();
    
    JPanel optionsPanel;
    
    JPanel segmentations;
    JPanel gtPanel;
    JPanel segPanel;
    
    JPanel results;
    JPanel dataPanel;
    JScrollPane graphPanel;
    
    JLabel lblCategory;
    JLabel lblCollection;
    JLabel lblUrl;
    JLabel lblAlgo;
    JLabel lblTr;
    JLabel lblTt;
//    JLabel lblSeg1;
//    JLabel lblSeg2;
//    JLabel lblCc;
//    JLabel lblCo;
//    JLabel lblCu;
//    JLabel lblCm;
//    JLabel lblCf;
//    JLabel lblCq;
//    JLabel lblPrec;
    
//    JTextField txtSeg1;
//    JTextField txtSeg2;
//    JTextField txtCc;
//    JTextField txtCo;
//    JTextField txtCu;
//    JTextField txtCm;
//    JTextField txtCf;
//    JTextField txtCq;
//    JTextField txtPrec;
    JList output;
    
    JButton btnGo;
    JButton btnBatch;
    
    ArrayList colarr;
    ArrayList catarr;
    ArrayList urlarr;
    ArrayList algoarr;
    
    JComboBox comboCollection;
    JComboBox comboCategory;
    JComboBox comboUrl;
    JComboBox comboAlgo;
    JComboBox comboTr;
    JComboBox comboTt;
    JComboBox comboTi;
    JLabel lblTi;
    
    Segmentation sg;
    Segmentation sp;
    
    boolean filling=false;
    SwingWorker worker;
    Evaluation eval;
    
    
    
    public GTApplication() {
        mainFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        mainFrame.setTitle("GT Evaluation");
        mainFrame.setSize(1000,1000);
        mainFrame.setLocationRelativeTo(null);
        
        optionsPanel = new JPanel();
        gtPanel = new JPanel();
        segPanel = new JPanel();
        dataPanel = new JPanel();
        graphPanel = new JScrollPane();
        
        gtPanel.setPreferredSize(new Dimension(400,400));
        segPanel.setPreferredSize(new Dimension(400,400));
        dataPanel.setPreferredSize(new Dimension(400,400));
        graphPanel.setPreferredSize(new Dimension(400,400));
        gtPanel.setBorder(BorderFactory.createDashedBorder(Color.GREEN));
        segPanel.setBorder(BorderFactory.createDashedBorder(Color.GREEN));
        dataPanel.setBorder(BorderFactory.createDashedBorder(Color.GREEN));
        graphPanel.setBorder(BorderFactory.createDashedBorder(Color.GREEN));
        
        
        lblCollection = new JLabel("Collection");
        colarr = getCollectionArray();
        comboCollection = new JComboBox(colarr.toArray());
        comboCollection.setRenderer(new MyListRenderer());
        comboCollection.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
              if ((e.getStateChange() == ItemEvent.SELECTED)) {
                    filling=true;
                    ComboItem ci = (ComboItem) comboCollection.getSelectedItem();
                    System.out.println("Selected Value From Collection is :   " + ci.value);
                    catarr = getCategoriesArray(ci.key);
                    comboCategory.removeAllItems();
                    for (int i=0;i<catarr.size();i++)  {
                        comboCategory.addItem(catarr.get(i));
                    }
                    btnBatch.setEnabled(true);
                    gtPanel.removeAll();
                    segPanel.removeAll();
                    //graphPanel.removeAll();
                    filling=false;
                }
            }
        });
        
        lblCategory = new JLabel("Category");
        comboCategory = new JComboBox();
        comboCategory.addItem(new ComboItem("",""));
        comboCategory.setRenderer(new MyListRenderer());
        comboCategory.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
              if ((e.getStateChange() == ItemEvent.SELECTED) && !filling) {
                    filling=true;
                    if (comboCategory.getSelectedItem() instanceof ComboItem) {
                        ComboItem ci = (ComboItem) comboCategory.getSelectedItem();
                        System.out.println("Selected Value From Category is :   " + ci.value);
                        urlarr = getUrlArray(ci.key);
                        comboUrl.removeAllItems();
                        for (int i=0;i<urlarr.size();i++)  {
                            comboUrl.addItem(urlarr.get(i));
                        }
                        gtPanel.removeAll();
                        segPanel.removeAll();
                        //graphPanel.removeAll();
                    }
                    filling=false;
                }
            }
        });
        
        lblUrl = new JLabel("Url");
        comboUrl = new JComboBox();
        comboUrl.addItem(new ComboItem("",""));
        comboUrl.setRenderer(new MyListRenderer());
        comboUrl.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
              if ((e.getStateChange() == ItemEvent.SELECTED) && !filling) {
                    filling=true;
                    ComboItem ci = (ComboItem) comboUrl.getSelectedItem();
                    System.out.println("Selected Value From Url is :   " + ci.value);
                    algoarr = getAlgoArray(ci.key);
                    comboAlgo.removeAllItems();
                    for (int i=0;i<algoarr.size();i++)  {
                        comboAlgo.addItem(algoarr.get(i));
                    }
                    sg=new Segmentation(ci.key,"GT");
                    sg.setColor(Color.blue);
                    gtPanel.removeAll();
                    segPanel.removeAll();
                    //graphPanel.removeAll();
                    gtPanel.add(new SegmentationRender(sg));
                    segmentations.revalidate();
                    segmentations.repaint();
                    filling=false;
                }
            }
        });
        
        lblAlgo = new JLabel("Algo");
        comboAlgo = new JComboBox();
        comboAlgo.addItem(new ComboItem("",""));
        comboAlgo.setRenderer(new MyListRenderer());
        comboAlgo.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
              if ((e.getStateChange() == ItemEvent.SELECTED) && !filling) {
                    filling=true;
                    go();
                    filling=false;
                }
            }
        });
        
        lblTr = new JLabel("Tr");
        comboTr = new JComboBox();
        for (double k=0;k<1;k+=0.1) {
            //DecimalFormat df = new DecimalFormat("0,00");
            DecimalFormat df = (DecimalFormat)NumberFormat.getInstance(new Locale("fr"));
            comboTr.addItem(new ComboItem(df.format(k),df.format(k)));
        }
        
        comboTr.setRenderer(new MyListRenderer());
        
        lblTt = new JLabel("Tt");
        comboTt = new JComboBox();
        for (int k=0;k<5;k++) {
            comboTt.addItem(new ComboItem(Integer.toString(k),Integer.toString(k)));
        }
        comboTt.setRenderer(new MyListRenderer());
        
        lblTi = new JLabel("Ti");
        comboTi = new JComboBox();
        for (double k=0;k<1;k+=0.1) {
            DecimalFormat df = (DecimalFormat)NumberFormat.getInstance(new Locale("fr"));
            comboTi.addItem(new ComboItem(df.format(k),df.format(k)));
        }
        comboTi.setRenderer(new MyListRenderer());
        
        btnGo = new JButton("Go");
        btnGo.addActionListener(new ActionListener() {

            @Override
            public void actionPerformed(ActionEvent e) {
                go();
            }
        });
        btnBatch = new JButton("Batch");
        btnBatch.setEnabled(false);
        btnBatch.addActionListener(new ActionListener() {

            @Override
            public void actionPerformed(ActionEvent e) {
                if (btnBatch.getText()=="Batch") {
                    btnBatch.setText("Stop");
                    worker = new SwingWorker() {

                        @Override
                        protected Object doInBackground() throws Exception {
                            batch();
                            return(null);
                        }
                        @Override
                        public void done() {
                            btnBatch.setText("Batch");
                            comboCategory.setSelectedIndex(0);
                        }


                    };

                    worker.execute();
                } else {
                    if (worker!=null) {
                        worker.cancel(false);
                        worker=null;
                    }
                }
                
            }
        });
        
        //optionsPanel.add(lblCollection);
        optionsPanel.add(comboCollection);
        //optionsPanel.add(lblCategory);
        optionsPanel.add(comboCategory);
        //optionsPanel.add(lblUrl);
        optionsPanel.add(comboUrl);
        //optionsPanel.add(lblAlgo);
        optionsPanel.add(comboAlgo);
        optionsPanel.add(comboTr);
        optionsPanel.add(comboTt);
        optionsPanel.add(comboTi);
        optionsPanel.add(btnGo);
        optionsPanel.add(btnBatch);
        
//        lblSeg1 = new JLabel("Seg1");
//        txtSeg1 = new JTextField("");
//        lblSeg2 = new JLabel("Seg2");
//        txtSeg2 = new JTextField("");
//        lblCc = new JLabel("Cc");
//        txtCc = new JTextField("");
//        lblCo = new JLabel("Co");
//        txtCo = new JTextField("");
//        lblCu = new JLabel("Cu");
//        txtCu = new JTextField("");
//        lblCm = new JLabel("Cm");
//        txtCm = new JTextField("");
//        lblCf = new JLabel("Cf");
//        txtCf = new JTextField("");
//        lblCq = new JLabel("Cq");
//        txtCq = new JTextField("");
//        lblPrec = new JLabel("Prec");
//        txtPrec = new JTextField("");
        
//        dataPanel.add(lblSeg1);
//        dataPanel.add(txtSeg1);
//        dataPanel.add(lblSeg2);
//        dataPanel.add(txtSeg2);
//        dataPanel.add(lblCc);
//        dataPanel.add(txtCc);
//        dataPanel.add(lblCo);
//        dataPanel.add(txtCo);
//        dataPanel.add(lblCu);
//        dataPanel.add(txtCu);
//        dataPanel.add(lblCm);
//        dataPanel.add(txtCm);
//        dataPanel.add(lblCf);
//        dataPanel.add(txtCf);
//        dataPanel.add(lblCq);
//        dataPanel.add(txtCq);
//        dataPanel.add(lblPrec);
//        dataPanel.add(txtPrec);
        output = new JList();
        dataPanel.add(output);
        
        mainFrame.setLayout(new BoxLayout(mainFrame.getContentPane(), BoxLayout.Y_AXIS));
        
        //optionsPanel.setAlignmentX(Component.CENTER_ALIGNMENT);
        //gtPanel.setAlignmentX(Component.LEFT_ALIGNMENT);
        //segPanel.setAlignmentX(Component.RIGHT_ALIGNMENT);
        
        mainFrame.add(optionsPanel);
        
        segmentations = new JPanel();
        segmentations.add(gtPanel);
        segmentations.add(segPanel);
        segmentations.add(graphPanel);
        segmentations.setAlignmentX(Component.CENTER_ALIGNMENT);
        mainFrame.add(segmentations);
        
        results = new JPanel();
        results.add(dataPanel);
       
        results.setAlignmentX(Component.CENTER_ALIGNMENT);
        mainFrame.add(results);
        mainFrame.setExtendedState(mainFrame.MAXIMIZED_BOTH);  
        mainFrame.setVisible(true);
    }
    
    public static void main(String[] args) {    
        SwingUtilities.invokeLater(new Runnable() {
            @Override
            public void run() {
                GTApplication gtapp = new GTApplication();
            }
        });
    }

    private ArrayList getCollectionArray() {
        ArrayList output = new ArrayList();
        output.add("");
        try {
            Class.forName("com.mysql.jdbc.Driver").newInstance();
            //Connection con = DriverManager.getConnection("jdbc:mysql://localhost/bom", "bom", "DL77ESuQZT2a3q6X");
            Connection con = DriverManager.getConnection("jdbc:mysql://"+Config.mysqlHost+"/"+Config.mysqlDatabase+"", Config.mysqlUser, Config.mysqlPassword);
            Statement st = con.createStatement();
            String sql = ("SELECT * FROM collection ORDER BY name;");
            ResultSet rs = st.executeQuery(sql);
            while(rs.next()) {
                String id = rs.getString("id");
                String name = rs.getString("id");
                //output.add(name+" ("+id+")");
                output.add(new ComboItem(id,name));
            }
            con.close();
        } catch (ClassNotFoundException | SQLException | InstantiationException | IllegalAccessException ex) {
            Logger.getLogger(GTApplication.class.getName()).log(Level.SEVERE, null, ex);
        }
        return(output);
    }
    private ArrayList getCategoriesArray(String collection_id) {
        ArrayList output = new ArrayList();
        output.add("");
        try {
            Class.forName("com.mysql.jdbc.Driver").newInstance();
            //Connection con = DriverManager.getConnection("jdbc:mysql://localhost/bom", "bom", "DL77ESuQZT2a3q6X");
            Connection con = DriverManager.getConnection("jdbc:mysql://"+Config.mysqlHost+"/"+Config.mysqlDatabase+"", Config.mysqlUser, Config.mysqlPassword);
            Statement st = con.createStatement();
            String sql = ("SELECT * FROM categories where collection_id='"+collection_id+"' ORDER BY name;");
            ResultSet rs = st.executeQuery(sql);
            while(rs.next()) {
                String id = rs.getString("id");
                String name = rs.getString("name");
                //output.add(name+" ("+id+")");
                output.add(new ComboItem(id,name));
            }
            con.close();
        } catch (ClassNotFoundException | SQLException | InstantiationException | IllegalAccessException ex) {
            Logger.getLogger(GTApplication.class.getName()).log(Level.SEVERE, null, ex);
        }
        return(output);
    }
    private ArrayList getUrlArray(String category_id) {
        ArrayList output = new ArrayList();
        output.add("");
        try {
            Class.forName("com.mysql.jdbc.Driver").newInstance();
            //Connection con = DriverManager.getConnection("jdbc:mysql://localhost/bom", "bom", "DL77ESuQZT2a3q6X");
            Connection con = DriverManager.getConnection("jdbc:mysql://"+Config.mysqlHost+"/"+Config.mysqlDatabase+"", Config.mysqlUser, Config.mysqlPassword);
            Statement st = con.createStatement();
            int maxseg=4;
            String sql = ("SELECT pages.id id,pages.url url,count(segmentation.id) c FROM pages inner join segmentation on segmentation.page_id=pages.id where category_id='"+category_id+"' group by segmentation.page_id having c>"+maxseg+" ORDER BY url;");
            ResultSet rs = st.executeQuery(sql);
            while(rs.next()) {
                String id = rs.getString("id");
                String name = rs.getString("url");
                //output.add(name+" ("+id+")");
                output.add(new ComboItem(id,name));
            }
            con.close();
        } catch (ClassNotFoundException | SQLException | InstantiationException | IllegalAccessException ex) {
            Logger.getLogger(GTApplication.class.getName()).log(Level.SEVERE, null, ex);
        }
        return(output);
    }
    private ArrayList getAlgoArray(String page_id) {
        ArrayList output = new ArrayList();
        output.add("");
        try {
            Class.forName("com.mysql.jdbc.Driver").newInstance();
            //Connection con = DriverManager.getConnection("jdbc:mysql://localhost/bom", "bom", "DL77ESuQZT2a3q6X");
            Connection con = DriverManager.getConnection("jdbc:mysql://"+Config.mysqlHost+"/"+Config.mysqlDatabase+"", Config.mysqlUser, Config.mysqlPassword);
            Statement st = con.createStatement();
            String sql = ("SELECT algorithms.id id,algorithms.name name FROM algorithms inner join segmentation on segmentation.algo=algorithms.id where page_id='"+page_id+"' and algo<>'GT' ORDER BY algorithms.ord asc;");
            ResultSet rs = st.executeQuery(sql);
            while(rs.next()) {
                String id = rs.getString("id");
                String name = rs.getString("id");
                //output.add(name+" ("+id+")");
                output.add(new ComboItem(id,name));
            }
            con.close();
        } catch (ClassNotFoundException | SQLException | InstantiationException | IllegalAccessException ex) {
            Logger.getLogger(GTApplication.class.getName()).log(Level.SEVERE, null, ex);
        }
        return(output);
    }
    
    public void go() {
        ComboItem ciu = (ComboItem) comboUrl.getSelectedItem();
        ComboItem cia = (ComboItem) comboAlgo.getSelectedItem();
        ComboItem citr = (ComboItem) comboTr.getSelectedItem();
        ComboItem citt = (ComboItem) comboTt.getSelectedItem();
        ComboItem citi = (ComboItem) comboTi.getSelectedItem();
        
        gtPanel.removeAll();
        segPanel.removeAll();
        
        sg=new Segmentation(ciu.key,"GT");
        sg.setColor(Color.blue);
        
        sp=new Segmentation(ciu.key,cia.key);
        sp.setColor(Color.red);
        
        gtPanel.add(new SegmentationRender(sg));
        segPanel.add(new SegmentationRender(sp));
        
        eval = new Evaluation(sg,sp);
        double tr = Double.parseDouble(citr.value.replaceAll(",", "."));
        int tt = Integer.parseInt(citt.value);
        double ti = Double.parseDouble(citi.value.replaceAll(",", "."));
        
        BCG bcg = eval.evaluate(tr,tt,ti);
        BCGRender bcgr = new BCGRender(bcg);
        
        output.
        txtSeg1.setText(sg.getCompositeId());
        txtSeg2.setText(sp.getCompositeId());
        txtCc.setText(String.valueOf(eval.getCc()));
        txtCo.setText(String.valueOf(eval.getCo()));
        txtCu.setText(String.valueOf(eval.getCu()));
        txtCm.setText(String.valueOf(eval.getCm()));
        txtCf.setText(String.valueOf(eval.getCf()));
        txtCq.setText(String.valueOf(eval.getCq()));
        txtPrec.setText(String.valueOf(eval.getPrec()));

        //graphPanel.removeAll();
        graphPanel.add(bcgr);
        graphPanel.setViewportView(bcgr);
        int maxnodes = Math.max(bcg.getNodesG().size(),bcg.getNodesP().size());
        graphPanel.setPreferredSize(new Dimension(300,maxnodes*50));
        segmentations.revalidate();
        segmentations.repaint();
    }
    
    public void batch()  {
        String collection_id = ((ComboItem) comboCollection.getSelectedItem()).key;
        String category_id;
        String page_id;
        String algo_id;
        double tr = Double.parseDouble(((ComboItem) comboTr.getSelectedItem()).value);
        double ti = Double.parseDouble(((ComboItem) comboTi.getSelectedItem()).value);
        int tt = Integer.parseInt(((ComboItem) comboTt.getSelectedItem()).value);
        for (int i = 0; i<comboCategory.getItemCount();i++) {
            comboCategory.setSelectedIndex(i);
            if ((comboCategory.getSelectedItem()) instanceof ComboItem) {
                category_id = ((ComboItem) comboCategory.getSelectedItem()).key;
                for (int j=0;j<comboUrl.getItemCount();j++) {
                    comboUrl.setSelectedIndex(j);
                    if ((comboUrl.getSelectedItem()) instanceof ComboItem) {
                        page_id = ((ComboItem) comboUrl.getSelectedItem()).key;
                        for (int k=0;k<comboAlgo.getItemCount();k++) {
                            comboAlgo.setSelectedIndex(k);
                            if ((comboAlgo.getSelectedItem()) instanceof ComboItem) {
                                algo_id = ((ComboItem) comboAlgo.getSelectedItem()).key;
                                go();
                                eval.save(tt,tr,ti);
                                try {
                                    Thread.sleep(100);
                                } catch (InterruptedException ex) {
                                    Logger.getLogger(GTApplication.class.getName()).log(Level.SEVERE, null, ex);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

