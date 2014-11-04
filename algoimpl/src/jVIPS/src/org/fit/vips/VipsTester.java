/*
 * Tomas Popela, 2012
 * VIPS - Visual Internet Page Segmentation
 * Module - VipsTester.java
 */

package org.fit.vips;

/**
 * VIPS API example application.
 * @author Tomas Popela
 *
 */
public class VipsTester {
        public static String Salida="";
	/**
	 * Main function
	 * @param args Internet address of web page.
	 */
	public static void main(String args[])
	{
		// we've just one argument - web address of page
		if (args.length != 2)
		{
			System.err.println("We've just only two argument - web address of page and category!");
			System.exit(0);
		}

		String url = args[0];
                Vips.category = args[1];
		try
		{
			Vips vips = new Vips();
                        
			// disable graphics output
			vips.enableGraphicsOutput(true);
			// disable output to separate folder (no necessary, it's default value is false)
			vips.enableOutputToFolder(false);
			// set permitted degree of coherence
			vips.setPredefinedDoC(5);
			// start segmentation on page
			vips.startSegmentation(url);
		} catch (Exception e)
		{
			e.printStackTrace();
		}
	}
}
