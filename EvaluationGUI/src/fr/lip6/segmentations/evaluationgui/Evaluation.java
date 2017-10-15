/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package fr.lip6.segmentations.evaluationgui;

import edu.uci.ics.jung.algorithms.layout.CircleLayout;
import edu.uci.ics.jung.algorithms.layout.Layout;
import edu.uci.ics.jung.graph.Graph;
import edu.uci.ics.jung.graph.UndirectedSparseGraph;
import edu.uci.ics.jung.visualization.BasicVisualizationServer;
import edu.uci.ics.jung.visualization.decorators.ToStringLabeller;
import edu.uci.ics.jung.visualization.renderers.Renderer.VertexLabel.Position;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Paint;
import java.net.URL;
import java.util.Collection;
import javax.swing.JComponent;
import javax.swing.JPanel;
import org.apache.commons.collections15.Transformer;

/**
 *
 * @author asanoja
 */
public class Evaluation extends JPanel {

    private Configuration conf1;
    private Configuration conf2;
    private Parameters params;
    private Segmentation groundTruth;
    private Segmentation segmentation;
    private Graph<Block, Link> bcg = new UndirectedSparseGraph<Block, Link>();
    private Measure measure;

    public static final int EQUALS = 1;
    public static final int CONTAINED = 2;
    private URL url;

    public Evaluation(URL url,Configuration conf1,Configuration conf2, Parameters params) {
        this.params = params;
        this.conf1 = conf1;
        this.conf2 = conf2;
        this.url = url;

        setSize(500, 500);
        setPreferredSize(new Dimension(500, 500));

        this.groundTruth = new GroundTruthSegmentation(url,conf1);
        this.segmentation = new ProposedSegmentation(url,conf2);
    }

    public JComponent prepareEvaluation() {
        this.groundTruth.load();
        this.segmentation.load();
        prepareGraph();

        Layout<Block, Link> layout = new CircleLayout(this.bcg);
        //Layout<Block,Float> layout =new edu.uci.ics.jung.algorithms.layout.FRLayout2<Block,Float>(this.bcg);
        layout.setSize(new Dimension(550, 550));
        BasicVisualizationServer<Block, Link> vv = new BasicVisualizationServer<Block, Link>(layout);
        vv.setPreferredSize(new Dimension(550, 550));
        Transformer<Block, Paint> vertexPaint = new Transformer<Block, Paint>() {
            public Paint transform(Block b) {
                if (b instanceof GroundTruthBlock) {
                    return (Color.LIGHT_GRAY);
                } else {
                    return (Color.orange);
                }
            }
        };

        vv.getRenderContext().setVertexFillPaintTransformer(vertexPaint);
        vv.getRenderContext().setVertexLabelTransformer(new ToStringLabeller());
        vv.getRenderContext().setEdgeLabelTransformer(new ToStringLabeller());
        vv.getRenderer().getVertexLabelRenderer().setPosition(Position.CNTR);
        return (vv);
    }

    public void prepareGraph() {
        for (Block b : groundTruth.getBlocks()) {
            bcg.addVertex(b);
        }
        for (Block b : segmentation.getBlocks()) {
            bcg.addVertex(b);
        }

    }


    @Override
    public void paint(Graphics g) {
        g.drawString("URL:"+this.url.toString(), 10, 10);
        g.drawString("Tr:" + params.getTr()+",Tt:" + params.getTt(), 10, 21);
        g.drawString("Algo:" + conf2.getAlgo(), 10, 31);
        g.drawString(measure.toString(), 10, 42);
    }

