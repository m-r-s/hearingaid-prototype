#!/usr/bin/octave

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


