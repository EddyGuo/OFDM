function H_LS = LS_CE(Y,Xp,pilot_loc,Nfft,Np)
% LS channel estimation function
% Inputs:
%       Y         = Frequency-domain received signal
%       Xp        = Pilot signal
%       pilot_loc = Pilot location
%       N         = FFT size
%       Nps       = Pilot spacing
%       int_opt   = 'linear' or 'spline'
% output:
%       H_LS      = LS channel etimate

%MIMO-OFDM Wireless Communications with MATLAB¢ç   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%?2010 John Wiley & Sons (Asia) Pte Ltd

k=1:Np; 
LS_est(k) = Y(pilot_loc(k))./Xp(k);  % LS channel estimation
H_LS = InterPLT(LS_est, pilot_loc, Nfft, 'spline'); % Linear/Spline interpolation