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
public class BOMAlgo extends SeleniumWrapper{
    public void run(String category,String url,String browser) {
            String pac = "3";
            String collectUrl = "http://www-poleia.lip6.fr/~sanojaa/BOM/add.php";
            this.category = category;
            this.local = false;
            basehost("http://localhost:8030");
            
            ArrayList<String> browsers = new ArrayList();
            browsers.add(browser);
            //browsers.add("firefox");
            for (String br : browsers) {
                try {
                    
                        System.out.println("BOM");
                        open(br);
                        navigate(url);
                        inject("jquery-min.js");
                        inject("bomlib.js");
                        inject("rectlib.js");
                        inject("polyk.js");
                        inject("md5.js");
                        inject("sniff.js");
                        execute("startSegmentation(window,"+pac+",50,true);return getRecord(page,'"+url+"')");
                        saveTo(br+"_bom.rec");
                        navigate(collectUrl);
                        placeIn("record");
                        submit("record");
                        close();
                    
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    close();
                }
            }
    }
}