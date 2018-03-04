function [] = SSVEP(subID)
try
%     clc;
%     clear;
    
%     subID = input('Participant number: ','s'); % ask participant id. 
%     subID = '7';
    cond = 'l'; % left self > right self.
    %% Experimental Parameters
    
    % Where stimuli folders locate
    inputDir = [pwd filesep 'processedStimuli' filesep subID filesep];
    noiseDir = dir([inputDir, 'noise' filesep '*jpg']);
    outputDir = [pwd filesep 'Data' filesep];
    
    % Defines keys used in experiment. You can also substitute the target
    % keys with the keys whatever you want.
    KbName('UnifyKeyNames');
    keys.rightArrow = KbName('RightArrow');
    keys.leftControl = KbName('LeftControl');
    keys.esc = KbName('ESCAPE');
    keys.enter = KbName('Return');
    
    % Create list of specific keys we want to record.
    keys.keyList= zeros(1,256);
    keys.keyList(keys.leftControl) = 1;
    keys.keyList(keys.rightArrow) = 1;
    keys.keyList(keys.enter) = 1;
    keys.keyList(keys.esc) = 1;
    
    % Color codes used for the task.
    color.bg = [0 0 0]; % black background
    color.pink = [255,105,180]; %pink
    color.text = [255 255 255]; % white
    
    % Size of noise pool
    lenNoise = length(noiseDir);
    %% Trial Design
    expInfo = trialDesign(cond);
    
    % reset random seed
    rand('state',sum(100*clock));
    
    %% Screen Parameters
    
    % Get number of screens used, and use the display with the greatest
    % display number. For instance if you use external display with laptop,
    % experiment take place on external display.
    screen = max(Screen('Screens'));
    
    % Skip Sync Test. Decrease timing accuracy. Please Change when you
    % figure out problem!! If you have problem with screen synchronization
    % test please uncomment the one line of code below this comment
    % removing % before the code. This code skip the sync. test, but it may
    % create timing inconsistencies in miliseconds.
    Screen('Preference', 'SkipSyncTests', 0);
    
    % Close warnings. 
    Screen('Preference', 'VisualDebugLevel',1); % Only critical errors. 
    
    % Open drawing window in your display with maximum number. That means
    % if you have external monitor, it will open drawing window on it. To
    % run experiment on your main display write 0 (zero) instead of
    % maxScreen.
    mainwin = Screen('OpenWindow',screen, color.bg);
    Priority(MaxPriority(mainwin)); % set the window high priority
    
    % Location for dot.
    pos.res = Screen('Resolution',mainwin); % screen resolution
    pos.height = 567; % stimulus height
    pos.width = 400; % stimulus width
    pos.mask = [134 173 135 180];
    
    % Screen framerate
    frame = Screen('FrameRate',screen);

    %% Welcome, Goodbye and Instructions
    msg.welcome = ['Willkommen zu unserer Studie! \n Dieses Experiment',...
        'besteht aus zwei verschiedenen Aufgaben mit jeweils zwei Blöcken.' ...
        '\n Drücken Sie nun eine beliebige Taste, um fortzufahren.'];
    msg.lSelf= ['Bitte drücken Sie so schnell wie möglich die linke STRG-TASTE, sobald Sie Ihr eigenes ',...
        'Gesicht auf dem Bildschirm sehen, oder die rechte PFEIL-TASTE, sobald Sie das Gesicht ',...
        'Ihrer Freundin/Ihres Frendes sehen.\n',...
        'Drücken Sie nun eine beliebige Taste, um fortzufahren.'];
    msg.rSelf = ['Bitte drücken Sie so schnell wie möglich die rechte PFEIL-TASTE, sobald Sie Ihr eigenes ',...
        'Gesicht auf dem Bildschirm sehen, oder die linke STRG-TASTE, sobald Sie das Gesicht  ',...
        'Ihrer Freundin/Ihres Frendes sehen.\n',...
        'Drücken Sie nun eine beliebige Taste, um fortzufahren.'];
    msg.block2 = ['Die Aufgabe ist dieselbe, wie im vorherigen Block. \n',...
        'Drücken Sie eine beliebige Taste, um zu starten.'];
    msg.block = ['Block '];
    msg.keyChange = ['Die jeweiligen Tasten wurden getauscht. \n '];
    msg.task1 = ['Aufgabe 1 \n',...
        'Ihre Aufgabe wird es sein, das Erscheinen eines pinken Punktes auf dem Bildschirm zu erkennen.\n',...
        'Bitte drücken Sie so schnell wie möglich mit Ihrer rechten Hand die EINGABETASTE,',...
        'sobald Sie den pinken Punkt auf dem Bildschirm sehen. Es wird jedoch auch Durchgeange geben,',...
        'in denen kein Punkt erscheint.\n Drücken Sie nun eine beliebige Taste, um fortzufahren.'];
    msg.task2 = ['Aufgabe 2. \n Dieses Mal sollen Sie auf das Erscheinen',...
        'Ihres eigenen Gesichts bzw. das Gesicht einer Ihnen bekannten Person reagieren.\n'];
    msg.training = ['Trainingsphase.\n Drücken Sie eine beliebige Taste, um zu starten.'];
    msg.main = ['Die Trainingsphase ist beendet.\n Drücken Sie nun eine beliebige Taste, um die Testung zu starten.'];
    msg.goodbye = ['Das Experiment ist beendet.\n Vielen Dank für Ihre Teilnahme!\n',...
        'Bitte wenden Sie sich an die Versuchsleitung.'];
    msg.correct = ['Richtig!'];
    msg.wrong = ['Falsch!'];
    
    %% Welcome  message.
    HideCursor( ); % Hide Cursor
