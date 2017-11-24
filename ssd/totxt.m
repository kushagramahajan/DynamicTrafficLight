%%my code starts here
load('cars2.mat')
names=[];
for j=1:length(cars)
    names=[names ;char(cars(j).imageFilename)];
end

namesonly=[];
for i=1:size(names,1)
    str=names(i,:);
    t=strsplit(str,'\');
    l=length(t);
    x=t(l);
    y=strsplit(char(x),'.');
    namesonly=[namesonly y(1)];
end

xmin=[];ymin=[];xmax=[];ymax=[];
for j=1:length(cars)
%for j=1:1

    %disp(positiveInstances(j).objectBoundingBoxes(1))
    xmin=cars(j).objectBoundingBoxes(:,1);
    ymin=cars(j).objectBoundingBoxes(:,2);
    xmax=cars(j).objectBoundingBoxes(:,1)+cars(j).objectBoundingBoxes(:,3);
    ymax=cars(j).objectBoundingBoxes(:,2)+cars(j).objectBoundingBoxes(:,4);
    fname=strcat('Labels/',namesonly(j),'.txt');
    fname=char( fname);
    fileID = fopen(fname,'w');
    for k=1:length(xmin)
        fprintf(fileID,'%d %d %d %d %d\n',7,xmin(k),ymin(k),xmax(k),ymax(k));
    end
    
end

%% my code ends here
