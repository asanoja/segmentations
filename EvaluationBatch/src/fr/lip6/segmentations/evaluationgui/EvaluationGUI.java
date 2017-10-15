/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package fr.lip6.segmentations.evaluationgui;

import java.awt.Container;
import java.awt.Dimension;
import java.awt.Graphics2D;
import java.awt.Toolkit;
import java.awt.event.WindowEvent;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.imageio.ImageIO;
import javax.swing.JFrame;
import javax.swing.JPanel;

/**
 *
 * @author sanojaa
 */
public class EvaluationGUI {
    public static void main(String[] args) throws IOException {
        String algo1 = args[0];
        String browser1 = args[1];
        String algo2 = args[2];
        String browser2 = args[3];
        String collection = args[4];
        String category = args[5];
        int tt = Integer.parseInt(args[6]);
        float tr = new Float(args[7]);
        
        
        
        Configuration conf1 = new Configuration(algo1, collection, category, browser1);
        Configuration conf2 = new Configuration(algo2, collection, category, browser2);
        
        InputURLParser iup = new InputURLParser(conf1);
        Parameters params;
        Evaluation e;
        int twidth = 0;
        int theight=0;
        ArrayList<BufferedImage> shots;
        ArrayList<JFrame> frames = new ArrayList<JFrame>();
        for(URL url : iup.getList()) {
//            tr=0;  //activar para hacer la evaluacion de tc y los otros
//            while (tr<=1) {
                shots = new ArrayList<BufferedImage>();
                tr = (float) (Math.round(tr*100.0f)/100.0f);
                params = new Parameters(tt,tr); 
                
                JFrame frame = new JFrame(url.toString()+" :: "+conf1.getAlgo()+" vs "+conf2.getAlgo()+" with Tr:"+params.getTr() + ", Tt:" + params.getTt());
                frame.setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
                frame.setLocationByPlatform(true);
                frame.setSize(600, 600);
                frame.setPreferredSize(new Dimension(600, 600));

                e = new Evaluation(url,conf1,conf2,params);
                frame.add(e);
                frame.add(e.prepareEvaluation());
                e.buildGraph();
                e.startEvaluation();
                frame.pack();
                frame.setVisible(true);
                Container content = frame.getContentPane();
                BufferedImage img = new BufferedImage(content.getWidth(),content.getHeight(), BufferedImage.TYPE_INT_RGB);
                Graphics2D g2d = img.createGraphics();
                try {
                    Thread.sleep(500);
                } catch (InterruptedException ex) {
                    Logger.getLogger(EvaluationGUI.class.getName()).log(Level.SEVERE, null, ex);
                }
                content.printAll(g2d);
                g2d.dispose();
                shots.add(img);
                frames.add(frame);
                twidth = img.getWidth();
                theight = img.getHeight();
//              tr+=0.1;
                
//            }
        
            int dwidth = 0;
            int dheight = 0;
            int count = 0;
            BufferedImage join = new BufferedImage(twidth ,theight,BufferedImage.TYPE_INT_RGB);
            for (BufferedImage imgout : shots) {
                join.createGraphics().drawImage(imgout,dwidth,dheight,null);
                dwidth+=img.getWidth();
                count++;
                if (count % 4 == 0) {
                    dwidth=0;
                    dheight+=imgout.getHeight();
                }
            }
            ImageIO.write(join,"png",new File("output/"+(url.getHost().replace("/", "_")+"_"+url.getPath().replace("/", "_"))+"_TT:"+tt+"_TR:"+tr+".png"));
            for (JFrame f : frames) {
                WindowEvent wev = new WindowEvent(f, WindowEvent.WINDOW_CLOSING);
                Toolkit.getDefaultToolkit().getSystemEventQueue().postEvent(wev);
                f.dispose();
            }
        }
    }
}


