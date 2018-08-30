% Copyright 2018 Marc René Schädler
%
% This file is part of the mobile hearing aid prototype project
% The the mobile hearing aid prototype project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
%
% The mobile hearing aid prototype project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with the mobile hearing aid prototype project. If not, see http://www.gnu.org/licenses/.

function [feedback, range] = estimate_feedback(signal, fs, method)

if nargin < 3 || isempty(method)
  method = 'median';
end

signal = signal(1000:end-1000,:);
num_samples = size(signal,1);
max_samples = round(20.*fs./1000); % ~20 ms
max_range = round(3.*fs./1000); % ~3 ms
min_freq = fs./max_samples;

step_samples = round(0.1.*fs);
analysis_samples = round(0.5.*fs);
num_frames = floor((num_samples-analysis_samples)/step_samples);
fft_samples = 2.^nextpow2(2.*analysis_samples);

% Use only single precision
signal = single(signal);

% Function to calculate the ifft of a reduced spectrum which belongs to a real function
real_ifft = @(x) real(ifft([x;conj(x(end-1:-1:2))]));

if strcmp(method,'deconv')
  % Unsegmented reference implementation
  signal_fft = fft(signal);
  signal_fft(1:1+round(min_freq./fs.*size(signal,1)),3:4) = 0;
  signal_fft(1+end-round(min_freq./fs.*size(signal,1)):end,3:4) = 0;
  feedback = real(ifft(signal_fft(:,[3,4])./signal_fft(:,[1,2])));
  feedback_short = feedback_ref(1:max_samples,:);
else
  % Calculate feedback paths for each segment
  feedback_left_fft = zeros(num_frames,fft_samples./2+1,'single');
  feedback_right_fft = zeros(num_frames,fft_samples./2+1,'single');
  for i=1:num_frames
    start = 1+(i-1).*step_samples;
    stop = analysis_samples+(i-1).*step_samples;
    signal_fft = fft(signal(start:stop,:),fft_samples);
    feedback_left_fft(i,:) = signal_fft(1:end/2+1,3)./signal_fft(1:end/2+1,1);
    feedback_right_fft(i,:) = signal_fft(1:end/2+1,4)./signal_fft(1:end/2+1,2);
  end
end

switch(method)
  case 'median'
    % Function to calculate median of real and imaginary part independently
    cmedian = @(x) median(real(x))+1i.*median(imag(x));
    % Remove outliers and frequencies which dont "fit" into "max_range"
    feedback_left_fft_median = cmedian(feedback_left_fft);
    feedback_right_fft_median = cmedian(feedback_right_fft);
    feedback_left_fft_median(1:1+round(min_freq./fs.*fft_samples)) = 0;
    feedback_right_fft_median(1:1+round(min_freq./fs.*fft_samples)) = 0;
    feedback_left_median = real_ifft(feedback_left_fft_median(:));
    feedback_right_median = real_ifft(feedback_right_fft_median(:));
    feedback_left_median_short = feedback_left_median(1:max_samples);
    feedback_right_median_short = feedback_right_median(1:max_samples);
    feedback1 = single(feedback_left_median_short);
    feedback2 = single(feedback_right_median_short);
  case 'mean'
    % A variant using the mean instead of the median values
    feedback_left_fft_mean = mean(feedback_left_fft);
    feedback_right_fft_mean = mean(feedback_right_fft);
    feedback_left_fft_mean(1:1+round(min_freq./fs.*fft_samples)) = 0;
    feedback_right_fft_mean(1:1+round(min_freq./fs.*fft_samples)) = 0;
    feedback_left_mean = real_ifft(feedback_left_fft_mean(:));
    feedback_right_mean = real_ifft(feedback_right_fft_mean(:));
    feedback_left_mean_short = feedback_left_mean(1:max_samples);
    feedback_right_mean_short = feedback_right_mean(1:max_samples);
    feedback1 = single(feedback_left_mean_short);
    feedback2 = single(feedback_right_mean_short);
end

% Find level for first path
level1 = 0;
while diff(selectmain(feedback1,level1)) <= max_range
  level1 = level1 - 1;
end
level1 = level1 + 1;

% Find level for second path
level2 = 0;
while diff(selectmain(feedback2,level2)) <= max_range
  level2 = level2 - 1;
end
level2 = level2 + 1;

% Get corrsponding ranges ranges
range1 = selectmain(feedback1,level1)-1;
range2 = selectmain(feedback2,level2)-1;

feedback = [feedback1,feedback2];
range = [range1;range2];
end

function range = selectmain(in,level)
  % Dynamically select the window that covers the most energy

  min_level = 10.^(level/20);
  [~, maxidx] =  max(abs(in));
  start = find(abs(in)>min_level,1,'first');
  stop = find(abs(in)>min_level,1,'last');
  if isempty(start)
    start = maxidx;
  end
  if isempty(stop)
    stop = maxidx;
  end
  range = [start stop];
end
