% This software comes free with the hope that it is useful, but without any
% warranty. 
% It is published under the terms of the GNU General Public
% License v3.0. You are free to use, modify and redistribute the code,
% provided the original source is attributed and further distribution is
% made under the same license.
%
%% Copyright (c) Florian Denk, 2018
% Email: florian.denk@uni-oldenburg.de
% Department of Medical Physics and Acoustics, University of Oldenburg
%%
function v_resp_mean = average_resp (M_resp, dim, s_method)
% v_resp = average_resp (M_resp, dim, s_method)
%
% performs robust averaging over frequency responses (or spectra), 
% by seperately averaging magintude and unwrapped phase along the dimension
% dim in the array M_resp
% s_method sets modalities. 
%   Options: 'mean': Arithmetic average of amplitude and unwrapped phase
%                    separately
%            'median': Median of amplitude and unwrapped phase separately
%            'mean_dBmag': Averaging the magnitude in the dB regime,
%                          arithmetic averaging of phase values
%
% See Also: AVERAGE_IMP()
%
% Author: Florian Denk, 
% September 2016

% 16.06.17: Included mag-dB averaging

if nargin < 3
    error('Not enough input arguments')
end

switch lower(s_method)
    case 'mean'
        v_resp_mean =         mean(         abs(M_resp) ,dim)    .* exp(1i .* mean(   unwrap(angle(M_resp)),dim) );
    case 'mean_dbmag'
        v_resp_mean = db2mag( mean( mag2db( abs(M_resp)),dim))   .* exp(1i .* mean(   unwrap(angle(M_resp)),dim) );
    case 'median'
        v_resp_mean =         median(       abs(M_resp) ,dim)    .* exp(1i .* median( unwrap(angle(M_resp)),dim) );
    otherwise
        error('Invalid averaging method specified')
end