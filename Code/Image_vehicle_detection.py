import cv2
from nms import nms
print(cv2.__version__)

cascade_src = 'cars.xml'

car_cascade = cv2.CascadeClassifier(cascade_src)

img = cv2.imread("dataset/2.jpg")
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
gray = cv2.resize(gray,(0,0),fx = 0.7,fy = 0.7)

clone = gray

cars = car_cascade.detectMultiScale(gray, 1.01, 0)
#for (x,y,w,h) in cars:
#    cv2.rectangle(gray,(x,y),(x+w,y+h),(0,0,255),2)      
    
#cv2.imshow('video', gray)

#print ("Detections before NMS = {}".format(cars))


cars1 = nms(cars,0.01)

    # Display the results after performing NMS
for (x_tl, y_tl, w, h) in cars1:
        # Draw the detections
    cv2.rectangle(clone, (x_tl, y_tl), (x_tl+w,y_tl+h), (0, 0, 0), thickness=2)

#print ("Detections after NMS = {}".format(cars1))

cv2.imshow("Final Detections after applying NMS", clone)

cv2.waitKey()
