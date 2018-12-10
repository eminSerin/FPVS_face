function [cTrig] = checkTrigger(expInfo,Trig,t)
%   checkTrigger checks the current trial and send trigger informing current
%   frequency and perspective of the images in the current trial.
%   
%   Input:
%       expInfo: Structure that contains experimental information
%       Trig: Trigger structure.
%       t: Current trial. 
%
%   Output: 
%       cTrig: Trigger corresponding the current trial. 
%
%   Emin Serin - Berlin School of Mind and Brain
%
%% Main Script. 
if strcmpi(expInfo(t).imType,'self')
    % If self
    if (expInfo(t).block == 1 || expInfo(t).block == 2)
        % If implicit
        cTrig = Trig.(['selfImp',upper(expInfo(t).perspective(1))]);
        SendTrigger(Trig.(['imp',int2str(expInfo(t).freq),'Hz']), Trig.duration);
    else
        % If explicit
        cTrig = Trig.(['selfExp',upper(expInfo(t).perspective(1))]);
        SendTrigger(Trig.(['exp',int2str(expInfo(t).freq),'Hz']), Trig.duration);
    end
else
    % If familiar other
    if (expInfo(t).block == 1 || expInfo(t).block == 2)
        % If implicit
        cTrig = Trig.(['famImp',upper(expInfo(t).perspective(1))]);
        SendTrigger(Trig.(['imp',int2str(expInfo(t).freq),'Hz']), Trig.duration);
    else
        % If explicits
        cTrig = Trig.(['famExp',upper(expInfo(t).perspective(1))]);
        SendTrigger(Trig.(['exp',int2str(expInfo(t).freq),'Hz']), Trig.duration);
    end
end
end