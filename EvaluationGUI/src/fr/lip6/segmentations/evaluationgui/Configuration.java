/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package fr.lip6.segmentations.evaluationgui;
/**
 *
 * @author sanojaa
 */
public class Configuration {
    private String algo;
    private String browser;
    private String category;
    private String collection;
    
    public Configuration(String algo,String collection, String category,String browser) {
        this.algo = algo;
        this.collection = collection;
        this.category = category;
        this.browser = browser;
    }

    /**
     * @return the algo
     */
    public String getAlgo() {
        return algo;
    }
    public String getAlgoData() {
        return(getAlgo().toUpperCase()+"data");
    }
    /**
     * @return the browser
     */
    public String getBrowser() {
        return browser;
    }

    /**
     * @return the category
     */
    public String getCategory() {
        return category;
    }

    /**
     * @return the collection
     */
    public String getCollection() {
        return collection;
    }
}
