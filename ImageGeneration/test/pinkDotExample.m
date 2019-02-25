function [] = pinkDotExample(subID)
%   pinkDotExample simulates possible pink dot location on the image of
%   given subject. The images of the given subject must be 'images' folder.
%   
%
%   Emin Serin - Berlin School of Mind and Brain
%
%% Import files
Imgpath  = [pwd, filesep, 'images', filesep,num2str(subID), filesep];
allPics = dir([Imgpath, '*jpg']); % all pictures.

% Load images
for n = 1: length(allPics)
    rgbImages(:,:,:,n) = imread(allPics(n).name);
    grayImages(:,:,n) = rgb2gray(rgbImages(:,:,:,n));
end

%% Show images.
% show RGB images

% figure('Name','RGB Images');
% for n = 1: length(allPics)
%     subplot(2,3,n)
%     imshow(grayImages(:,:,n));
%     imellipse(gca,[134 173 135 209]);
% end

%% Display using Psychtoolbox.

try
    screen = max(Screen('Screens'));
    Screen('Preference', 'SkipSyncTests', 0);
    mainwin = Screen('OpenWindow',screen);
    pos.res = Screen('Resolution',mainwin); % screen resolution
    pos.height = 567; % stimulus height
    pos.width = 400; % stimulus width
    pos.mask = [134 173 135 180];
    
    image = [];
    for i = 1:length(allPics)
        image(i) = Screen('MakeTexture',mainwin,grayImages(:,:,i));
    end
    
    for im = 1 : length(allPics)
        for i = 1:300
            randXY = [(rand()*pos.mask(3)+ pos.mask(1)),(rand()* pos.mask(4)+ pos.mask(2))];
            pinkDot = [(randXY(1)+(pos.res.width-pos.width)/2),...
                (randXY(2)+(pos.res.height-pos.height)/2)];
            Screen('DrawTexture',mainwin,image(im));
            DrawFormattedText(mainwin,'+','center','center');
            Screen('DrawDots',mainwin,pinkDot,8,[255,0,0],[],1);
            Screen('Flip',mainwin);
        end
    end
catch error
    sca;
    rethrow(error)
end
sca;
end
