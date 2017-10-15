/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package fr.lip6.segmentations.evaluationgui;



/**
 *
 * @author asanoja
 */
public class Record {
   private String bid;
   private float x;
   private float y;
   private float w;
   private float h;
   private int ecover;
   private int wcover;
   
   public Record(String rec) {
       this.parse(rec);
   }
   public void parse(String rec) {
       String[] arr = rec.split(",");
       this.setBid(arr[0]);
        this.setX(Float.parseFloat(arr[3]));
        this.setY(Float.parseFloat(arr[4]));
        this.setW(Float.parseFloat(arr[5]));
        this.setH(Float.parseFloat(arr[6]));
        this.setEcover(Integer.parseInt(arr[7]));
        this.setWcover(Integer.parseInt(arr[8]));
   }
   @Override
   public String toString() {
       return(this.getBid() +" : ["+this.getX()+","+this.getY()+","+this.getW()+","+this.getH()+"] ("+this.getEcover() + "," +this.getWcover()+")");
   }

    /**
     * @return the bid
     */
    public String getBid() {
        return bid;
    }

    /**
     * @param bid the bid to set
     */
    public void setBid(String bid) {
        this.bid = bid;
    }

    /**
     * @return the x
     */
    public float getX() {
        return x;
    }

    /**
     * @param x the x to set
     */
    public void setX(float x) {
        this.x = x;
    }

    /**
     * @return the y
     */
    public float getY() {
        return y;
    }

    /**
     * @param y the y to set
     */
    public void setY(float y) {
        this.y = y;
    }

    /**
     * @return the w
     */
    public float getW() {
        return w;
    }

    /**
     * @param w the w to set
     */
    public void setW(float w) {
        this.w = w;
    }

    /**
     * @return the h
     */
    public float getH() {
        return h;
    }

    /**
     * @param h the h to set
     */
    public void setH(float h) {
        this.h = h;
    }

    /**
     * @return the ecover
     */
    public int getEcover() {
        return ecover;
    }

    /**
     * @param ecover the ecover to set
     */
    public void setEcover(int ecover) {
        this.ecover = ecover;
    }

    /**
     * @return the wcover
     */
    public int getWcover() {
        return wcover;
    }

    /**
     * @param wcover the wcover to set
     */
    public void setWcover(int wcover) {
        this.wcover = wcover;
    }
}
