function [NEW_I] = dakinPhaseSpectrumStaircase(S, C, m, n, MAG_AVG)
%JH
% Image phase scrambling routine using the routine described in the
% Dakin paper sited in Philiastides et al., CerCor 2006. Modified JH
%       average magnitude spectrum of all images in the dataset
%       you get this by extracting individual magnitude spectra from
%       each image using abs(fft(image_i)) and then averaging all
%
% NEW_I = phase scrambled version of target image

% pre allocate.
NPH_X = zeros(m,n);

ind_1 = S>0 & C>0;
ind_2 = S>0 & C<0;
ind_3 = S<0 & C<0;
ind_4 = S<0 & C>0;

% Weighted mean algorithm.
NPH_X(ind_1) = atan(S(ind_1)./C(ind_1));

NPH_X(ind_2) = atan(S(ind_2)./C(ind_2)) + pi;

NPH_X(ind_3) = atan(S(ind_3)./C(ind_3)) - pi;

NPH_X(ind_4) = atan(S(ind_4)./C(ind_4));

%%%%JH%%%%%
NEW_X = real(ifft2(MAG_AVG.*exp(sqrt(-1)*(NPH_X))));
%NEW_X = real(NEW_X); % prevents: Warning: Displaying real part of complex input.
%%%%JH%%%%

NEW_I = uint8(NEW_X);
end
