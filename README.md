# Dynamic Traffic Light System

Sample code for work done as part of final course project of Computer Vision by -

1. Kushagra Mahajan (kushagra14055@iiitd.ac.in)
2. Rohan Tiwari (rohan14157@iiitd.ac.in)
3. Sakti Saurav (sakti14093@iiitd.ac.in)


### Code Structure

* The folder `ssd` contains the code for running the Single Shot Detector for vehicle detection to calculate the density of vehicles.
* The `Code` folder contains the code for lane detection, affine and metric rectification, tracking, and speed estimation.
* `datasets.txt` file contains the links to the datasets used for our experiments and the Google Drive link for the annotated data.
* `references.txt` contains the list of references for this work.


### Running the Deep Models

The repository has been cloned from the Single Shot Detector repository for caffe on github. The link for the repository is: [https://github.com/weiliu89/caffe/tree/ssd](https://github.com/weiliu89/caffe/tree/ssd). Most of the code for fine-tuning and running the network is available on the the official link given. The repository has a pre-trained model on the Pascal VOC 2007 dataset, which is used for fine-tuning. Matlab Computer Vision Toolbox has been used for creating bounding box annotations as part of dataset creation.

The `ssd/totxt.m` file has been used to convert the .mat file with the bounding box annotations for the dataset to the format for creating lmdb training and testing files for fine-tuning. The fine-tuning is done using the `ssd/ssd_pascal.py` file.

Thus, using SSD model we are able to model the problem of vehicle detection highly efficiently.


### Running HoG Model

* Import `Bridge.mat`
* Run `Code/letstrack.m` using `H` and `muponpix` as arguments
* Run `Code/rectification.m` for rectifying the lanes. Specify the images in the code before running the code. For affine rectification, select 2 sets of parallel lines and for metric rectification, select a pair of perpendicular lines. Use the homography calculated and stored in the variable `H` for `letstrack.m` file. Also select the points on the lane between which you want the speed to be calculated and specify them in the `letstrack.m` file.
