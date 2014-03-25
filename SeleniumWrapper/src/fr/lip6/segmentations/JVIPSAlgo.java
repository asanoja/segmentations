/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package fr.lip6.segmentations;

/**
 *
 * @author sanojaa
 */
class JVIPSAlgo extends SeleniumWrapper{
    public void run(String category,String url,String browser) {
            String collectUrl = "http://www-poleia.lip6.fr/~sanojaa/BOM/add.php";
            this.category = category;
            this.local = false;
            browser = "chrome";
            basehost("http://localhost:8030");
            
            try {
                System.out.println("jVIPS");
                open(browser);
                String[] argss = new String[2];
                argss[0] = url;
                argss[1] = this.category;
                org.fit.vips.VipsTester.main(argss);
                setBuffer(org.fit.vips.VipsTester.Salida);
                saveTo("jvips.rec");
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