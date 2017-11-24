%Function to detect,track and estimate the speed.


function letstrack(H,muponpix)
obj = setupSystemObjects();

tracks = initializeTracks(); 
nextId = 1; 

%Read frame by frame and process the frame
while ~isDone(obj.reader)
    
    
    frame = readFrame();
    centroids = [];
    [centroids, bboxes, mask] = detectObjects(frame);
    
    si = size(frame);
    predictNewLocationsOfTracks(si);
    [assignments, unassignedTracks, unassignedDetections] = ...
        detectionToTrackAssignment();

    updateAssignedTracks();
    updateUnassignedTracks();
    deleteLostTracks();
    createNewTracks();

    displayTrackingResults();
    
    
  
end




function obj = setupSystemObjects()
        
		%Video File Reader to read videos
        obj.reader = vision.VideoFileReader('CarsDrivingUnderBridge.mp4');

        
        %obj.maskPlayer = vision.VideoPlayer('Position', [740, 400, 700, 400]);
        obj.videoPlayer = vision.VideoPlayer('Position', [20, 400, 700, 400]);

        
        % of 1 corresponds to the foreground and the value of 0 corresponds
        % to the background.

        obj.detector = vision.ForegroundDetector('NumGaussians', 3, ...
            'NumTrainingFrames', 40, 'MinimumBackgroundRatio', 0.7);

        

        obj.blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
            'AreaOutputPort', true, 'CentroidOutputPort', true, ...
            'MinimumBlobArea', 400);
end



function tracks = initializeTracks()
        % create an empty array of tracks
        tracks = struct(...
            'id', {}, ...
            'bbox', {}, ...
            'kalmanFilter', {}, ...
            'age', {}, ...
            'totalVisibleCount', {}, ...
            'consecutiveInvisibleCount', {},...
            'speed',{});
end


function frame = readFrame()
        frame = obj.reader.step();
end


function [centroids, bboxes, mask] = detectObjects(frame)

        %{
        % Detect foreground.
        mask = obj.detector.step(frame);

        % Apply morphological operations to remove noise and fill in holes.
        mask = imopen(mask, strel('rectangle', [3,3]));
        mask = imclose(mask, strel('rectangle', [15, 15]));
        mask = imfill(mask, 'holes');

        % Perform blob analysis to find connected components.
        [~, centroids, bboxes] = obj.blobAnalyser.step(mask);
        
        disp(bboxes);
    
    %}
    
    % Detect foreground.
        mask = obj.detector.step(frame);

        % Apply morphological operations to remove noise and fill in holes.
        mask = imopen(mask, strel('rectangle', [3,3]));
        mask = imclose(mask, strel('rectangle', [15, 15]));
        mask = imfill(mask, 'holes');
    
    detector = vision.CascadeObjectDetector('cars.xml');
detector.ScaleFactor = 1.05;

bboxes1 = step(detector,frame);
[r c] = size(bboxes1);
%disp(bboxes);

bboxes = [];

centroids = [];

cou = 1;
for object = 1:r
   %disp(object);
   
   %Detect only the cars in the provided Lane
   
   p1 = [bboxes1(object,1) bboxes1(object,2);
       bboxes1(object,1) bboxes1(object,2)+bboxes1(object,4);
       bboxes1(object,1)+bboxes1(object,3) bboxes1(object,2)+bboxes1(object,4);
       bboxes1(object,1)+bboxes1(object,3) bboxes1(object,2)];
  
    position = [ 2.396811023622048e+02 4.047204724409450e+02; 
            1.160374015748032e+03 4.194606299212599e+02 ;
            9.063897637795278e+02 1.734133858267718e+02 ;
            4.505787401574804e+02 1.666102362204725e+02];
   in = inpolygon(p1(:,1),p1(:,2),position(:,1),position(:,2));
   
   
   %If Bounding Box lies in the provided isolated lane points, display only those
   if(max(in) == 1)
       xCentroid(cou) = bboxes1(object,1) + bboxes1(object,3)/2;
   
       yCentroid(cou) = bboxes1(object,2) + bboxes1(object,4)/2;
   
   
       centroids(cou,:) = [xCentroid(cou) yCentroid(cou)];
       
       bboxes = [bboxes; bboxes1(object,:)];
       
       cou = cou +1;
   end
   
   
   %bboxes = bboxes1
     
end

size(centroids)
   
%detectedImg = insertObjectAnnotation(img,'rectangle',bbox,'car');

%figure; imshow(detectedImg);
end


function predictNewLocationsOfTracks(si)
    
    
        for i = 1:length(tracks)
            bbox = tracks(i).bbox;

            % Predict the current location of the track.
            predictedCentroid = predict(tracks(i).kalmanFilter);
            apoint = predictedCentroid;
                        
            %disp(int32(predictedCentroid));
            %disp(size(predictedCentroid));
            
            %disp(bbox(3:4));
            
            predictedCentroid(1) = int32(predictedCentroid(1)) - bbox(3) / 2;
            predictedCentroid(2) = int32(predictedCentroid(2)) - bbox(4) / 2;
            
			%Speed Estimation
			
			%Estimate the position of centroid in the warped image then calculate the distance moved in a given frame 
			
            tracks(i).bbox = [predictedCentroid, bbox(3:4)];
            homcen1 = [predictedCentroid(1); predictedCentroid(2); 1];
            hompoint = [apoint(1); apoint(2); 1];
            
            
            warpedp1 = (H)*homcen1;
            warpedp2 = (H)*hompoint;
            
            warpedp1 = warpedp1/warpedp1(3);
            warpedp2 = warpedp2/warpedp2(3);
            
            
            
            tracks(i).speed = norm(warpedp1(2) - warpedp2(2))*(muponpix)*8*3.6;
            
        end
