im1 = imread('floor.jpg');
imshow(im1);

%Select Points
[ptsx ptsy] = getpts;

%Retrieve Points
p1 = [ptsx(1) ptsy(1) 1];     
p2 = [ptsx(2) ptsy(2) 1];
p3 = [ptsx(3) ptsy(3) 1];
p4 = [ptsx(4) ptsy(4) 1];

%make lines
l1 = cross(p1,p2);
l2 = cross(p3,p4);

m1 = cross(p1,p4);
m2 = cross(p3,p2);

%Find the vanishing points
vp1 = cross(l1,l2);
vp2 = cross(m1,m2);

%Find the vanishing line
vl = cross(vp1,vp2);

vline = vl/vl(3);

%Create the Projective Transformation
H1 = [1 0 0;
    0 1 0;
    vline(1) vline(2) 1];

tform = projective2d(H1');

%warp the image using Homography
newIma =imwarp(rgb2gray(im1),tform);
%rgbImage = rgb2gray(im1);
%sze = size(rgbImage);
%newIma = imTransD(im1, H1, sze, 'lh');


imshow(newIma);

%Select Points for metric
[pts2x pts2y] = getpts;


p1n = [pts2x(1) pts2y(1) 1];
p2n = [pts2x(2) pts2y(2) 1];
p3n = [pts2x(3) pts2y(3) 1];
p4n = [pts2x(4) pts2y(4) 1];

%make lines from the points selected
ol1 = cross(p1n,p2n);
ol1 = ol1/ol1(3);
ol2 = cross(p2n,p3n);
ol2 = ol2/ol2(3);
ol3 = cross(p1n,p3n);
ol3 = ol3/ol3(3);
ol4 = cross(p2n,p4n);
ol4 = ol4/ol4(3);


%s = [s1 ; s2];

%Create Matrix A
A = [ol1(1)*ol2(1) ol1(1)*ol2(2)+ol1(2)*ol2(1);
    ol3(1)*ol4(1) ol3(1)*ol4(2)+ol3(2)*ol4(1)];


b = [-1*ol1(2)*ol2(2);
    -1*ol3(2)*ol4(2)];

%Solve As = b
s = A\b;

%Create matrix S symmetric
S = [s(1) s(2); s(2) 1];

%SVD decompose S matrix
[U,D,V] = svd(S);
%Find A
AffA = U*sqrt(D)*U';


%Affine transformation matrix
H2 = [AffA(1,1) AffA(1,2) 0;
    AffA(2,1) AffA(2,2) 0;
    0 0 1];

%sze = [500 500];
%newImaRectified = imTransD(newIma, H2, sze, 'lh');

tform = projective2d(inv(H2));
newImaRectified =imwarp(newIma,tform);


imshow(newImaRectified);


