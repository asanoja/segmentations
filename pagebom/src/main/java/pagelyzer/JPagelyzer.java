/*
# Andrés Sanoja
# UPMC - LIP6
# pagelyzer 
#
# Copyright (C) 2011, 2012, 2013, 2014 Andrés Sanoja, Université Pierre et Marie Curie -
# Laboratoire d'informatique de Paris 6 (LIP6)
#
# Authors
# Andrés Sanoja andres.sanoja@lip6.fr
# Alexis Lechervy alexis.lechervy@lip6.fr
# Zeynep Pehlivan zeynep.pehlivan@lip6.fr
# Myriam Ben Saad myriam.ben-saad@lip6.fr
# Marc Law marc.law@lip6.fr
# Carlos Sureda carlos.sureda@lip6.fr
# Jordi Creus jordi.creus@lip6.fr
# LIP6 / Université Pierre et Marie Curie

# Responsables WP
# Matthieu CORD/UPMC
# Stéphane GANÇARSKI/UPMC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# Some parts of this package are adapted from the BrowserShot proyect developed by IM, France.
# https://github.com/sbarton/browser-shot-tool-mapred
 */

package pagelyzer;


import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URISyntaxException;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.apache.commons.cli.BasicParser;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.configuration.ConfigurationException;
import org.apache.commons.configuration.XMLConfiguration;

//import Scape.MarcAlizer;
//import Scape.ScapeTrain;

/**
 * Class to calculate de change detection between two web pages
 * @author sanojaa
 */
public class JPagelyzer {

     public XMLConfiguration config;

     Options displayoptions = new Options();
//     public String comparemode ;// public to use in test
//     String cfile;
     String target;
     Boolean isDebugActive = false;
     String debugfilePattern;
     String debugPathtoSave ;
     String outputfile;
     boolean screenshot;
     boolean segmentation;
     boolean mirror;
     CaptureResult result;
//     boolean isTrain;
//     ScapeTrain sc ;
//     MarcAlizer marcalizer;
     public String browser;
//     public  String browser2; // public to use in test
//     int idcounter = 0; // to count how many time change detection called and use this counter as id to save files if debug mode is on
     public static final String LOCAL = "local";
     /**
 * Constant remote
 */
//     public static final String MODE_IMAGE = "image";
//     public static final String MODE_CONTENT = "content";
//     public static final String MODE_HYBRID = "hybrid";
     public static final String REMOTE = "remote";
     /**
 * Constant score
 */
//     public static final String SCORE = "score";
     /**
 * Constant screenshot
 */
     public static final String SCREENSHOT = "screenshot";
     /**
 * Constant source
 */
     public static final String SOURCE = "source";
     /**
 * Constant segmentation
 */
     public static final String SEGMENTATION = "segmentation";
     public static final String MIRROR = "mirror";

     public String url1, url2,url;
    /**
     * get the current configuration
     * @return the current configuration
     */
    public XMLConfiguration getConfig() {
        return(this.config);
    }

    public JPagelyzer(String url, String config) {
        this(new String[]{"-url",url,"-config",config},false);
    }
  
