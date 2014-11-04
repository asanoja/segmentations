/**
 * boilerpipe
 *
 * Copyright (c) 2009 Christian Kohlschütter
 *
 * The author licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package de.l3s.boilerpipe.sax;

import java.io.IOException;

import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import de.l3s.boilerpipe.BoilerpipeInput;
import de.l3s.boilerpipe.BoilerpipeProcessingException;
import de.l3s.boilerpipe.document.TextDocument;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Parses an {@link InputSource} using SAX and returns a {@link TextDocument}.
 * 
 * @author Christian Kohlschütter
 */
public final class BoilerpipeSAXInput implements BoilerpipeInput {
    private final InputSource is;

    /**
     * Creates a new instance of {@link BoilerpipeSAXInput} for the given {@link InputSource}.
     *
     * @param is
     * @throws SAXException
     */
    public BoilerpipeSAXInput(final InputSource is) throws SAXException {
        this.is = is;
    }

    /**
     * Retrieves the {@link TextDocument} using a default HTML parser.
     */
    public TextDocument getTextDocument() throws BoilerpipeProcessingException {
        return getTextDocument(new BoilerpipeHTMLParser());
    }
    
    /**
     * Retrieves the {@link TextDocument} using the given HTML parser.
     * 
     * @param parser The parser used to transform the input into boilerpipe's internal representation.
     * @return The retrieved {@link TextDocument}
     * @throws BoilerpipeProcessingException
     */
    public TextDocument getTextDocument(final BoilerpipeHTMLParser parser) throws BoilerpipeProcessingException {
        try {
            //parser.setIncludeExternalDTDDeclarations(false);
            //parser.setIncludeInternalDTDDeclarations(false);
            //parser.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false);
            //parser.read(is) ; 
            parser.parse(is);
//        } catch (IOException e) {
//            throw new BoilerpipeProcessingException(e);
        } catch (SAXException ex) {
            Logger.getLogger(BoilerpipeSAXInput.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(BoilerpipeSAXInput.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        return parser.toTextDocument();
    }

}
