package fr.lip6.web.evaluation;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import javax.swing.JComponent;

public class SegmentationRender extends JComponent {
    Graphics2D graphics2D;
    final int ND=350;
    Segmentation segmentation;
    
    public SegmentationRender(Segmentation segmentation) {
        this.segmentation = segmentation;
        this.setPreferredSize(new Dimension(ND+10,ND+10));
    }
    @Override
    public void paintComponent(Graphics g) {
       g.setColor(Color.GRAY);
       g.drawRect(0, 0, ND, ND);
       

       for (Block b : segmentation.getBlocks()) {
           int x,y,w,h;
           x=((int) b.getNx())*ND/100;
           y=((int) b.getNy())*ND/100;
           w=((int) b.getNw())*ND/100;
           h=((int) b.getNh())*ND/100;
          
           g.setColor(segmentation.getColor());
           g.drawRect(x, y, w-x, h-y);
//           g.setColor(Color.BLACK);
//           g.drawRect(x, y, w-x, h-y);
           g.drawString(b.getBid(), x, y+10);
       }
    }
}
