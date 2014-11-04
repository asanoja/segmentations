/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package fr.lip6.web.evaluation;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.FontMetrics;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Point;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import javax.swing.JComponent;

/**
 *
 * @author asanoja
 */
public class BCGRender extends JComponent {
    Graphics2D graphics2D;
    final int ND=350;
    BCG bcg;
    Map<String, Point> nodeGPos = new HashMap<String, Point>();
    Map<String, Point> nodePPos = new HashMap<String, Point>();
    
    public BCGRender(BCG bcg) {
        this.bcg = bcg;
        this.setPreferredSize(new Dimension(ND+10,ND+10));  
    }
    
    private void drawNodes(int x,char t,ArrayList<Node> nodes,Graphics g)  {
       int dy = 40;
       int desp=40;
       for (Node n : nodes) {
            int centerX = x, centerY = dy;
            int ovalWidth = 30, ovalHeight = 30;
            
            FontMetrics fm = g.getFontMetrics();
            double textWidth = fm.getStringBounds(n.getBlock().getBid(), g).getWidth();
            
            if (n.isImportant()) {
                g.setColor(Color.GREEN);
            } else {
                g.setColor(Color.BLACK);
            }
            g.drawRect(centerX-ovalWidth/2, centerY-ovalHeight/2, 10+((int) textWidth), ovalHeight);
            g.setColor(Color.BLACK);
            g.drawString(n.getBlock().getBid(), (int) (centerX-ovalWidth/2)+5, (int) (centerY + fm.getMaxAscent() / 2));
            if (n.getBlock().getParent().getAlgo().equals("GT")) {
                this.nodeGPos.put(n.getBlock().getId(), new Point(centerX-ovalWidth/2+ovalWidth,centerY-ovalHeight/2));
            } else {
                this.nodePPos.put(n.getBlock().getId(), new Point(centerX-ovalWidth/2,centerY-ovalHeight/2));
            }
            dy=dy+desp;
        } 
    }
    
    private void drawEdges(ArrayList<Edge> edges,Graphics g) {
        for (Edge e : edges) {
            String startId = e.getStartNode().getBlock().getId();
            String endId = e.getStartNode().getBlock().getId();
            Point start;
            Point end;
            if (e.getStartNode().getBlock().getParent().getAlgo().equals("GT")) {
                start = this.nodeGPos.get(e.getStartNode().getBlock().getId());
            } else {
                start = this.nodePPos.get(e.getStartNode().getBlock().getId());
            }
            if (e.getEndNode().getBlock().getParent().getAlgo().equals("GT")) {
                end = this.nodeGPos.get(e.getEndNode().getBlock().getId());
            } else {
                end = this.nodePPos.get(e.getEndNode().getBlock().getId());
            }

            int xx,yy;
            
            if (start.x<end.x) {
                xx = start.x+(end.x-start.x)/2;
                 g.setColor(Color.BLUE);
            } else {
                 g.setColor(Color.RED);
                xx = start.x-(start.x-end.x)/2;
            }
            
            if (start.y<end.y) {
                yy = start.y+(end.y-start.y)/2;
            } else {
                yy = start.y-(start.y-end.y)/2;
            }
            
            System.out.println(xx+","+yy+": "+e.getWeight());
            g.drawLine(start.x, start.y+5, end.x, end.y+5);
            DecimalFormat df = (DecimalFormat)NumberFormat.getInstance(new Locale("fr"));
            g.drawString(df.format(e.getWeight()), xx, yy);
        }
    }
    
    @Override
    public void paintComponent(Graphics g) {
        drawNodes(30,'G',bcg.getNodesG(),g);
        drawNodes(200,'P',bcg.getNodesP(),g);
        drawEdges(bcg.getEdges(),g);
    }
}
