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
cIm.ls4 = 1;cIm.lf4 = 1;cIm.rs4=1;cIm.rf4=1;cIm.cs4=1;cIm.cf4=1;
cIm.ls10 = 14;cIm.lf10 = 14;cIm.rs10=14;cIm.rf10=14;cIm.cs10=14;cIm.cf10=14;
for n = 1: nTrial
    if expInfo(n).freq == 4
        switch expInfo(n).perspective
            case 'left'
                if strcmpi(expInfo(n).imType,'self')
                    expInfo(n).nim = cIm.ls4;
                    cIm.ls4 = cIm.ls4 + 1;
                else
                    expInfo(n).nim = cIm.lf4;
                    cIm.lf4 = cIm.lf4 +1;
                end
            case 'right'
                if strcmpi(expInfo(n).imType,'self')
                    expInfo(n).nim = cIm.rs4;
                    cIm.rs4 = cIm.rs4 +1;
                    
                else
                    expInfo(n).nim = cIm.rf4;
                    cIm.rf4 = cIm.rf4 +1;
                    
                end
            case 'center'
                if strcmpi(expInfo(n).imType,'self')
                    expInfo(n).nim = cIm.cs4;
                    cIm.cs4 = cIm.cs4 + 1;
                    
                else
                    expInfo(n).nim = cIm.cf4;
                    cIm.cf4 = cIm.cf4 +1;
                end
        end
    else
        switch expInfo(n).perspective
            case 'left'
                if strcmpi(expInfo(n).imType,'self')
                    expInfo(n).nim = cIm.ls10;
                    cIm.ls10 = cIm.ls10 + 1;
                else
                    expInfo(n).nim = cIm.lf10;
                    cIm.lf10 = cIm.lf10 +1;
                end
            case 'right'
                if strcmpi(expInfo(n).imType,'self')
                    expInfo(n).nim = cIm.rs10;
                    cIm.rs10 = cIm.rs10 +1;
                    
                else
                    expInfo(n).nim = cIm.rf10;
                    cIm.rf10 = cIm.rf10 +1;
                end
            case 'center'
                if strcmpi(expInfo(n).imType,'self')
                    expInfo(n).nim = cIm.cs10;
                    cIm.cs10 = cIm.cs10 + 1;
                    
                else
                    expInfo(n).nim = cIm.cf10;
                    cIm.cf10 = cIm.cf10 +1;  
                end
        end
    end
end

% assign trial numbers
for n = 1:length(expInfo)
    expInfo(n).trial = n;
end
end
