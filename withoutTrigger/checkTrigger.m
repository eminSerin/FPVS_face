function [cTrig] = checkTrigger(expInfo,t)
if strcmpi(expInfo(t).imType,'self')
    if (expInfo(t).block == 1 || expInfo(t).block == 2)
        cTrig = ['Trigger selfImp',upper(expInfo(t).perspective(1))];
        disp(['Trigger imp',int2str(expInfo(t).freq),'Hz']);
    else
        cTrig = ['Trigger selfExp',upper(expInfo(t).perspective(1))];
        disp(['Trigger exp',int2str(expInfo(t).freq),'Hz']);
    end
else
    if (expInfo(t).block == 1 || expInfo(t).block == 2)
        cTrig = ['Trigger famImp',upper(expInfo(t).perspective(1))];
        disp(['Trigger imp',int2str(expInfo(t).freq),'Hz']);
    else
        cTrig = ['Trigger famExp',upper(expInfo(t).perspective(1))];
        disp(['Trigger exp',int2str(expInfo(t).freq),'Hz']);
    end
end
end