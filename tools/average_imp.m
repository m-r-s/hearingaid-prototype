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

function v_imp = average_imp (M_imp, dim, s_method)
% v_imp = average_imp (M_imp, dim, s_method)
%
% performs robust averaging over impulse responses (or signals), 
% by seperately averaging magintude and unwrapped phase along the dimension
% dim in the array M_resp
% s_method sets modalities. 
%   Options: 'mean': Arithmetic average of amplitude and unwrapped phase
%                    separately
%            'median': Median of amplitude and unwrapped phase separately
%            'mean_dBmag': Averaging the magnitude in the dB regime,
%                          arithmetic averaging of phase values
%
% See also: AVERAGE_RESP()
%
% Author: Florian Denk, 
% September 2016

if nargin < 3
   error('Not enough input arguments')
end

M_resp = fftR(M_imp);

v_resp = average_resp(M_resp,dim,s_method);

v_imp = ifftR(v_resp);
end