end



function [assignments, unassignedTracks, unassignedDetections] = ...
            detectionToTrackAssignment()

        nTracks = length(tracks);
        nDetections = size(centroids, 1);
        
        
        %disp(nTracks);
        %disp(nDetections)
        
        % Compute the cost of assigning each detection to each track.
        cost = zeros(nTracks, nDetections);
        for i = 1:nTracks
            cost(i, :) = distance(tracks(i).kalmanFilter, centroids);
        end

        % Solve the assignment problem.
        
            costOfNonAssignment = 20;
            [assignments, unassignedTracks, unassignedDetections] = ...
            assignDetectionsToTracks(cost, costOfNonAssignment);
       
        
       
end



function updateAssignedTracks()
        numAssignedTracks = size(assignments, 1);
        for i = 1:numAssignedTracks
            trackIdx = assignments(i, 1);
            detectionIdx = assignments(i, 2);
            centroid = centroids(detectionIdx, :);
            bbox = bboxes(detectionIdx, :);

            % Correct the estimate of the object's location
            % using the new detection.
            correct(tracks(trackIdx).kalmanFilter, centroid);

            % Replace predicted bounding box with detected
            % bounding box.
            tracks(trackIdx).bbox = bbox;

            % Update track's age.
            tracks(trackIdx).age = tracks(trackIdx).age + 1;

            % Update visibility.
            tracks(trackIdx).totalVisibleCount = ...
                tracks(trackIdx).totalVisibleCount + 1;
            tracks(trackIdx).consecutiveInvisibleCount = 0;
        end
end


function updateUnassignedTracks()
        for i = 1:length(unassignedTracks)
            ind = unassignedTracks(i);
            tracks(ind).age = tracks(ind).age + 1;
            tracks(ind).consecutiveInvisibleCount = ...
                tracks(ind).consecutiveInvisibleCount + 1;
        end
end



function deleteLostTracks()
        if isempty(tracks)
            return;
        end

        invisibleForTooLong = 20;
        ageThreshold = 8;

        % Compute the fraction of the track's age for which it was visible.
        ages = [tracks(:).age];
        totalVisibleCounts = [tracks(:).totalVisibleCount];
        visibility = totalVisibleCounts ./ ages;

        % Find the indices of 'lost' tracks.
        lostInds = (ages < ageThreshold & visibility < 0.6) | ...
            [tracks(:).consecutiveInvisibleCount] >= invisibleForTooLong;

        % Delete lost tracks.
        tracks = tracks(~lostInds);
end



function createNewTracks()
    
        %disp(unassignedDetections);
        
        centroids = centroids(unassignedDetections, :);
        bboxes = bboxes(unassignedDetections, :);
        
        for i = 1:size(centroids, 1)

            centroid = centroids(i,:);
            bbox = bboxes(i, :);

            % Create a Kalman filter object.
            kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
                centroid, [200, 50], [100, 25], 100);

            % Create a new track.
            newTrack = struct(...
                'id', nextId, ...
                'bbox', bbox, ...
                'kalmanFilter', kalmanFilter, ...
                'age', 1, ...
                'totalVisibleCount', 1, ...
                'consecutiveInvisibleCount', 0,...,
                'speed',{0});

            % Add it to the array of tracks.
            tracks(end + 1) = newTrack;

            % Increment the next id.
            nextId = nextId + 1;
        end
end




function displayTrackingResults()
        
		%Display the tracking result on frame 
        frame = im2uint8(frame);
        mask = uint8(repmat(mask, [1, 1, 3])) .* 255;

        minVisibleCount = 8;
        if ~isempty(tracks)

            
            reliableTrackInds = ...
                [tracks(:).totalVisibleCount] > minVisibleCount;
            reliableTracks = tracks(reliableTrackInds);

            
            if ~isempty(reliableTracks)
                % Get bounding boxes.
                bboxes = cat(1, reliableTracks.bbox);
                velocity = cat(1,reliableTracks.speed);
                % Get ids.
                ids = int32([reliableTracks(:).id]);

                
                labels = cellstr(int2str(velocity));
                predictedTrackInds = ...
                    [reliableTracks(:).consecutiveInvisibleCount] > 0;
                %isPredicted = cell(size(labels));
                %isPredicted(predictedTrackInds) = {''};
                isPredicted = cellstr(int2str(ids'));
                isPredicted = strcat(isPredicted, '-');
                labels = strcat(isPredicted, labels);

                bboxes
                % Draw the objects on the frame.
                frame = insertObjectAnnotation(frame, 'rectangle', ...
                    bboxes, labels);
                
                

                % Draw the objects on the mask.
                mask = insertObjectAnnotation(mask, 'rectangle', ...
                    bboxes, labels);
            end
        end
		%Isolate the lane
        position = [ 2.396811023622048e+02 4.047204724409450e+02 1.160374015748032e+03 4.194606299212599e+02 9.063897637795278e+02 1.734133858267718e+02 4.505787401574804e+02 1.666102362204725e+02];
        RGB = insertShape(frame, 'Polygon',position);

        % Display the mask and the frame.
        %obj.maskPlayer.step(mask);
        obj.videoPlayer.step(RGB);
end

end
