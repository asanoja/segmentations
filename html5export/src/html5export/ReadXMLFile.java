package html5export;
 
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;
import org.w3c.dom.Node;
import org.w3c.dom.Element;
import java.io.File;
import java.util.HashMap;
import java.util.Map;
 
public class ReadXMLFile {
 
  public static void main(String argv[]) {
  }
 public Map<String, String> getMap() {
     Map<String,String> map = new HashMap<String,String>();
    try {
 
	File fXmlFile = new File("/home/asanoja/Documentos/00_Tesis/work/dataset/dataset/sc.xml");
	DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
	DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
	Document doc = dBuilder.parse(fXmlFile);
        
 
	//optional, but recommended
	//read this - http://stackoverflow.com/questions/13786607/normalization-in-dom-parsing-with-java-how-does-it-work
	doc.getDocumentElement().normalize();
 
	System.out.println("Root element :" + doc.getDocumentElement().getNodeName());
 
	NodeList nList = doc.getElementsByTagName("page");
 
	System.out.println("----------------------------");
 
	for (int temp = 0; temp < nList.getLength(); temp++) {
 
		Node nNode = nList.item(temp);
 
		System.out.println("\nCurrent Element :" + nNode.getNodeName());
 
		if (nNode.getNodeType() == Node.ELEMENT_NODE) {
 
			Element eElement = (Element) nNode;
                        String id = eElement.getAttribute("id");
                        String url = eElement.getAttribute("url");
                        map.put(id, url);
			System.out.println("id : " + id);
			System.out.println("url : " + url);
			
			
 
		}
	}
    } catch (Exception e) {
	e.printStackTrace();
    }


    
      return map;
        
    }
 
}