% Copyright 2018 Marc René Schädler
%
% This file is part of the mobile hearing aid prototype project
% The the mobile hearing aid prototype project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
%
% The mobile hearing aid prototype project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with the mobile hearing aid prototype project. If not, see http://www.gnu.org/licenses/.

function signal = sinesweepphase(samples, frequency, phase)
%usage: signal = sinesweepphase(samples, frequency, phase)
%
% samples          - number of samples
% frequency        - normalized frequencies [0..1]
% phase            - phase [0..2*pi]

phase_diff_start = 2.*pi.*frequency(1);
phase_diff_stop = 2.*pi.*frequency(2);

phase_diff = logspace(log10(phase_diff_start),log10(phase_diff_stop),samples);

if nargin >= 4
  phase_diff(1) = phase_diff(1) + phase;
end

signal = sin(cumsum(phase_diff)).';
end

