function [] = stimulusGen(varargin)
% stimulusGen generates phase scrambled images using Dakin et. al. (2002)
% algorithm. Input images are decomposed into power and phase using Fast
% Fourier Transformation, and phase of the each images are changed with
% random phase. Power of the images are also changed by averaged magnitude
% of all images in the images folder. HSV color space is used to mask out
% background.
% stimulusGen is designed for the FPVS studies. So it creates images to be
% presented at different frequencies (4Hz in default).
%
% Usage:
%
% [] = stimulusGen(). Generates 26 phase scrambled images for 4Hz
% FPVS and 3000 noise images.
%
% [] = stimulusGen({'04','10'},15,1000). Generates 15 images for 4Hz and
% 10Hz FPVS and 1000 noise images. Frequencies values are has to be string.
%
% References:
%
% Dakin, S. C., Hess, R. F., Ledgeway, T., & Achtman, R. L.
% (2002). What causes non-monotonic tuning of fMRI response to noisy
% images?. Current Biology, 12(14), R476-R477.
%
% Ales, J. M., Farzin, F., Rossion, B., & Norcia, A. M. (2012). An objective
% method for measuring face detection thresholds using the sweep
% steady-state visual evoked response. Journal of vision, 12(10), 18-18.
%
% Author: Emin Serin / Berlin School of Mind and Brain / 2018
%
%% Input parameters.
if length(varargin) > 3
    % raise an error if more than 3 parameters given.
    error(['requires at most 3 arguements.',' e.g. stimulusGen({''04'',''10''},13)'])
end
optargs = {[4],26,3000}; % default parameters.
optargs(1:length(varargin)) = varargin; % overwrite parameters if given.

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
freq = optargs{1}; % image presentation frequency used in FPVS.

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
    
    nImages = optargs{2}; % number of images created from each input images.
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
            cFreq = freq(f);
            for b = 1:nImages % for each trials
                
                % Shows current trial
                trialWarning = ['Trial: ', num2str(n)];
                disp(trialWarning)
                
                cOutputpath = [iOutputpath, cImageType,[sprintf('%02d',cFreq),'_'],...
                    ['trial_',sprintf('%02d',n)], filesep];
                
                if ~exist(cOutputpath, 'dir')
                    mkdir(cOutputpath);
                end
                
                %% Creates images with different coherence values for each trial
                for c = 1: lenCoh
                    for ifreq = 1 : cFreq/2
                        current_coh = coh_set(c); % current coherence.
                        nImg = phaseScrambled(cPic,mask,h,w,MAG_AVG,current_coh);
                        
                        % Write image into jpg file.
                        imwrite(nImg,[cOutputpath, cImageType,sprintf('%02d',c) '_'...
                            num2str(ifreq),'_', num2str(round(current_coh*100)), '.jpeg'], 'jpeg');
                        
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
for p = 1: optargs{3}
    if mod(p,100) == 0
        disp(['Noise: ', int2str(p)]);
    end
    
    % Create noise pool
    randMatr = rand(h,w); % random matrix
    RPH_X = angle(fft2(randMatr));
    noise = dakinPhaseSpectrumStaircase(sin(RPH_X),cos(RPH_X),h,w,MAG_AVG);
    noise = imfuse(noise,noise,'blend');
    
    % Write image into jpg file.
    imwrite(noise,[nOutputpath,'n_',sprintf('%02d',p), '_', '.jpg'],'jpg');
    
end

toc % Total elapsed time
disp('Done!')
end

