function nImg = phaseScrambled(cPic,mask,h,w,MAG_AVG,current_coh)
%   phaseScrambled generates phase scrambled image of given image. 
%       
%   Input:
%       cPic: current image matrix.
%       mask: mask generated for given image.
%       h: Height of the image
%       w: Widht of the image
%       MAG_AVG: mean magnitude of the image.
%       current_coh: Coherence value of the image to be generated.
%
%   Output:
%       nImg: Phase scrambled version of given image. 
%
%   Emin Serin - Berlin School of Mind and Brain
%
%% Main Script.
randMatr = rand(h,w); % random matrix

PH_S = angle(fft2(cPic)); % PSD angle of pic. 

RPH_X = angle(fft2(randMatr)); % PSD angle of random matrix. 

noise = dakinPhaseSpectrumStaircase(sin(RPH_X),cos(RPH_X),h,w,MAG_AVG); % create noise pic.
noise = alphaBlend(noise,noise,'blend'); % alpha blend noise with noise to increase luminance. 

% Phase spectrum of given image.
Sin = current_coh*sin(PH_S) + (1-current_coh)*sin(RPH_X);
Cos = current_coh*cos(PH_S) + (1-current_coh)*cos(RPH_X);
nImg = dakinPhaseSpectrumStaircase(Sin, Cos, h, w, MAG_AVG); % create img pic. 
nImg = alphaBlend(nImg,noise,'blend'); % alpha blend noise with face. 
nImg = uint8(mask .* double(nImg) + (1-mask) .* double(noise)); % combine noise and pic. 

end