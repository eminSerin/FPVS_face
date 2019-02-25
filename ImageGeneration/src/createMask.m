function [mask] = createMask(target)
%   createMask generate HSV-based mask for background in a image. Gets the
%   image and threshold the saturation value of it with 0.005. That returns
%   image without a background. 
%
%   Input: 
%       target: Target image. 
%
%   Output:
%       mask: Mask generated for the target image.
%
%   Emin Serin - Berlin School of Mind and Brain
%
%% Script
mask = target(:,:,1) > 0.005; % color thresholding
mask = imfill(mask,'holes'); % fill the holes
mask = imgaussfilt(double(mask),15); % smooth the mask with gaussian filter.
end
