%
% Skeleton code for COSE490 Fall 2022 Assignment 3
%
% Won-Ki Jeong (wkjeong@korea.ac.kr)
%

clear all;
close all;

%
% Loading input image
%
Img=imread('coins-small.bmp');
Img=double(Img(:,:,1));

%
% Parameter setting - modify as you wish
%
dt = 0.8;  % time step
c = 1.0;  % weight for expanding term
niter = 400; % max # of iterations


%
% Initializing distance field phi
%
% Inner region : -2, Outer region : +2, Contour : 0
%
[numRows,numCols] = size(Img);
phi=2*ones(size(Img));
phi(10:numRows-10, 10:numCols-10)=-2;

%
% Compute g (edge indicator, computed only once)
%

% ToDO ------------------------

% using gaussian smoothing
% p norm as L-2 norm (square)

% <1> gaussian smoothing
% in matlab function imgaussfilt, we can moderate sigma value
sigma = 2;
img_smoothed = imgaussfilt(Img, sigma);

% <2> get g from smoothed image
[img_dx, img_dy] = gradient(img_smoothed);
grad_ihat = sqrt(img_dx.^2 + img_dy.^2);

g = 1 ./ (1 + grad_ihat.^2);


% -----------------------------

%
% Level set iteration
%
for n=1:niter
    
    %
    % Level set update function
    %
    phi = levelset_update(phi, g, c, dt);    

    %
    % Display current level set once every k iterations
	%
	% Modify k to adjust the refresh rate of the viewer
    %
    k = 10;
    if mod(n,k)==0
        figure(1);
        imagesc(Img,[0, 255]); axis off; axis equal; colormap(gray); hold on; contour(phi, [0,0], 'r');
        str=['Iteration : ', num2str(n)];
        title(str);
        
    end
end


%
% Output result
%
figure(1);
imagesc(Img,[0, 255]); axis off; axis equal; colormap(gray); hold on;  contour(phi, [0,0], 'r');
str=['Final level set after ', num2str(niter), ' iterations'];
title(str);



