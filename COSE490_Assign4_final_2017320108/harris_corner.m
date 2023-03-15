%
% Skeleton code for COSE490 Fall 2022 Assignment 4
%
% Won-Ki Jeong (wkjeong@korea.ac.kr)
%

clear all;
close all;

%
% Loading input image
%
I=imread('building-600by600.tif');
%I=imread('checkerboard-noisy2.tif');
%I=imread('ArseneWenger.png');
Img=double(I(:,:,1));

%
% ToDo: Compute R
%

% Compute gradients
[Ix Iy] = gradient(Img);
% Apply Gaussian smoothing
sigma = 2;
IxIx = imgaussfilt(Ix.*Ix, sigma);
IxIy = imgaussfilt(Ix.*Iy, sigma);
IyIy = imgaussfilt(Iy.*Iy, sigma);
% input image size: height and width
[img_h, img_w] = size(Img);
% build matrix R with k value
R = zeros(size(Img));
k = 0.05;

% Compute Harris matrix H and corner response function R
for i=1:img_h
    for j=1:img_w
        H = [IxIx(i,j) IxIy(i,j); IxIy(i,j) IyIy(i,j)];
        valueR = det(H) - (k*((trace(H)).^2));
        R(i,j) = valueR;
    end
end

%
% Example of collecting points and plot them
%
% (10,1), (15,2), (20,3)
%
%{
location = [10 15 20; 1 2 3]'
points = cornerPoints(location)
plot(points)
%}

%
% ToDo: Visualize R values using jet colormap
%

% normalize values into [0, 255] for indexing
minval = min(R, [], 'all');
indexR = R - minval;
maxval = max(indexR, [], 'all');
indexR = indexR./maxval;
indexR = indexR.*255;
indexR = round(indexR);

% with preprocessed values, build jet colormap
visualR = ind2rgb(indexR, colormap(jet));
imshow(visualR);
caxis([min(R, [], 'all') max(R, [], 'all')]);
colorbar;
title("Visualize R with Jet Colormap");

%
% ToDo: Threshold R & Collect Local Maximum Points
%

% Set threshold value
threshold = max(R, [], 'all')/10;
% local max points set : initial with (1,1) to avoid empty set during concat
locSet = [1 1];
for i=1:img_h
    for j=1:img_w
        if R(i,j) > threshold
            temp = [j i];
            locSet = cat(1, locSet, temp);
        end
    end
end
% check initial (1,1) meets threshold : if not, drop it
if R(1, 1) <= threshold
    locSet = locSet(2:end, :);
end
% Finally, collect corner points
points = cornerPoints(locSet);


%
% Visualize corner points over the input image
%

figure, imshow(I)

hold on

plot(points)

hold off
