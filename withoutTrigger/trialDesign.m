function [expInfo] = trialDesign(cond)
% trial design
imageType = {'familiar','self'}; % Image types used in the experiment
perspective = {'left','right','center'};
frequency = {4,10};

expInfo.trial = [];
expInfo.block = [];
count = 0;

%% Genesis block.
for n = 1: 3
    for i = 1: length(imageType)
        for p = 1: length(perspective)
            for f = 1: length(frequency)
                count = count + 1;
                expInfo(count).imType = imageType{i};
                expInfo(count).perspective = perspective{p};
                expInfo(count).nim = [];
                expInfo(count).freq = frequency{f};
                expInfo(count).responseType = [];
                expInfo(count).response = [];
                expInfo(count).accuracy = [];
                expInfo(count).rt = [];
            end
        end
    end
end

% temporary blocks for implicit block
block1 = expInfo; block2 = expInfo;

%% Implicit block
for n = 1: 12
    iBlock(n) = expInfo(n);
    iBlock(n).responseType = 'pink';
end

iBlock = Shuffle(iBlock);
for n = 1: length(iBlock)/2
    block1 = [block1 iBlock(n)];
end
for n = 1: length(iBlock)/2
    block2 = [block2 iBlock(length(iBlock)/2 + n)];
end
for n = 1: length(block1)
    block1(n).block = 1;
    block2(n).block = 2;
end
iBlock = [Shuffle(block1), Shuffle(block2)];

%% Explicit block
eBlock = [Shuffle(expInfo),Shuffle(expInfo)];
if strcmpi(cond,'l')
    responseType = {'lSelf','rSelf'};
else
    responseType = {'rSelf','lSelf'};
end
count = 0;
for r = 1: length(responseType)
    for t = 1: length(eBlock)/2
        count = count +1;
        eBlock(count).responseType = responseType{r};
        eBlock(count).block = r+2;
    end
end

expInfo = [iBlock, eBlock]; % merge blocks
nTrial = length(expInfo); % number of trials

%% image number asign
cIm.ls = 0;cIm.lf = 0;cIm.rs=0;cIm.rf=0;cIm.cs=0;cIm.cf=0;
for n = 1: nTrial
    switch expInfo(n).perspective
        case 'left'
            if strcmpi(expInfo(n).imType,'self')
                cIm.ls = cIm.ls + 1;
                expInfo(n).nim = cIm.ls;
            else
                cIm.lf = cIm.lf +1;
                expInfo(n).nim = cIm.lf;
            end
        case 'right'
            if strcmpi(expInfo(n).imType,'self')
                cIm.rs = cIm.rs + 1;
                expInfo(n).nim = cIm.rs;
            else
                cIm.rf = cIm.rf +1;
                expInfo(n).nim = cIm.rf;
            end
        case 'center'
            if strcmpi(expInfo(n).imType,'self')
                cIm.cs = cIm.cs + 1;
                expInfo(n).nim = cIm.cs;
            else
                cIm.cf = cIm.cf +1;
                expInfo(n).nim = cIm.cf;
            end
    end
end

% assign trial numbers
for n = 1:length(expInfo)
    expInfo(n).trial = n;
end
