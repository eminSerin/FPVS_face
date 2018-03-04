    function [expInfo] = testTask(mainwin,expInfo,frame,...
    inputDir,noiseDir,lenNoise,keyList,t,pos,color,Trig)

%% Preload Images
cTrig = checkTrigger(expInfo,Trig,t);
DrawFormattedText(mainwin,'+','center','center',color.text);
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

%% Task
% ITI
for n = 1 : length(ITIsequence)
    Screen('DrawTexture',mainwin,ITIsequence(n));
    Screen('Flip',mainwin);
end

% Keypress Queue
KbQueueCreate([],keyList);
KbQueueStart;
rtStart=GetSecs;
pressed = 0;
tic;
SendTrigger(cTrig, Trig.duration);
if ~strcmpi(expInfo(t).responseType,'pink')
    for n = 1: length(sequence)
        Screen('DrawTexture',mainwin,sequence(n));
        Screen('Flip',mainwin);
        if ~pressed
            [pressed,firstPress]=KbQueueCheck; % Check pressed buttons.
            if pressed
                % check accuracy and rt and send trigger.
                expInfo = pressedCheckAcc(firstPress,rtStart,expInfo,t,Trig);
            end
        end
    end
else
    pinkDot = rand()*10; % random in 10 sec window.
    dotTime = pinkDot + GetSecs;
    rtStart = dotTime;
    randXY = [(rand()*pos.mask(3)+ pos.mask(1)),(rand()* pos.mask(4)+ pos.mask(2))];
    pinkDot = [(randXY(1)+(pos.res.width-pos.width)/2),...
        (randXY(2)+(pos.res.height-pos.height)/2)]; % random pink dot position.
    pinkPresent = 0;
    for n = 1: length(sequence)
        Screen('DrawTexture',mainwin,sequence(n));
        if GetSecs > dotTime && GetSecs < dotTime + .25
            Screen('DrawDots',mainwin,pinkDot,8,color.pink,[],1);
            if ~pinkPresent
                SendTrigger(Trig.pink, Trig.duration);
                pinkPresent = 1;
            end
        end
        Screen('Flip',mainwin);
        if ~pressed
            [pressed,firstPress]=KbQueueCheck; % Check pressed buttons.
            if pressed
                % check accuracy and rt and send trigger.
                expInfo = pressedCheckAcc(firstPress,rtStart,expInfo,t,Trig);
            end
        end
    end
end
toc;
KbQueueRelease; % Clear keypress queue.
Screen('Close'); % Close all offscreens.

if ~pressed
    if isempty(expInfo(t).responseType)
        expInfo(t).accuracy = 1;
    elseif strcmpi(expInfo(t).responseType,'pink')
        expInfo(t).accuracy = 0;
     else
        expInfo(t).accuracy = 0;
        SendTrigger(Trig.expWrongNaN, Trig.duration);
    end
    expInfo(t).rt = nan;
    expInfo(t).response = nan;
end
end