%     DrawFormattedText(mainwin,msg.welcome,'center','center',...
%         color.text,60,[],[],1.5); Screen('Flip',mainwin);
%     KbWait;
%     WaitSecs(.3);
    
    %% Experiment
    trainInfo = []; % training info.
    trnum = 1; % traning info num. 
    for cBlock = 1: 4 % Four blocks.
        %% Training Block
        disp(['Block: ', int2str(cBlock)]);
        disp('Training...');
        
        % First trial of the block.
        trial= [expInfo(([expInfo.block]==cBlock)).trial];
        trial = trial(1); % starting trial for the block.
        
        % Block instruction
        DrawFormattedText(mainwin,[msg.block, int2str(cBlock)],...
            'center','center',color.text,60);
        Screen('Flip',mainwin);
        WaitSecs(1);
        
%         if ~(cBlock == 2)
%             switch cBlock
%                 case 1
%                     cMsg = msg.task1;
%                 case 3
%                     cMsg = [msg.task2,msg.(expInfo(trial).responseType)];
%                 case 4
%                     cMsg = [msg.keyChange,msg.(expInfo(trial).responseType)];
%             end
%             
%             DrawFormattedText(mainwin, cMsg,'center','center',...
%                 color.text,60,[],[],1.5); Screen('Flip',mainwin);
%             KbStrokeWait; WaitSecs(.3);
%             DrawFormattedText(mainwin,msg.training,'center','center',...
%                 color.text,60,[],[],1.5); Screen('Flip',mainwin);
%             KbStrokeWait; WaitSecs(.3);
%             
%             % Task function
%             for t = 1:3 % Number of train trials.
%                 trainInfo = trainTask(mainwin,expInfo,frame,cBlock,...
%                     inputDir,noiseDir,lenNoise,keys.keyList,t,pos,color,...
%                     msg,trnum,trainInfo,trial);
%                 trnum = trnum + 1; 
%             end
%             
%             % Training finished message.
%             DrawFormattedText(mainwin,msg.main,'center','center',...
%                 color.text,60,[],[],1.5); Screen('Flip',mainwin);
%             WaitSecs(.3); KbWait;
%             
%         else
%             DrawFormattedText(mainwin, msg.block2,'center','center',...
%                 color.text,60,[],[],1.5); Screen('Flip',mainwin);
%             KbStrokeWait;
%         end
        %% Test Block
        tnum = 2;
        cTrial = trial;
        disp('Test...');
%         for t = 1: tnum % Number of task trials.
        while expInfo(cTrial).block == cBlock
            disp(['Trial: ',int2str(cTrial)]);
            % Task function
            [expInfo] = testTask(mainwin,expInfo,frame,...
                inputDir,noiseDir,lenNoise,keys.keyList,cTrial,pos,color);
            cTrial = cTrial + 1; % update current trial number.
            save([outputDir,'Data_',subID,'_s1.mat'],'expInfo','trainInfo');
            if cTrial == 157
                break;
            end
        end
    end
      
    KbQueueStop;
    % End message.
%     DrawFormattedText(mainwin,msg.goodbye,'center','center',...
%         color.text,60,[],[],2); Screen('Flip',mainwin); KbWait;
catch error
    sca;
    rethrow(error);
    save([outputDir,'Data_',subID,'_s1.mat'],'expInfo','trainInfo');
end
sca;
end