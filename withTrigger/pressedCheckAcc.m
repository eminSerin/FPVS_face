function [expInfo] = pressedCheckAcc(firstPress,rtStart,expInfo,t,Trig)
%   pressedCheckAcc checks whether participants pressed any key or not, and
%   returns the accuracy and RT values. 
%   
%   Input: 
%       firstPress: Press time. 
%       rtStart: Stimulus onset time. 
%       expInfo: Experiment structure. 
%       t: Current trial
%       Trig: Trigger structure.
%
%   Output: 
%       expInfo: Experiment structure with accuracy and RT values.
%
%   Emin Serin - Berlin School of Mind and Brain
%
%% Main Script. 
% Check RT and Accuracy
firstPress(firstPress==0)=NaN; % convert zeros to NaNs.
[pressTime, Index]=min(firstPress);
response = KbName(Index);
if strcmpi(response,'ESCAPE')
    error('Quit!')
end
expInfo(t).response = response; % assign response to data str.
if expInfo(t).block == 1 || expInfo(t).block == 2
    % If implicit
    SendTrigger(Trig.pressed, Trig.duration);
    if strcmpi(expInfo(t).responseType,'pink') && strcmpi(response,'Return')
        % Correct
        expInfo(t).accuracy = 1;
        expInfo(t).rt = pressTime - rtStart; % return key.
    else
        % Wrong
        expInfo(t).accuracy = 0;
        expInfo(t).rt = nan;
    end
else
    % If explicit
    expInfo(t).rt = pressTime - rtStart;
    if strcmpi(expInfo(t).responseType,'rSelf')
        % if right self condition. 
        if (strcmpi(expInfo(t).imType,'self') ...
                && strcmpi(response(1),'r'))...
                || (strcmpi(expInfo(t).imType,'familiar') ...
                && strcmpi(response(1),'l'))
            % Correct
            expInfo(t).accuracy = 1;
        else
            %Wrong
            expInfo(t).accuracy = 0;
        end
    else
        % if left self condition.
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
        SendTrigger(Trig.(['expCorrect',upper(response(1))]), Trig.duration);
    end
else
    if expInfo(t).block == 3 || expInfo(t).block== 4
        SendTrigger(Trig.(['expWrong',upper(response(1))]), Trig.duration);
    end
end
end