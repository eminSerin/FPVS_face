faceData = [];
try
    for i = 1:5
        disp(['Trial: ', int2str(i)])
        faceData(:,i) = (imagePreload(inputDir,noiseDir,expInfo,lenNoise,color))';
    end
catch error
    sca;
    rethrow(error);
end

sca;
% subplot(2,1,1);
% hist(dataShapedNoPool);
% title('Image loading duration without preloaded noise images')
% xlabel('Seconds')
% subplot(2,1,2);
% hist(dataShapedPool);
% title('Image loading duration with preloaded noise images')
% xlabel('Seconds')