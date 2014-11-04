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
public class BFAlgo extends SeleniumWrapper{
    public void run(String url,String browser) {
        String pac = "5";
            String collectUrl = "http://www-poleia.lip6.fr/~sanojaa/BOM/add.php";
            this.category = category;
            this.local = false;
            basehost("http://localhost:8030");
            
            ArrayList<String> browsers = new ArrayList();
            browsers.add(browser);
            //browsers.add("firefox");
            for (String br : browsers) {
                try {
                    System.out.println("BF");
                    open(br);
                    navigate(url);
                    inject("jquery-min.js");
                    
                    inject("bfdecorator.js");
                    execute("return bfdecorate();");
                    dumpContent();
                    saveTo("www/bfdec.html");
                                        
                    String[] args = {localUrl("bfdec.html"),System.getProperty("user.dir")+"/www/bftmp.js"};
                    de.l3s.boilerpipe.demo.HTMLBlocksDemo.main(args);
                    
                    inject("rectlib.js");
                    inject("polyk.js");
                    inject("bfanalyzer.js");
                    inject("bftmp.js");
                    
                    execute("return bfprocess("+pac+")");
                    
                    setBuffer(new BFProcess().parse(getBuffer(),br,url,pac));
                    saveTo(br+"_bf.rec");
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