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

function [v_h, v_tot] = kn_inversion(v_c, N, D, v_b, beta, v_a)
% [v_h, v_tot] = kn_inversion(v_c, N, D, v_b, beta, v_a)
%
% Regularized Inversion of an impulse response v_c, computes FIR inversion
% filter v_h. Implementation of
% Ole Krikby & Philip Nelson (1999):Digital Filter Design for Inversion
% Problems in Sound Reproduction, JAES 47(7/8)
%
%
% Inputs: 
%   v_c:  Impulse Response to be inverted
%   N:    Length of inversion filter
%   D:    Delay for target Delta-Impulse (latency of equalized impulse
%         response in samples)
%   v_b:  Impulse Response describing the regularization filter
%   beta: Regularization weight
%   v_a: (optional): impulse response describing target. It should be
%   minimum phase, since delay D is applied inside the function
%
% Output:
%   v_h   : Inversion Filter
%   v_tot : Equalized impulse response (convolution of v_h and v_c)
%
% Author:
% Florian Denk, Dept. Medical Physics and Acoustics, Uni Oldenburg
% 20.04.2018


% Notation of variables is according to paper

%% Input Parsing

% Data types
assert(isvector(v_c), 'v_c must be a vector');
assert(isvector(v_b), 'v_b must be a vector');
if exist('v_a', 'var')
    assert(isvector(v_a), 'v_a must be a vector');
end
assert(isscalar(N) && (floor(N)==N), 'N must be a scalar integer')
assert(isscalar(D) && (floor(D)==D), 'D must be a scalar integer')
assert(isnumeric(beta) && isscalar(beta), 'beta must be a scalar numeric')

% make sure all vectors are column vectors
v_c = v_c(:);
v_b = v_b(:);
if exist('v_a', 'var')
    v_a = v_a(:);
end

% Total length of equalized impulse response
N_tot = N + size(v_c, 1) -1;

% Make sure dimensions are compatible
if exist('v_a', 'var')
    assert(D + size(v_a, 1) <= N_tot, 'v_a is too long with given delay');
end

%% Calculations


% Target signal
if nargin < 6
   % Write 
   v_a = zeros(N_tot, 1);
   v_a(D+1) = 1;
else
   v_a = [zeros(D,1);v_a]; % Append delay
   if size(v_a, 1) < N_tot
       v_a = [v_a;zeros(N_tot - size(v_a, 1), 1)];
   else
       warning('v_target is too long and was truncated')
       v_a = ir_cutandfade(v_a, 1, N_tot, 0, 4);
   end
end


% Write Convolution matrices
M_C = convmtx(v_c(:), N); % Eq. (2), Acoustic input
M_B = convmtx(v_b(:), N); % Eq. (8), Regularization filter


% Solve for h, Eq (9)
v_h = ( (M_C.') * M_C + beta * (M_B.') * M_B) \ M_C.' * v_a;


% if desired: compute equalized impulse response
if nargin > 1
    v_tot = conv(v_c, v_h);
end