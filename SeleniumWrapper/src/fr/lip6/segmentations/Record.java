package fr.lip6.segmentations;
public class Record {
    public String bid="";
    public double x=0;
    public double y=0;
    public double w=0;
    public double h=0;
    public double nx=0;
    public double ny=0;
    public double nw=0;
    public double nh=0;
    public String tcount="";
    public String ecount="";
    public int segmentation_id=0;
    private double docw=0;
    private double doch=0;
    public int importance=0;
    public Record(int segmentation_id,String line) {
        String[] arr = line.split(",");
        docw = Double.parseDouble(arr[4]);
        doch = Double.parseDouble(arr[5]);
        bid = arr[8];
        x = Double.parseDouble(arr[9]);
        y = Double.parseDouble(arr[10]);
        w = Double.parseDouble(arr[11]);
        h = Double.parseDouble(arr[12]);
        nx = 100*x/docw;
        ny=100*y/doch;
        nw=100*w/docw;
        nh=100*h/doch;
        ecount = arr[13];
        tcount = arr[14];
        this.segmentation_id=segmentation_id;
        this.importance = this.computeImportance();
    }
    public String sql() {
        
       
        return("insert into blocks(bid,x,y,w,h,segmentation_id,ecount,tcount,importance,nx,ny,nw,nh) values('"+bid+"','"+x+"','"+y+"','"+w+"','"+h+"','"+this.segmentation_id+"','"+ecount+"','"+tcount+"','"+importance+"','"+nx+"','"+ny+"','"+nw+"','"+nh+"')");
    }
    
    private int computeImportance() {
        int[][] im = new int[][] {
            {1, 2, 3, 3, 4, 4, 3, 3, 2, 1},
            {1, 1, 2, 3, 4, 4, 3, 2, 1, 1},
            {0, 1, 2, 2, 3, 3, 2, 2, 1, 0},
            {0, 1, 1, 1, 2, 2, 1, 1, 1, 0},
            {0, 1, 1, 1, 1, 1, 1, 1, 1, 0},
            {0, 1, 1, 1, 1, 1, 1, 1, 0, 0},
            {0, 0, 1, 1, 1, 1, 1, 1, 0, 0},
            {0, 0, 0, 1, 1, 1, 1, 0, 0, 0},
            {0, 0, 0, 0, 1, 1, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
     };
        int imp=0;
        int ix,iy,iw,ih;
        ix = (int) Math.round(nx/10);
        iy = (int) Math.round(ny/10);
        iw = (int) Math.round(nw/10);
        ih = (int) Math.round(nh/10);
        
        for (int i=ix;i<iw;i++) {
            for (int j=iy;j<ih;j++) {
                imp+=im[i][j];
            }
        }
        
        return(imp);
    }
}
