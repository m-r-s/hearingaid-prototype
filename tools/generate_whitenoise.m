#!/usr/bin/octave -q

fs=48000; % Hz
duration = 20; % seconds
attenuation = 20; % dB FS

% Stereo signal with uncorrelated samples
signal_2ch = 10.^(-attenuation./20).*randn(round(duration.*fs),2);

% Write to 32bit sampled wav file
audiowrite('whitenoise_2ch.wav', signal_2ch, fs, 'BitsPerSample', 32);

