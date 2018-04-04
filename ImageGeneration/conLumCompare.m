figure('Name','Gray Images'); 
allPics = dir([pwd filesep '*.jpeg']);
noisePics = dir([pwd filesep '*.jpg']);
for n = 1: length(allPics)
    grayImage = imread(allPics(n).name);
    noiseImage = imread(noisePics(n).name);
    cCont = mean2(max(grayImage) - min(grayImage));
    cContNoise = mean2(max(noiseImage) - min(noiseImage));
    contSent = ['Contrast for image ', allPics(n).name ': ' , num2str(cCont)];
    contSentNoise = ['Contrast for noise image: ' , num2str(cContNoise)];
    disp(contSent)
    disp(contSentNoise)
%     subplot(2,5,n)
%     imshow(grayImage);
%     title(contSent)
end