    public void buildGraph() {
        Link link;
        for (Block gtb : groundTruth.getBlocks()) {
            for (Block pb : segmentation.getBlocks()) {
                if (gtb.equals(pb, params.getTt())){
                    link = new Link(gtb, pb);
//                    if (link.significative(params.getTr(), Evaluation.EQUALS)) {
                    if (true ) {
                        bcg.addEdge(link.fix(Evaluation.EQUALS), gtb, pb);
                        gtb.addMatch(pb);
                        pb.addMatch(gtb);
//                        System.out.println("LINK EQUAL " + gtb.getBid() + "," + pb.getBid());
                    } else {
//                        System.out.println("LINK NOT SIG " + gtb.getBid() + "," + pb.getBid());
                    }
                } else if (gtb.contains(pb, params.getTt())){
                    link = new Link(gtb, pb);
//                    if (link.significative(params.getTr(), Evaluation.CONTAINED)) {
                    if (true) {
                        bcg.addEdge(link.fix(Evaluation.CONTAINED), gtb, pb);
                        gtb.addMatch(pb);
                        pb.addMatch(gtb);
//                        System.out.println("LINK CONTAINED " + gtb.getBid() + "," + pb.getBid());
                    } else {
//                        System.out.println("LINK NOT SIG " + gtb.getBid() + "," + pb.getBid());
                    }
                } else if (pb.contains(gtb, params.getTt())) {
                    link = new Link(pb, gtb);
//                    if (link.significative(params.getTr(), Evaluation.CONTAINED)) {
                    if (true) {
                        bcg.addEdge(link.fix(Evaluation.CONTAINED), pb, gtb);
                        pb.addMatch(gtb);
                        gtb.addMatch(pb);
//                        System.out.println("LINK CONTAINED " + gtb.getBid() + "," + pb.getBid());
                    } else {
//                        System.out.println("LINK NOT SIG " + gtb.getBid() + "," + pb.getBid());
                    }
                } else {
//                    System.out.println("NOT RELATED " + gtb.getBid() + "," + pb.getBid());
                }
            }
        }
    }
    public void startEvaluation() {
        int tc = 0;
        int co = 0;
        int cu = 0;
        int cm = 0;
        int cf = 0;
        
        //evaluating from the ground truth perspective
        for (Block gtb : groundTruth.getBlocks()) {
            if (gtb.getMatch().size() == 0) {
                cm++;
            } else if (gtb.getMatch().size() == 1) {
                Block other = gtb.getMatch().get(0);
                if (other.getMatch().size() == 1) {
                    if ( gtb.getMatch().get(0) == other) {
                        tc++;
//                        System.out.println(gtb+","+other+", TC++");
                    } else {
                        if (new Link(gtb,other).compute(Evaluation.CONTAINED)>this.params.getTr()) {
                            tc++;
                        }
                    }
                    
                }
            } else if (gtb.getMatch().size() > 1){
                float max=0;
                int cont=0;
                for (Block stb : gtb.getMatch()) {
                    Link aux = new Link(gtb,stb);
                    float val = aux.compute(Evaluation.CONTAINED);
                    if (val>this.params.getTr()) {
                        max = val;
                        cont++;
                    }
                }
                if (max>params.getTr()) {
                    tc++;
                }
                co++;
            } else {
//                System.out.println("Erreur bizzarre");
            }
        }
        
//        System.out.println("Tc:"+tc+",Co:"+co+",Cm:"+cm);
        
       for (Block pb : segmentation.getBlocks()) {
            if (pb.getMatch().size() == 0) {
                cf++;
            } else if (pb.getMatch().size() == 1){
                //skip already counted
            } else if (pb.getMatch().size() > 1){
                cu++;
            } else {
//                System.out.println("Erreur bizzarre");
            }
        }
//         System.out.println("Tc:"+tc+",Cu:"+cu+",Cf:"+cf);
         measure = new Measure(url,tc,co,cu,cm,cf,groundTruth.getBlocks().size(),segmentation.getBlocks().size(),conf1,conf2,params);
         System.out.println(measure.toString());
         measure.sendTo("http://www-poleia.lip6.fr/~sanojaa/BOM/results.php");
    }

    /**
     * @return the m
     */
    public Measure getMeasure() {
        return this.measure;
    }
}
