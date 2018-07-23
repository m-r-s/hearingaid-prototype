#!/usr/bin/octave -q

fs = 48000; % Hz
duration = 2; % seconds
levels = [-80 -70 -60 -50 -40 -30 -20 -10 -0.1]; % dB FS

freq_start = 50; % Hz
freq_stop = 20000; % Hz

phase_diff_start = 2.*pi.*freq_start./fs;
phase_diff_stop = 2.*pi.*freq_stop./fs;

phase = cumsum(logspace(log10(phase_diff_start), log10(phase_diff_stop), round(fs.*duration)));

win_samples = 2.*round(0.5*fs*0.01);
win = hanning(win_samples).';
win_fadein = win(1:end/2);
win_fadeout = win(end/2+1:end);

% Stereo signal with identical samples
signal_2ch = zeros(round(2.*fs)+round(length(phase)+0.1.*fs).*length(levels),2);

write_pointer = round(2.*fs);
for i=1:length(levels)
   signal_tmp = 10.^(levels(i)./20).*sin(phase);
   signal_tmp(1:length(win_fadein)) = signal_tmp(1:length(win_fadein)) .* win_fadein;
   signal_tmp(end-length(win_fadeout)+1:end) = signal_tmp(end-length(win_fadeout)+1:end) .* win_fadeout;
   signal_2ch(write_pointer+1:write_pointer+length(signal_tmp),1) = signal_tmp;
   signal_2ch(write_pointer+1:write_pointer+length(signal_tmp),2) = signal_tmp;
  write_pointer = write_pointer + length(signal_tmp) + round(0.1*fs);
end

% Write to 32bit sampled wav file
audiowrite('sinesweeps_2ch.wav', signal_2ch, fs, 'BitsPerSample', 32);

