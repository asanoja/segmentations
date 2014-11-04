/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package fr.lip6.segmentations;

import java.util.ArrayList;

/**
 *
 * @author sanojaa
 */
public class Segmentation {
    public String docw="";
    public String doch="";
    public String algo="";
    public String browser="";
    public String gran="";
    public String tdcount="";
    public int page_id=0;
    public ArrayList<Record> records=new ArrayList<Record>();
    public Segmentation(int page_id,String algo,String line){
        String[] arr = line.split(",");
        this.algo = algo;
        browser = arr[1];
        gran = arr[7];
        this.page_id = page_id;
        tdcount = arr[14];
        docw=arr[4];
        doch=arr[5];
    }
    public Segmentation(int page_id,String line){
        String[] arr = line.split(",");
        algo = arr[0];
        browser = arr[1];
        gran = arr[7];
        this.page_id = page_id;
        tdcount = arr[14];
        docw=arr[4];
        doch=arr[5];
    }
    public String sql() {
        return("insert into segmentation(page_id,source1,algo,granularity,browser,doc_w,doc_h,tdcount) values('"+page_id+"','','"+algo+"','"+gran+"','"+browser+"','"+docw+"','"+doch+"','"+tdcount+"')");
    }
}
