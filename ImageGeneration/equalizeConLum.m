function [] = equalizeConLum(subID,varargin)
%   EQUALIZECONLUM
%   This function equalizes contrast and luminance of image couples. Couple
%   images are first averaged and the histogram of each image is matched
%   with histogram of averaged image using imhistmatch function. 
%   
%   Usage: 
%   equalizeConLum(2); % equalizes images with original luminance.
%   
%   equalizeConLum(2,0.9); % equalizes images and decreases luminance by
%   10%. 
%
%   Output image will be saved in new directory called equalizedImages.
%   
%   Author: Emin Serin (emin.serin@hu-berlin.de)
%   
%% Input
if length(varargin) > 1
    % raise an error if more than 3 parameters given.
    error(['requires at most 1 arguements.',' e.g. equalizeConLum(10,.9)'])
end
optargs = {1}; % default parameters.
optargs(1:length(varargin)) = varargin; % overwrite parameters if given. 

lum = optargs{1};

% Input and output directory. 
subID = num2str(subID);
imgPath  = [pwd,filesep,'raw_images', filesep, subID, filesep];
outputPath = [pwd,filesep, 'equalizedImages',filesep, subID,filesep];

% Check directory if outputpath exists.
if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end

% Load images.
allPics = dir([imgPath, '*jpg']); % all pictures.
for n = 1: length(allPics)
    imValues(n).imName = allPics(n).name;
    rgbImages(:,:,:,n) = imread(allPics(n).name)*lum;
end

%% Process
% Average images.
for n = 1 : 3
    % Take average of nth and n+3th image. 
    sumImageRGB(:,:,:,n) = im2double(rgbImages(:,:,:,n)) + im2double(rgbImages(:,:,:,n+3));
    aveImageRGB(:,:,:,n) = sumImageRGB(:,:,:,n)./2 ;
end

%% Output and plotting.
% show RGB images
figure('Name','RGB Images'); 
for n = 1: length(allPics)
    cCont = mean2(max(rgbImages(:,:,:,n)) - min(rgbImages(:,:,:,n)));
    imValues(n).preCont = cCont;
    contSent = ['Contrast: ', num2str(cCont)];
    R=rgbImages(:,:,1,n) ; G=rgbImages(:,:,2,n) ; B=rgbImages(:,:,3,n) ;
    cLum = mean2(0.299 * R + 0.587 * G + 0.114 * B);
    imValues(n).preLum = cLum;
    lumSent = ['Luminance: ', num2str(cLum)];
    subplot(2,3,n)
    imshow(rgbImages(:,:,:,n));
    title({lumSent;contSent})
end

% show averaged RGB images
figure('Name','Equalized RGB Images');
n = 1;
for picType = 1 : 2
    for l = 1: 3
        equalizedIm(:,:,:,n) = imhistmatch(rgbImages(:,:,:,n),aveImageRGB(:,:,:,l));
        R=equalizedIm(:,:,1,n) ; G=equalizedIm(:,:,2,n) ; B=equalizedIm(:,:,3,n) ;
        cCont = mean2(max(equalizedIm(:,:,:,n)) - min(equalizedIm(:,:,:,n)));
        imValues(n).postCont = cCont;
        cLum = mean2(0.299 * R + 0.587 * G + 0.114 * B);
        imValues(n).postLum = cLum;
        lumSent = ['Luminance: ', num2str(cLum)];
        contSent = ['Contrast: ', num2str(cCont)];
        subplot(2,3,n)
        imshow(equalizedIm(:,:,:,n));
        title({lumSent,contSent})
        n = n + 1;
    end
end

% save images. 
for p = 1 : length(allPics)
    imgDir = [outputPath,allPics(p).name];
    imwrite(equalizedIm(:,:,:,p),imgDir,'jpg','Quality',100)
end
save([outputPath, subID, '.mat'],'imValues');

end
