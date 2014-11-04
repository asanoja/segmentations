/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package fr.lip6.segmentations;

import java.net.URL;
import java.util.ArrayList;


/**
 *
 * @author sanojaa
 */
public class BOMAlgo extends SeleniumWrapper{
    public void run(int page_id,String url,String datafolder) {
            String pac = "6";
            String collectUrl = "http://www-poleia.lip6.fr/~sanojaa/BOM/add.php";
            this.category = category;
            this.local = false;
            basehost("http://localhost:8030");
            
            ArrayList<String> browsers = new ArrayList();
            browsers.add("chrome");
            //browsers.add("firefox");
            for (String br : browsers) {
                try {
                    
                        System.out.println("BOM");
                        open(br);
                        //HTML5 hack
                        //navigate(url);
                        navigate("http://localhost:8000/"+datafolder+"/"+datafolder+".5.html");
                        inject("jquery-min.js");
                        inject("bomlib.js");
                        inject("rectlib.js");
                        inject("polyk.js");
                        inject("md5.js");
                        inject("sniff.js");
                        execute("return startSegmentation(window,"+pac+",50,'record','"+url+"')");
                       //saveTo(br+"_bom.rec");
                       // navigate(collectUrl);
                       // placeIn("record");
                        //submit("record");
                        dbsave(url,page_id);
                        close();
                    
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    close();
                }
            }
    }

    public void run5(URL url) {
            String pac = "6";
            this.local = false;
            basehost("http://localhost:8030");
            
            ArrayList<String> browsers = new ArrayList();
            browsers.add("chrome");
            //browsers.add("firefox");
            for (String br : browsers) {
                try {
                        System.out.println("BOM");
                        open(br);
                        navigate(url.toString());
                        inject("jquery-min.js");
                        inject("bomlib.js");
                        inject("rectlib.js");
                        inject("polyk.js");
                        inject("md5.js");
                        inject("sniff.js");
                        execute("return startSegmentation(window,"+pac+",50,'descriptor','"+url.toString()+"')");
                       //saveTo(br+"_bom.rec");
                       // navigate(collectUrl);
                       // placeIn("record");
                        //submit("record");
                        //dbsave(url.toString());
                        close();
                    
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    close();
                }
            }
    }


}