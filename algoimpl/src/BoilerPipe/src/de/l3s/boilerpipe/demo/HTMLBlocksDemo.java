/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package de.l3s.boilerpipe.demo;

import de.l3s.boilerpipe.BoilerpipeExtractor;
import de.l3s.boilerpipe.extractors.CommonExtractors;
import de.l3s.boilerpipe.sax.XpathExtractor;
import java.io.PrintWriter;
import java.net.URL;

/**
 *
 * @author sanojaa
 */

/**
 * Demonstrates how to use Boilerpipe to get the blocks
 * 
 * @author Christian Kohlschütter
 * @see Oneliner if you only need the plain text.
 */
public class HTMLBlocksDemo {
        public static String realURL = "";
        public static String category = "";
	public static void main(String[] args) throws Exception {
		URL url = new URL(args[0]);
                //url = new URL("http://www-poleia.lip6.fr/~sanojaa/bfdec.html");
               // url = new URL("http://www-poleia.lip6.fr/~sanojaa/dummy.html");
                
                //url = new URL("http://fr.wikipedia.com/wiki/France");
			//	"http://research.microsoft.com/en-us/um/people/ryenw/hcir2010/challenge.html"
//				"http://boilerpipe-web.appspot.com/"
                              
                        //"http://www.upmc.fr/"
                       // "http://fr.wikipedia.com/wiki/France"
                        // "http://fr.wikipedia.org/wiki/Salto_Angel"
		
		// choose from a set of useful BoilerpipeExtractors...
		
                final BoilerpipeExtractor extractor = CommonExtractors.ARTICLE_EXTRACTOR;
		//final BoilerpipeExtractor extractor = CommonExtractors.DEFAULT_EXTRACTOR;
		//final BoilerpipeExtractor extractor = CommonExtractors.CANOLA_EXTRACTOR;
		//final BoilerpipeExtractor extractor = CommonExtractors.LARGEST_CONTENT_EXTRACTOR;
//                final BoilerpipeExtractor extractor = CommonExtractors.KEEP_EVERYTHING_EXTRACTOR;

		// choose the operation mode (i.e., highlighting or extraction)
		final XpathExtractor hh = XpathExtractor.newXpathExtractorInstance();
		//final HTMLHighlighter hh = HTMLHighlighter.newExtractingInstance();
		
                String filename = args[1];//"/web/sanojaa/public_html/bf_blocks.js";
		PrintWriter out = new PrintWriter(filename, "UTF-8");
		out.println("var bfurl = \"" + url + "\";");
		out.println(hh.process(url, extractor));
		out.close();
                System.out.println("The result were saved to "+filename);
	}
}
