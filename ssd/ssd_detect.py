#### my code starts here

import numpy as np
import glob
import cv2
import matplotlib.pyplot as plt
plt.switch_backend('agg')
#get_ipython().magic(u'matplotlib inline')

plt.rcParams['figure.figsize'] = (10, 10)
plt.rcParams['image.interpolation'] = 'nearest'
plt.rcParams['image.cmap'] = 'gray'

# Make sure that caffe is on the python path:
caffe_root = '../'  # this file is expected to be in {caffe_root}/examples
import os
os.chdir(caffe_root)
import sys
sys.path.insert(0, 'python')

import caffe
caffe.set_device(0)
caffe.set_mode_gpu()


# * Load LabelMap.

# In[2]:

from google.protobuf import text_format
from caffe.proto import caffe_pb2

# load PASCAL VOC labels
labelmap_file = 'data/VOC0712/labelmap_voc.prototxt'
file = open(labelmap_file, 'r')
labelmap = caffe_pb2.LabelMap()
text_format.Merge(str(file.read()), labelmap)

def point_inside_polygon(x,y,poly):

    n = len(poly)
    inside =False

    p1x,p1y = poly[0]
    for i in range(n+1):
        p2x,p2y = poly[i % n]
        if y > min(p1y,p2y):
            if y <= max(p1y,p2y):
                if x <= max(p1x,p2x):
                    if p1y != p2y:
                        xinters = (y-p1y)*(p2x-p1x)/(p2y-p1y)+p1x
                    if p1x == p2x or x <= xinters:
                        inside = not inside
        p1x,p1y = p2x,p2y

    return inside

def get_labelname(labelmap, labels):
    num_labels = len(labelmap.item)
    labelnames = []
    if type(labels) is not list:
        labels = [labels]
    for label in labels:
        found = False
        for i in xrange(0, num_labels):
            if label == labelmap.item[i].label:
                found = True
                labelnames.append(labelmap.item[i].display_name)
                break
        assert found == True
    return labelnames


# * Load the net in the test phase for inference, and configure input preprocessing.

# In[3]:
model_def = 'models/VGGNet/VOC0712/SSD_300x300/deploy.prototxt'
model_weights = 'models/VGGNet/VOC0712/SSD_300x300/VGG_VOC0712_SSD_300x300_iter_120000.caffemodel'

net = caffe.Net(model_def,      # defines the structure of the model
                model_weights,  # contains the trained weights
                caffe.TEST)     # use test mode (e.g., don't perform dropout)

transformer = caffe.io.Transformer({'data': net.blobs['data'].data.shape})
transformer.set_transpose('data', (2, 0, 1))
transformer.set_mean('data', np.array([104,117,123])) # mean pixel
transformer.set_raw_scale('data', 255)  # the reference model operates on images in [0,255] range instead of [0,1]
transformer.set_channel_swap('data', (2,1,0))  # the reference model has channels in BGR order instead of RGB


image_resize = 300
net.blobs['data'].reshape(1,3,image_resize,image_resize)

poly=[(853,423),(534,478),(424,147)]

#im_file = os.path.join('/home/kushagra/ssd/caffe/examples','kushagra-images','test1')
fNum = 0
print(glob.glob("/home/kushagra/ssd/caffe/examples/kushagra-images/test4/*.jpg"))

#### my code ends here

for img_fn in glob.glob("/home/kushagra/ssd/caffe/data/vehicles/Images/*.jpg"):

    #image = cv2.imread(img_fn)
    image = caffe.io.load_image(img_fn)
    print(image.shape)
    #print image
    img_name = os.path.basename(img_fn)
    image_name = img_name[:-4]
    fNum += 1
    print fNum
    transformed_image = transformer.preprocess('data', image)
    net.blobs['data'].data[...] = transformed_image
    out = net.forward()
    detections = out['detection_out']
    #print detections
    # Parse the outputs.
    
    det_label = detections[0,0,:,1]
    det_conf = detections[0,0,:,2]
    det_xmin = detections[0,0,:,3]
    det_ymin = detections[0,0,:,4]
    det_xmax = detections[0,0,:,5]
    det_ymax = detections[0,0,:,6]
    # Get detections with confidence higher than 0.5.
    top_indices = [i for i, conf in enumerate(det_conf) if conf >= 0.15]
    top_conf = det_conf[top_indices]
    top_label_indices = det_label[top_indices].tolist()
    top_labels = get_labelname(labelmap, top_label_indices)
    top_xmin = det_xmin[top_indices]
    top_ymin = det_ymin[top_indices]
    top_xmax = det_xmax[top_indices]
    top_ymax = det_ymax[top_indices]
    #print top_xmin,top_ymin,top_xmax,top_ymax
    # * Plot the boxes
    # In[6]:
    colors = plt.cm.hsv(np.linspace(0, 1, 21)).tolist()
    #print colors
    plt.imshow(image)
    currentAxis = plt.gca()
    flag=0
    #print currentAxis
    for i in xrange(top_conf.shape[0]):
        xmin = int(round(top_xmin[i] * image.shape[1]))
        ymin = int(round(top_ymin[i] * image.shape[0]))
        xmax = int(round(top_xmax[i] * image.shape[1]))
        ymax = int(round(top_ymax[i] * image.shape[0]))
        #print xmin,ymin,xmax,ymax
        score = top_conf[i]
        #print score
        label = int(top_label_indices[i])
        label_name = top_labels[i]
        #print label_name
        display_txt = '%s: %.2f'%(label_name, score)
        #print display_txt
        coords = (xmin, ymin), xmax-xmin+1, ymax-ymin+1
	### my code starts here
	print(coords)        
	point1=(xmin,ymin)
	point2=(xmin,ymax)
	point3=(xmax,ymin)
	point4=(xmax,ymax)
	if(point_inside_polygon(point1[0],point1[1],poly)==True  or point_inside_polygon(point2[0],point2[1],poly)==True or point_inside_polygon(point3[0],point3[1],poly)==True or point_inside_polygon(point4[0],point4[1],poly)==True):
		pass
	else:
	    continue
	color = colors[label]
        currentAxis.add_patch(plt.Rectangle(*coords, fill=False, edgecolor=color, linewidth=2))
        currentAxis.text(xmin, ymin, display_txt, bbox={'facecolor':color, 'alpha':0.5})
    plt.axis('off')
    plt.tight_layout()
    plt.plot([853, 534, 424], [423, 478, 147])
    plt.draw()
    fig = plt.gcf()
    print("before save")
    fig.savefig("/home/kushagra/ssd/caffe/examples/kushagraoutputs/output_"+str(image_name))
    plt.close()

	### my code ends here


