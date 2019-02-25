function [expInfo] = pressedCheckAcc(firstPress,rtStart,expInfo,t,Trig)

% Check RT and Accuracy
firstPress(firstPress==0)=NaN; % convert zeros to NaNs.
[pressTime, Index]=min(firstPress);
response = KbName(Index);
if strcmpi(response,'ESCAPE')
    error('Quit!')
end
expInfo(t).response = response; % assign response to data str.
if expInfo(t).block == 1 || expInfo(t).block == 2
    %         if pressTime > rtStart
    %             expInfo(t).rt = pressTime - rtStart;
    %         else
    %             expInfo(t).rt = nan;
    %         end
%     SendTrigger(Trig.pressed, Trig.duration);
    if strcmpi(expInfo(t).responseType,'pink') && strcmpi(response,'Return')
        expInfo(t).accuracy = 1;
        expInfo(t).rt = pressTime - rtStart; % return key.
    else
        expInfo(t).accuracy = 0;
        expInfo(t).rt = nan;
    end
else
    expInfo(t).rt = pressTime - rtStart;
    if strcmpi(expInfo(t).responseType,'rSelf')
        if (strcmpi(expInfo(t).imType,'self') ...
                && strcmpi(response(1),'r'))...
                || (strcmpi(expInfo(t).imType,'familiar') ...
                && strcmpi(response(1),'l'))
            expInfo(t).accuracy = 1;
        else
            expInfo(t).accuracy = 0;
        end
    else
        if ((strcmpi(expInfo(t).imType,'self') ...
                && strcmpi(response(1),'l'))...
                ||(strcmpi(expInfo(t).imType,'familiar') ...
                && strcmpi(response(1),'r')))
            expInfo(t).accuracy = 1;
        else
            expInfo(t).accuracy = 0;
        end
    end
end

% Send Trigger.
if expInfo(t).accuracy == 1
    if expInfo(t).block == 3 || expInfo(t).block== 4
%         SendTrigger(Trig.(['expCorrect',upper(response(1))]), Trig.duration);
    end
else
    if expInfo(t).block == 3 || expInfo(t).block== 4
%         SendTrigger(Trig.(['expWrong',upper(response(1))]), Trig.duration);
    end
end
end
