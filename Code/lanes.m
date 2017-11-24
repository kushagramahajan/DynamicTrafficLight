close all
img = imread('IMG_00002.jpg');
img_gray = rgb2gray(img);
img_double = double(img_gray);
%Question 2 part a) Lane Highlighting
% figure
% I = conv2(imsharpen(img_double),fspecial('log',[5 5],2.1));
% imshow(I)
% % Question 2 part b) Canny Edge 
edges = edge(img_double,'canny',[0.026 0.37],1.25);
% figure
% imshow(edges)

% Question 2 part c) Hough Lines
start_angle = -60;
end_angle = 60;
theta_resolution = 0.3;
[accum theta rho] = hough(edges,'RhoResolution',1.5, 'Theta', start_angle:theta_resolution:end_angle);
figure, imagesc(accum,'XData',theta,'YData',rho),title('Hough Accumulator');
peaks = houghpeaks(accum,13,'Threshold',ceil(0.4*max(accum(:))),'NHoodSize',[31 13]);
hold on;plot(theta(peaks(:,2)),rho(peaks(:,1)),'rs');hold off
line_segs = houghlines(edges,theta,rho,peaks,'MinLength',180);
figure,imshow(img),title('Lanes');
hold on;
 x1 = [833 1361];
y1 = [289 629];
x2 = [740 840];
y2 = [380 677];
p1 = polyfit(x1,y1,1);
p2 = polyfit(x2,y2,1);
%calculate intersection
x_intersect = fzero(@(x) polyval(p1-p2,x),3);
y_intersect = polyval(p1,x_intersect);
for i = [1 4]
    endpoints = [line_segs(i).point2;x_intersect,y_intersect];
    plot(endpoints(:,1),endpoints(:,2),'LineWidth',2,'Color','green');
    pause(1)
end

hold off;