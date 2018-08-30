#!/usr/bin/octave
% Copyright 2018 Marc René Schädler
%
% This file is part of the mobile hearing aid prototype project
% The the mobile hearing aid prototype project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
%
% The mobile hearing aid prototype project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with the mobile hearing aid prototype project. If not, see http://www.gnu.org/licenses/.

close all;
clear;
clc;

fs = 48000;
reference_level = 111.4;
signal = randn(fs,1)-0.5;

signal_fft = fft(signal)./sqrt([1,1:(fs-1)]).';
signal_fft(1:200) = 0;
signal_fft(8000:end) = 0;

signal = real(ifft(signal_fft));

signal = signal./sqrt(mean(signal.^2));

signal50 = signal.*10.^((50-reference_level)./20);
signal65 = signal.*10.^((65-reference_level)./20);
signal80 = signal.*10.^((80-reference_level)./20);

testsound = [signal50; signal65; signal80];

testsound = repmat(testsound,10,2);

audiowrite('../recordings/testsound.wav',testsound,fs,'BitsPerSample',32);


