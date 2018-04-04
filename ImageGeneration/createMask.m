function [mask] = createMask(target)

mask = target(:,:,1) > 0.005; % color thresholding
mask = imfill(mask,'holes'); % fill the holes
mask = imgaussfilt(double(mask),15); % smooth the mask with gaussian filter.
end