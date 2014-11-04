package de.l3s.boilerpipe.sax;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;
import java.io.Writer;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;
import java.util.Stack;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import org.cyberneko.html.parsers.DOMParser;
import org.dom4j.Attribute;
import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.Node;
import org.dom4j.dom.DOMElement;
import org.dom4j.dom.DOMNodeHelper;
import org.dom4j.io.DOMReader;
import org.w3c.dom.Attr;
import org.w3c.dom.NodeList;

import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 * An {@link InputSourceable} for {@link HTMLFetcher}.
 * 
 * @author Christian Kohlschütter
 */
public class HTMLDocument implements InputSourceable {
	private final Charset charset;
	private byte[] data;
//        private org.w3c.dom.Document dom=null;
        private org.dom4j.Document dom=null;
       

	public HTMLDocument(final byte[] data, final Charset charset) {
		this.data = data;
		this.charset = charset;
                //setDOM();
	}
	
	public HTMLDocument(final String data) {
		Charset cs = Charset.forName("utf-8");
		this.data = data.getBytes(cs);
		this.charset = cs;
                //setDOM();
	}
	
        private void setDOM() {
            try {
                DOMParser parser = new DOMParser();
                DOMReader reader = new DOMReader();
                Element element = null;
                InputSource isrc = null;
                String xpath = "";
                isrc = new InputSource(new ByteArrayInputStream(this.data));
                        
                parser.parse(isrc);
                this.dom = reader.read(parser.getDocument());
                List<Node> list = this.dom.selectNodes("//*");
                for (Node item : list) {
                    element = (Element) item;
                    xpath  = getXPath(item);
                    System.out.println(xpath);
                    element.addAttribute("xpath", xpath);
                }
                
                this.data = this.dom.asXML().getBytes();
                
            } catch ( SAXException | IOException ex) {
                Logger.getLogger(HTMLDocument.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        
	public Charset getCharset() {
		return charset;
	}
	
	public byte[] getData() {
		return data;
	}
	
	public InputSource toInputSource() {
		final InputSource is = new InputSource(new ByteArrayInputStream(data));
		is.setEncoding(charset.name());
		return is;
	}
        
        
 public  String getXPath(Node n) {
      // abort early
      if (null == n) return null;
//      if (n.getName()=="DIV")
//          System.out.println("debug");
      // declarations
      Node parent = null;
      Stack hierarchy = new Stack();
      StringBuffer buffer = new StringBuffer();

      // push element on stack
      hierarchy.push(n);

      parent = n.getParent();
      while (null != parent && parent.getNodeType() != Node.DOCUMENT_NODE) {
         // push on stack
         hierarchy.push(parent);

         // get parent of parent
         parent = parent.getParent();
      }

      // construct xpath
      Object obj = null;
      while (!hierarchy.isEmpty() && null != (obj = hierarchy.pop())) {
         Node node = (Node) obj;
         boolean handled = false;

         // only consider elements
         if (node.getNodeType() == Node.ELEMENT_NODE) {
            Element e = (Element) node;

            // is this the root element?
            if (buffer.length() == 0) {
               // root element - simply append element name
               //buffer.append(DOMNodeHelper.getLocalName(node));
                buffer.append("/");
                buffer.append(node.getName());
            } else {
               // child element - append slash and element name
               buffer.append("/");
               //buffer.append(DOMNodeHelper.getLocalName(node));
               buffer.append(node.getName());
               
               
//               if (hasAttributes(node)) {
//                  // see if the element has a name or id attribute
//                  if (e.attribute("id")!=null) {
//                     // id attribute found - use that
//                     buffer.append("[@id='" + e.attribute("id").getValue() + "']");
//                     handled = true;
//                  } else if (e.attribute("name")!=null) {
//                     // name attribute found - use that
//                     buffer.append("[@name='" + e.attribute("name").getValue() + "']");
//                     handled = true;
//                  }
//               }

               if (!handled) {
                  // no known attribute we could use - get sibling index
                  int prev_siblings = 1;
                  Node prev_sibling=null;
                  prev_sibling = (Node) getPreviousSibling(node);
                  while (null != prev_sibling) {
                     if (prev_sibling.getNodeType() == node.getNodeType()) {
                        if (prev_sibling.getName().equalsIgnoreCase(node.getName())) {
                           prev_siblings++;
                        }
                     }
                     prev_sibling = (Node) getPreviousSibling(prev_sibling);
                  }
                  if (prev_siblings>1)
                    buffer.append("[" + prev_siblings + "]");
               }
            }
         }
      }

      // return buffer
      return buffer.toString();
   }
    
 
 public static Node getPreviousSibling(Node node) {
          Element parent = node.getParent();
  
          if (parent != null) {
              int index = parent.indexOf(node);
  
              if (index > 0) {
                  Node previous = parent.node(index - 1);
  
                  return previous;
              }
          }
  
          return null;
      }
 public static boolean hasAttributes(Node node) {
         if ((node != null) && node instanceof Element) {
             return ((Element) node).attributeCount() > 0;
         } else {
             return false;
         }
     }
// public static Node asDOMNode(Node node) {
//         if (node == null) {
//             return null;
//         }
// 
//         if (node instanceof org.w3c.dom.Node) {
//             return (org.w3c.dom.Node) node;
//         } else {
//             // Use DOMWriter?
//             System.out.println("Cannot convert: " + node
//                     + " into a W3C DOM Node");
//             //notSupported();
// 
//             return null;
//         }
//     }
}
