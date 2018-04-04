%% Description

% New version of script for image generation.
% Pool for noise (around. 3000 noise images).
% Linear coherence levels with 20 steps.
% New mask algo based on color thresholding using HSV colors.
% New better alpha blending algo.
% Updated on 24.03.2018

function [] = stimulusGen()
tic % start stopwatch
expDir = pwd;
subID = input('participant number: '); % As participant number
Imgpath  = [expDir, filesep, 'images', filesep,num2str(subID), filesep];
outputpath = [expDir,filesep, 'processedStimuli',filesep,num2str(subID),filesep];
% Noise output
nOutputpath = [outputpath,'noise',filesep];
% Check directory if outputpath exists.
if ~exist(nOutputpath, 'dir')
    mkdir(nOutputpath);
end

% reset random seed
rand('state',sum(100*clock));

%% Average Magnitude Spectrum

allPics = dir([Imgpath, '*jpg']); % all pictures.
% Image Size
h = 567; % height of the image
w = 400; % width of the image

% compute average magnitude spectrum:
ims = zeros(h,w,length(allPics)); % Pre-allocation

for count = 1:length(allPics)
    picName = [Imgpath, allPics(count).name];
    picGray(:,:,count) = rgb2gray(imread(picName)); % Gray-scale pictures
    picHSV(:,:,:,count) = rgb2hsv(imread(picName)); % hsv pictures.
    ims(:,:,count) = abs(fft2(picGray(:,:,count))); % ims = individual magnitude spectra.
end

MAG_AVG = mean(ims,3);  % MAG_AVG average magnitude spectrum of all images in the dataset
% you get this by extracting individual magnitude spectra from each image
% using abs(fft(image_i)) and then averaging all

%%
imageType = {'s','f'}; % image types.
freq = {'04','10'};
for i = 1: length(imageType)
    imType = imageType{i};
    disp(['Image: ',imType]);
    % Create folder for each type of photos for each subject
    if imType == 's'
        iOutputpath = [outputpath, 'self', filesep];
    elseif imType== 'f'
        iOutputpath = [outputpath, 'familiar', filesep];
    else
        error('We have problem with creating folder. Please check the input for the image type!')
    end
    
    % Check directory if outputpath exists.
    if ~exist(iOutputpath, 'dir')
        mkdir(iOutputpath);
    end
    
    tarPics  = dir([Imgpath, [imType,'*']]); % target pictures
    
    if isempty(tarPics)
        % if target picture does not exist, raise an error.
        error('Error! Can''t find the images! Please check your image file!')
    end
    ntarPics  = length(tarPics); % number of pictures
    
    
    % Preallocation for image matrices
    picM = zeros(h,w,length(tarPics));
    
    % Create matrices that include image names and image values.
    for count = 1:ntarPics
        picName    = [Imgpath, tarPics(count).name];
        picM(:,:,count)  = rgb2gray(imread(picName));
        picHSV(:,:,:,count) = rgb2hsv(imread(picName));
    end
    
    % Creates linear increasing coherence set with 20 steps.
    coh_set = linspace(0,1,20);
    lenCoh = length(coh_set); % Length of coherence set.
    %% Output directory for processed images
    
    nTrials = 26; % number of trials for each perspective (26 in default)
    disp([int2str(ntarPics),' images in total.']);
    
    % Create Images
    for a = 1:ntarPics
        disp(['Creating images for image ', int2str(a), '. Please wait....']);
        cPic= picM(:,:,a);
        
        cImageType = tarPics(a).name(1:4); % Output image.
        
        % Create mask
        cHSV = picHSV(:,:,:,a);
        mask = createMask(cHSV);
        n = 1;
        for f = 1: length(freq)
            cFreq = [freq{f}, '_'];
            for b = 1:nTrials/2 % for each trials
                
                % Shows current trial
                trialWarning = ['Trial: ', num2str(n)];
                disp(trialWarning)
                
                if n < 10
                    cOutputpath = [iOutputpath, cImageType,cFreq, 'trial_0', num2str(n), filesep];
                else
                    cOutputpath = [iOutputpath, cImageType,cFreq, 'trial_', num2str(n), filesep];
                end
                
                if ~exist(cOutputpath, 'dir')
                    mkdir(cOutputpath);
                end
                
                %% Creates images with different coherence values for each trial
                for c = 1: lenCoh
                    for ifreq = 1 : str2double(freq{f})/2
                        current_coh = coh_set(c); % current coherence.
                        nImg = phaseScrambled(cPic,mask,h,w,MAG_AVG,current_coh);
                        
                        %             Write image into jpg file.
                        if c < 10
                            imwrite(nImg,[cOutputpath, cImageType,'0' num2str(c), '_'...
                                num2str(ifreq),'_', num2str(round(current_coh*100)), '.jpeg'], 'jpeg');
                        else
                            imwrite(nImg,[cOutputpath, cImageType, num2str(c), '_'...
                                ,num2str(ifreq) '_', num2str(round(current_coh*100)), '.jpeg'], 'jpeg');
                        end
                    end
                end
                n = n + 1;
            end
        end
    end
    toc;
    tic;
end
% Noise image pool.
disp('Noise images are being created.')
for p = 1: 3000
    if mod(p,100) == 0
        disp(['Noise: ', int2str(p)]);
    end
    
    % Create noise pool
    randMatr = rand(h,w); % random matrix
    RPH_X = angle(fft2(randMatr));
    noise = dakinPhaseSpectrumStaircase(sin(RPH_X),cos(RPH_X),h,w,MAG_AVG);
    noise = imfuse(noise,noise,'blend');
    % Write image into jpg file.
    if p < 10
        imwrite(noise,[nOutputpath,'n_','0' num2str(p), '_', '.jpg'],'jpg');
    else
        imwrite(noise,[nOutputpath,'n_', num2str(p), '_', '.jpg'],'jpg');
    end
    
end

toc % Total elapsed time
disp('Done!')
end

