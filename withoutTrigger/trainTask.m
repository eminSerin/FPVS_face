function [trainInfo] = trainTask(mainwin,expInfo,frame,cBlock,...
    inputDir,noiseDir,lenNoise,keyList,t,pos,color,msg,trnum,trainInfo,cTrial)

%% Preload Images
DrawFormattedText(mainwin,'+','center','center',color.text);
Screen('Flip',mainwin);

% features
imageType = {'familiar','self'};
perspective = {'left','right','center'};
frequency = {4,10};
pink = {'pink',[]};

% Random features. 
randInf.p = perspective{randi(length(perspective))}; % perspective
randInf.f = frequency{randi(length(frequency))}; % frequency

% Image types. 
% At least one familiar and one self trial. 
switch t
    case 1
        randInf.im = imageType{randi(length(imageType))}; % image type
    case 2 
        randInf.im = 'familiar';
    case 3
        randInf.im = 'self';
end

% Pink
% At least one pink trial. 
if mod(t,2)==0
    randInf.pink = 'pink';
else
    randInf.pink = pink{randi(length(pink))}; % pink
end
randInf.nim = randi(max([expInfo.nim])); % image number

if randInf.f == 4
    cnim = 40;
    modn = 2;
else
    cnim = 100;
    modn = 5;
end

% Save train info.
trainInfo(trnum).im = randInf.im;
trainInfo(trnum).p = randInf.p;
trainInfo(trnum).nim = randInf.nim;
trainInfo(trnum).freq = randInf.f;
trainInfo(trnum).pink = randInf.pink;
trainInfo(trnum).response = [];

% ITI
% number of images presented in ITI. (0-5000ms + 2500 ms fixed noise.)
jitITI = randi(5*randInf.f)+ (2.5*randInf.f);

% Preload noise images.
ITIsequence = zeros(1,(jitITI)* (frame/randInf.f)); % preallocate memory.
nCount = 1; % count for noise sequence.
for i = 1 : jitITI
    r = randi(lenNoise);
    noiseText = Screen('MakeTexture', mainwin, imread(noiseDir(r).name));
    for f = 1 : (frame/randInf.f)
        ITIsequence(nCount) = noiseText;
        nCount = nCount + 1;
    end
end

% Load face images.
if randInf.nim >= 10
    faceDir = dir([inputDir randInf.im filesep [randInf.im(1)...
        '_' randInf.p(1) '_' 'trial_' int2str(randInf.nim)] filesep '*jpg']);
else
    faceDir = dir([inputDir randInf.im filesep [randInf.im(1)...
        '_' randInf.p(1) '_' 'trial_' ['0' int2str(randInf.nim)]] filesep '*jpg']);
end

% Create image presentation sequence.
sequence = zeros(1,(cnim*(frame/randInf.f))); % preallocate memory.
fCount = 1; % count for face images.
fnCount = 1; % count for sequence.
for i = 1: cnim
    if ~(mod(i, modn)==0)
        r = randi(lenNoise);
        picText =  Screen('MakeTexture', mainwin, imread(noiseDir(r).name));
        for f = 1 : (frame/randInf.f)
            sequence(fnCount) = picText;
            fnCount = fnCount + 1;
        end
    else
        picText = Screen('MakeTexture', mainwin, imread(faceDir(fCount).name));
        for f = 1 : (frame/randInf.f)
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

pressed = 0;
if ~strcmpi(randInf.pink,'pink') || ~(cBlock == 1 || cBlock == 2)
    for n = 1: length(sequence)
        Screen('DrawTexture',mainwin,sequence(n));
        Screen('Flip',mainwin);
        if ~pressed
            [pressed,firstPress]=KbQueueCheck; % Check pressed buttons.
        end
    end
else
    pinkDot = rand()*10; % random in 10 sec window.
    dotTime = pinkDot + GetSecs;
    randXY = [(rand()*pos.mask(3)+ pos.mask(1)),(rand()* pos.mask(4)+ pos.mask(2))];
    pinkDot = [(randXY(1)+(pos.res.width-pos.width)/2),...
        (randXY(2)+(pos.res.height-pos.height)/2)]; % random pink dot location. 
    for n = 1: length(sequence)
        Screen('DrawTexture',mainwin,sequence(n));
        if GetSecs > dotTime && GetSecs < dotTime + .03
            Screen('DrawDots',mainwin,pinkDot,8,color.pink,[],1);
        end
        Screen('Flip',mainwin);
        if ~pressed
            [pressed,firstPress]=KbQueueCheck; % Check pressed buttons.
        end
    end
end
KbQueueRelease;
Screen('Close');

%% give feedback
% Check RT and Accuracy
if pressed
    firstPress(firstPress==0)=NaN; % convert zeros to NaNs.
    [~, Index]=min(firstPress);
    response = KbName(Index);
    trainInfo(trnum).response = response;
    if strcmpi(response,'ESCAPE')
        error('Quit!')
    end
    if cBlock == 1 || cBlock == 2
        if strcmpi(randInf.pink,'pink') && strcmpi(response,'Return')
            cMsg = msg.correct;
        else
            cMsg = msg.wrong;
        end
    else
        if strcmpi(expInfo(cTrial).responseType,'lSelf')
            if (strcmpi(randInf.im,'self') ...
                    && strcmpi(response(1),'l'))...
                    || (strcmpi(randInf.im,'familiar') ...
                    && strcmpi(response(1),'r'))
                cMsg = msg.correct;
            else
                cMsg = msg.wrong;
            end
        else
            if ((strcmpi(randInf.im,'self') ...
                    && strcmpi(response(1),'r'))...
                    || (strcmpi(randInf.im,'familiar') ...
                    && strcmpi(response(1),'l')))
                cMsg = msg.correct;
            else
                cMsg = msg.wrong;
            end
        end
    end
else
    if isempty(randInf.pink)
        cMsg = msg.correct;
    else
        cMsg = msg.wrong;
    end
end

trainInfo(trnum).cMsg = cMsg;

DrawFormattedText(mainwin,cMsg,'center','center');
Screen('Flip',mainwin);
WaitSecs(.3);

end