For running the deep models

The repository has been cloned from the Single Shot Detector repository for caffe on github. The link for the repository is : https://github.com/weiliu89/caffe/tree/ssd. Much of the entire code for for fine-tuning and running the network is available on the the official link given. The repository has a pre-trained-model that has been trained on the Pascal VO 2007 dataset. That model is used for fine-tuning. Matlab Computer Vision Toolbox has been used for creating bounding box annotations as part of dataset creation.
The totxt.m file has been used to convert the .mat file with the bounding box annotations on that  dataset to the format for creating lmdb training and testing files for fine-tuning. The fine-tuning is done using the ssd_pascal-kushagra.py file. 
Thus, using SSD model we are able to model the problem of car detection highly efficiently.


For running HoG

Import Bridge.mat
Run letstrack.m using H and muponpix as arguments
Run metricrectification.m for rectifying the lanes.Specify the images in the code before running the code.For the affine rectification part select 2 set of parallel lines and for the metric rectification select a pair of perpendicular line.Use the homography calculated in the and stored in the variable H for the letstrack.m file. Also select the points on the lane between which you want the speed to be calculated and specify them in the letstrack.m file.
