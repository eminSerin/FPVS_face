% This funciton checks the current trial and send trigger informing current
% frequency, perspective of the images in the current trial.

function [cTrig] = checkTrigger(expInfo,Trig,t)
if strcmpi(expInfo(t).imType,'self')
    if (expInfo(t).block == 1 || expInfo(t).block == 2)
        cTrig = Trig.(['selfImp',upper(expInfo(t).perspective(1))]);
%         SendTrigger(Trig.(['imp',int2str(expInfo(t).freq),'Hz']), Trig.duration);
    else
        cTrig = Trig.(['selfExp',upper(expInfo(t).perspective(1))]);
%         SendTrigger(Trig.(['exp',int2str(expInfo(t).freq),'Hz']), Trig.duration);
    end
else
    if (expInfo(t).block == 1 || expInfo(t).block == 2)
        cTrig = Trig.(['famImp',upper(expInfo(t).perspective(1))]);
%         SendTrigger(Trig.(['imp',int2str(expInfo(t).freq),'Hz']), Trig.duration);
    else
        cTrig = Trig.(['famExp',upper(expInfo(t).perspective(1))]);
%         SendTrigger(Trig.(['exp',int2str(expInfo(t).freq),'Hz']), Trig.duration);
    end
end
end
