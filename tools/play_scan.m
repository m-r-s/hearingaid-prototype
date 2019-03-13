#!/usr/bin/octave
% Copyright 2019 Marc René Schädler
%
% This file is part of the mobile hearing aid prototype project
% The the mobile hearing aid prototype project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
%
% The mobile hearing aid prototype project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with the mobile hearing aid prototype project. If not, see http://www.gnu.org/licenses/.

close all
clear
clc

path = './';

% Calibration
calib_level = 0;
calib_fir = [1];

% File list
files = dir([path '*.wav']);

% Plot percentiles
figure;
N = ceil(sqrt(length(files)));
for i=1:length(files)
  subplot(N,N,i);
  [signal, fs] = audioread([path ,files(i).name]);
  signal = filter(calib_fir.*10.^(calib_level./20),1,signal);
  if length(signal) > fs
    [log_melspec_left, freqs] = log_mel_spectrogram(signal(:,1),fs);
    [log_melspec_right, freqs] = log_mel_spectrogram(signal(:,2),fs);
    values_left = prctile(log_melspec_left,[0 5 50 95 100],2);
    values_right = prctile(log_melspec_right,[0 5 50 95 100],2);
    plot(log(freqs),values_left,'r');
    hold on;
    plot(log(freqs),values_right,'b');
    xticks(log(freqs(1:10:end)));
    xticklabels(round(freqs(1:10:end)));
    xlabel(files(i).name);
    ylim([0 130]);
    max_level = max(0,max(max(values_left(:,5)),max(values_right(:,5))));
    median_level = max(0,max(max(values_left(:,3)),max(values_right(:,3))));
    min_level = max(0,max(max(values_left(:,2)),max(values_right(:,2))));
    printf('%s : %.0f %.0f %.0f\n',files(i).name,max_level,median_level,min_level);
  end
  filename = sprintf('%.0f-%.0f-%.0f_%s',max_level,median_level,min_level,files(i).name);
  audiowrite(['tmp_' filename],signal./100,fs,'BitsPerSample',32);
  system(['ffmpeg -i "' ['tmp_' filename] '" -af "volume=100" -acodec pcm_f32le "' filename '"']);
  unlink(['tmp_' filename]);
  drawnow;
end
