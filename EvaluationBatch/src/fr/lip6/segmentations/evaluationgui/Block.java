/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package fr.lip6.segmentations.evaluationgui;

import java.awt.geom.Point2D;
import java.util.ArrayList;
import uk.co.geolib.geolib.C2DRect;

/**
 *
 * @author asanoja
 */
public abstract class Block {

    private Record record;
    private C2DRect rect;
    private ArrayList<Block> match;

    public Block() {

    }

    public Block(Record rec) {
        this.record = rec;
        this.rect = new C2DRect();
        this.rect.Set(getX(), getY(), getW(), getH());
        this.match = new ArrayList<Block>();
    }

    /**
     * @return the bid
     */
    public String getBid() {
        return this.record.getBid();
    }

    /**
     * @return the x
     */
    public float getX() {
        return this.record.getX();
    }

    /**
     * @return the y
     */
    public float getY() {
        return this.record.getY();
    }

    /**
     * @return the w
     */
    public float getW() {
        return this.record.getW();
    }

    /**
     * @return the h
     */
    public float getH() {
        return this.record.getH();
    }

    /**
     * @return the ecover
     */
    public int getEcover() {
        return this.record.getEcover();
    }

    /**
     * @return the wcover
     */
    public int getWcover() {
        return this.record.getWcover();
    }

    public String toString() {
        return (getBid());
    }

    public Record getRecord() {
        return (record);
    }

    public C2DRect getRectangle(int tt) {
        C2DRect aux = new C2DRect();
        System.out.println(getRecord().toString());
        System.out.println((rect.GetLeft() - tt) + "," + (rect.GetTop() - tt) + "," + (rect.GetRight() + tt) + "," + (rect.GetBottom() + tt));
        aux.Set(rect.GetLeft() - tt, rect.GetTop() - tt, rect.GetRight() + tt, rect.GetBottom() + tt);
        return (aux);
    }

    public C2DRect getRectangle() {
        return (getRectangle(0));
    }

    public float weight() {
        return(getEcover());
    }
    
    boolean contains(Block pb, int tt) {
        if ((getX() - tt) > pb.getX()) {
            return (false);
        }
        if ((getY() - tt) > pb.getY()) {
            return (false);
        }
        if ((getW() + tt) < pb.getW()) {
            return (false);
        }
        if ((getH() + tt) < pb.getH()) {
            return (false);
        }
        return (true);
    }

    boolean equals(Block pb, int tt) {
        boolean ret = true;
        Point2D p1, p2, p3, p4;
        if (!this.contains(pb, tt)) {
            ret = false;
        } else {
            p1 = new Point2D.Float(getX() - tt, getY() - tt);
            p2 = new Point2D.Float(pb.getX(), pb.getY());

            p3 = new Point2D.Float(getW() + tt, getH() + tt);
            p4 = new Point2D.Float(pb.getW(), pb.getH());

            if (p1.distance(p2) > tt) {
                ret = false;
            }
            if (p3.distance(p4) > tt) {
                ret = false;
            }
        }
        return(ret);
    }

public void addMatch(Block b) {
    match.add(b);
}

    /**
     * @return the match
     */
    public ArrayList<Block> getMatch() {
        return match;
    }
}
/*
 recordar esto para ubicar los bloques luego
 Transformer<Integer, Shape> vertexShape = 
 new Transformer<Integer, Shape>() {
 private final Shape[] styles = { 
 new Rectangle(-20, -10, 40, 20),
 new Ellipse2D.Double(-25, -10, 50, 20),
 new Arc2D.Double(-30, -15, 60, 30, 30, 30, 
 Arc2D.PIE) };
 
 @Override
 public Shape transform(Integer i) {
 return styles[i.intValue() % styles.length];
 }
 };

 */