    public JPagelyzer(String[] args, boolean isTrain)
    {
//    	this.isTrain = isTrain;
        // no need any more cpath browser etc. they are all in config file
    	// not to change the usage of options I am adding display options to send to usage.
        displayoptions.addOption("get",true,"The functionality to run: "+SCREENSHOT+", "+SOURCE+" or "+SEGMENTATION+" or "+MIRROR);
    	displayoptions.addOption("url",true,"The URL to process");
//    	displayoptions.addOption("url2",true,"Second URL to compare");
    	displayoptions.addOption("config",true,"Global configuration file for an example of file: https://github.com/openplanets/pagelyzer/blob/master/config.xml");
//    	displayoptions.addOption("mode",true,"hybrid/content/image it can be also set in config file");

        CommandLineParser parser = new BasicParser();
        CommandLine cmd;
        
        /* Parsing comandline parameters*/
        try {
            cmd = parser.parse(displayoptions, args);
        } catch (ParseException pe) { 
            usage(displayoptions); return; 
        }
        if (!cmd.hasOption("config")) {usage(displayoptions);System.exit(0);}

		try {
			config = new XMLConfiguration(cmd.getOptionValue("config"));
			
		} catch (ConfigurationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        
//		if(displayoptions.getOption("mode").getValue()!=null)
//			
//			comparemode= displayoptions.getOption("mode").getValue();
//		else 
//        
//			comparemode = this.config.getString("pagelyzer.run.default.comparison.mode");
		
		
//		cfile = config.getString("pagelyzer.run.default.comparison.subdir")+ "ex_" + config.getString("pagelyzer.run.default.comparison.mode") +".xml";
		isDebugActive =  config.getBoolean("pagelyzer.debug.screenshots.active");
		debugfilePattern = config.getString("pagelyzer.debug.screenshots.filepattern");
		debugPathtoSave = config.getString("pagelyzer.debug.screenshots.path");
		outputfile = config.getString("pagelyzer.run.default.parameter.outputfile");
		browser = config.getString("pagelyzer.run.default.parameter.browser");
//		browser2 = config.getString("pagelyzer.run.default.parameter.browser2");
		
		
//		this.config.setProperty("pagelyzer.run.default.comparison.file","ex_"+comparemode+".xml");
		
//		if(isTrain)
//		{
//			sc = new ScapeTrain();
//			try {
//				sc.init(new File(cfile));
//			} catch (Exception ex) {
//				System.err.println("Marcalize could not be initialized");
//				System.exit(0);
//			}
//    		
//		}
//		else
//		{
//			url1 = displayoptions.getOption("url1").getValue();
//			url2 = displayoptions.getOption("url2").getValue();
			
//		}
        /* Validate program intrinsic input parameters and configuration */
        if (cmd.hasOption("get")) {
            target = cmd.getOptionValue("get");
        } else {
            if (this.config.getString("pagelyzer.run.default.parameter.get")==null) {
                usage(displayoptions);
                System.exit(0);
            } else {
                target = this.config.getString("pagelyzer.run.default.parameter.get");
            }
        }
        if (this.config.getString("selenium.run.mode").equals(LOCAL)) {
           System.out.println("Selenium: local WebDriver");
        } else {
           System.out.println("Selenium: remote " + this.config.getString("selenium.server.url"));
        }
        if (( this.config.getBoolean("pagelyzer.debug.screenshots.active")) && (this.config.getString("pagelyzer.debug.screenshots.path") == null)) {
            System.out.println("Debug was activated, but no path is specified to put the files. Use -debugpath path or change the configuration file");
            System.exit(0);
        }
        
        if (!cmd.hasOption("url")) {
            System.out.println("URL parameter missing");
            System.exit(0);
        } else url = cmd.getOptionValue("url");
    }
    
    public Capture GetCapture(String url1, String browser)
    {
    	 Capture capture = new Capture(this.config);
    	 capture.setup(browser);
    	 capture.run(url1, screenshot, segmentation); 
    	 return capture;
    }

    public CaptureResult getWithResult(String target, String url) {
         get(target,url);
         return(result);
        
    }
    
    /**
     * Method to call functionalities
     * @param target extra functionality. It can be: screenshot, segmentation, source
     * @param url the web page to process
     */
    public void get(String target, String url) {
        Capture capture = new Capture(config);
        capture.setup(this.config.getString("pagelyzer.run.default.parameter.browser"));
        switch(target) {
            case SCREENSHOT   : capture.run(url,true,false);break;
            case SEGMENTATION : capture.run(url,false,true);break;
            case SOURCE       : capture.run(url,false,false);break;
        }
        result = capture.result;

        OutputStream out=null;
        try {
            String ext="";
            
            switch(target) {
                case SCREENSHOT   :ext="png";break;
                case SEGMENTATION :ext="xml";break;
                case SOURCE       : ext="html";break;
            }
            out = new BufferedOutputStream(new FileOutputStream(outputfile.replace("#{ext}", ext)));
            switch(target) {
                case SCREENSHOT   : out.write(result.image);break;
                case SEGMENTATION : 
                    if (result.viXML!=null)
                        out.write(result.viXML.getBytes("UTF-8"));
                    if (result.wprima != null)
                        out.write(result.wprima.getBytes("UTF-8"));
                    if (result.record != null)
                        out.write(result.record.getBytes("UTF-8"));
                    break;
                case SOURCE       : out.write(result.srcHTML.getBytes("UTF-8"));break;
            }
            out.close();
            capture.cleanup();
         } catch (FileNotFoundException ex) {
             Logger.getLogger(JPagelyzer.class.getName()).log(Level.SEVERE, null, ex);
         } catch ( IOException | InterruptedException ex) {
             Logger.getLogger(JPagelyzer.class.getName()).log(Level.SEVERE, null, ex);
         }
    }
    
    /**
     * print the help usage of this application
    * @param options the command line arguments
    **/
    private static void usage(Options options){
    // Use the inbuilt formatter class
        HelpFormatter formatter = new HelpFormatter();
        formatter.printHelp( "Pagelyzer Help", options );
    }
    
    /**
    * @param args the command line arguments
     * @throws URISyntaxException 
    **/
    
    
    public static void main(String[] args) throws URISyntaxException {

        
        JPagelyzer pagelyzer = new JPagelyzer(args,false);
       // JPagelyzer pagelyzer = new JPagelyzer("http://www.lip6.fr","config.xml");
       
        /*
         * All is validated and fine, we can proceed to call functionalities
         */
        if (pagelyzer.getConfig() != null) {
            pagelyzer.get(pagelyzer.target,pagelyzer.url);
        } else {
            System.out.println("Configuration was not setup properly");
        }
       
        
    }
    
}
