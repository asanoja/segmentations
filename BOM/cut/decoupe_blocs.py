from PIL import Image, ImageOps
import Image
import ImageDraw
import math
import glob
import random
import sys
import os
#import xml.dom.minidom 
from xml.dom import minidom

repertory = "npr"

if not os.path.exists(repertory):
    os.makedirs(repertory)

xml_file = "firefox_www_npr_org_.xml"
png_file = "firefox_www_npr_org_.png"

dom1 = minidom.parse(xml_file)

im1 = Image.open(png_file)
#im2 = im1.crop((0, 0, 200, 100))
#im2.save("%s/test.png" % (repertory))

(w, h) = im1.size

for element in dom1.getElementsByTagName("Block"):
    l = []
    for e in element.getAttribute("Pos").strip().split(" "):
        l.append(int(e.split(":")[1]))
    print element.getAttribute("Pos")
    #im1 = Image.open(png_file)
    print (element.getAttribute("Ref"), l, w, h, l[0], l[1], l[0] + l[2], l[1] + l[3])
    im2 = im1.crop((l[0], l[1], l[0] + max(1,l[2]), l[1] + max(1,l[3])))
    im2.save("%s/%s.png" % (repertory, element.getAttribute("Ref")))
    
