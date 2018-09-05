function [dist] = auditory_distance(vf_resp1, vf_resp2, v_frq, v_frange)
% [dist] = auditory_distance(vf_resp1, vf_resp2, v_frq, v_frange)
%
% Auditory spectral distance between two spectra/frequency responses.
% Average spectral error in a specified frequency range, spectral weighting
% with inverse ERB-bandwidth to counteract perceptual over-representation
% of high frequencies in fourier spectrum.
%    vf_resp1, 2: complex spectra to be compared, up to half-sampling
%        frequency
%    v_frq: corresponding frequency vecor 
%    v_frange: [optional] Frequency range in which error is computed [f1 f2]
%              default: full range
%
% dist: auditory spectral distance in dB
%
% Florian Denk, 11.04.2018

if nargin < 4 
    v_frange = [0, v_frq(end)];
end

v_frq = v_frq(:);
    
% 1 Frequency range of interest
i_frqrange = find(v_frq >= v_frange(1) & v_frq<= v_frange(2)) ;

% 2 Averaging weight
v_weight = 1./ erb_bw(v_frq (i_frqrange));
v_weight = v_weight / sum(v_weight); % normalize to 1


% 3 Calc error and average over frequencies
dist = sum (abs (mag2db(abs( vf_resp1(i_frqrange ))) - ...
                 mag2db(abs( vf_resp2(i_frqrange )))) .* ...
             v_weight);


end



function bw = erb_bw(f)
% bw = erb_bw(f)
%
% Calculates ERB (Equivalent Rectangular Bandwidth) of an auditory filter
% depending on frequency f (Hz), according to the Formula
%
% ERB = 24.7 ( 4.37 F + 1 )
%
% where F is the frequency in kHz. From
% Glasberg, Brian R., and Brian CJ Moore. 
% "Derivation of auditory filter shapes from notched-noise data." 
% Hearing research 47.1 (1990): 103-138.
%
% Florian Denk, 16.06.2017


bw = 24.7 .* ( (0.00437 .* f) + 1 );
end
