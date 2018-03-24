function [faceDuration] = imagePreload(inputDir,noiseDir,expInfo,lenNoise,color)
% Open drawing window in your display with maximum number. That means
% if you have external monitor, it will open drawing window on it. To
% run experiment on your main display write 0 (zero) instead of
% maxScreen.
try
screen = max(Screen('Screens'));
mainwin = Screen('OpenWindow',screen, color.bg);
Priority(MaxPriority(mainwin)); % set the window high priority
frame = Screen('FrameRate',screen);

% for i = 1: length(noiseDir)
%     tic;
%     noiseText(i) = Screen('MakeTexture', mainwin, imread(noiseDir(i).name));
%     noiseDuration(i) = toc;
% end

for t = 1: 156
    DrawFormattedText(mainwin,'+','center','center',255);
    DrawFormattedText(mainwin,['Trial: ',int2str(t)],255);
    Screen('Flip',mainwin);
    
    % Current freq
    cInfo.nim = int2str(expInfo(t).nim);
    cInfo.freq = expInfo(t).freq;
    
    % ITI
    % number of images presented in ITI. (0-5000ms + 2500 ms fixed noise.)
    jitITI = randi(5*cInfo.freq*2) + (2.5*cInfo.freq*2);
    
    tic;
    % Preload noise images.
    % ITIsequence = zeros(1,(jitITI)* floor((frame/cInfo.freq)*0.5)); % preallocate memory.
    nCount = 1; % count for noise sequence.
    for i = 1 : jitITI
        r = randi(lenNoise);
        noiseText = Screen('MakeTexture', mainwin, imread(noiseDir(r).name));
        for f = 1 : ceil((frame/cInfo.freq)*0.5)
            ITIsequence(nCount) = noiseText;
            nCount = nCount + 1;
        end
    end
    
    % Load face images.
    if cInfo.freq == 4
        freqStr = '04';
    else
        freqStr = num2str(cInfo.freq);
    end
    if str2double(cInfo.nim) >= 10
        faceDir = dir([inputDir expInfo(t).imType filesep [expInfo(t).imType(1)...
            '_' expInfo(t).perspective(1) '_' freqStr '_' 'trial_' cInfo.nim] filesep '*jpeg']);
    else
        faceDir = dir([inputDir expInfo(t).imType filesep [expInfo(t).imType(1)...
            '_' expInfo(t).perspective(1) '_' freqStr '_' 'trial_' ['0' cInfo.nim]] filesep '*jpeg']);
    end
    
    % Create image presentation sequence.
    % sequence = zeros(1,(length(faceDir)*(frame/cInfo.freq)*2)); % preallocate memory.
    fnCount = 1;
    sequence = [];
    for c = 1 : length(faceDir)
        picText(1) = Screen('MakeTexture', mainwin, imread(faceDir(c).name));
        picText(2) = Screen('MakeTexture', mainwin, imread(noiseDir(randi(lenNoise)).name));
        for p = 1 : 2
            for f = 1 : floor((frame/cInfo.freq)*0.5)
                sequence(fnCount) = picText(p);
                fnCount = fnCount + 1;
            end
        end
    end
    Screen('Close');
    faceDuration(t) = toc;
end
catch error
    sca;
    rethrow(error);
end
sca;
save('faceData.mat','faceDuration');
end

