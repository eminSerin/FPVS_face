function [faceDuration] = imagePreload(inputDir,noiseDir,expInfo,lenNoise,color)
% Open drawing window in your display with maximum number. That means
% if you have external monitor, it will open drawing window on it. To
% run experiment on your main display write 0 (zero) instead of
% maxScreen.
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
    
    if cInfo.freq == 4
        % Current number of images and modular value.
        cnim = 40;
        modn = 2;
    else
        cnim = 100;
        modn = 5;
    end
    
    % ITI
    % number of images presented in ITI. (0-5000ms + 2500 ms fixed noise.)
    jitITI = randi(5*cInfo.freq) + (2.5*cInfo.freq);
    
    tic;
    % Preload noise images.
    ITIsequence = zeros(1,(jitITI)* (frame/cInfo.freq)); % preallocate memory.
    nCount = 1; % count for noise sequence.
    for i = 1 : jitITI
        r = randi(lenNoise);
        noiseText = Screen('MakeTexture', mainwin, imread(noiseDir(r).name));
        for f = 1 : (frame/cInfo.freq)
            ITIsequence(nCount) = noiseText;
            nCount = nCount + 1;
        end
    end
    
    % Load face images.
    if str2double(cInfo.nim) >= 10
        faceDir = dir([inputDir expInfo(t).imType filesep [expInfo(t).imType(1)...
            '_' expInfo(t).perspective(1) '_' 'trial_' cInfo.nim] filesep '*jpg']);
    else
        faceDir = dir([inputDir expInfo(t).imType filesep [expInfo(t).imType(1)...
            '_' expInfo(t).perspective(1) '_' 'trial_' ['0' cInfo.nim]] filesep '*jpg']);
    end
    
    % Create image presentation sequence.
    sequence = zeros(1,(cnim*(frame/cInfo.freq))); % preallocate memory.
    fCount = 1; % count for face images.
    fnCount = 1; % count for sequence.
    for i = 1: cnim
        if ~(mod(i, modn)==0)
            % Noise images.
            r = randi(lenNoise);
            picText =  Screen('MakeTexture', mainwin, imread(noiseDir(r).name));
            for f = 1 : (frame/cInfo.freq)
                sequence(fnCount) = picText;
                fnCount = fnCount + 1;
            end
        else
            % Face images.
            picText = Screen('MakeTexture', mainwin, imread(faceDir(fCount).name));
            for f = 1 : (frame/cInfo.freq)
                sequence(fnCount) = picText;
                fnCount = fnCount + 1;
            end
            fCount = fCount + 1;
        end
    end
    Screen('Close');
    faceDuration(t) = toc;
end
end
