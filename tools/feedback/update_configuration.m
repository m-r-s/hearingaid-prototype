#!/usr/bin/octave -q
close all
clear
clc

fs = 48000;

[signal, fs] = audioread('/tmp/feedback.wav');

assert(fs==48000);
signal = signal(1000:end-1000,:);
num_samples = size(signal,1);
  
max_samples = 20*48; % ~20 ms
max_range = 3*48; % ~3 ms
min_freq = fs./max_samples;

step_samples = round(0.1.*fs);
analysis_samples = round(0.5.*fs);
num_frames = floor((num_samples-analysis_samples)/step_samples);
fft_samples = 2.^nextpow2(2.*analysis_samples);

% Use only single precision
signal = single(signal);

% Unsegmented reference implementation 
signal_fft = fft(signal);
signal_fft(1:1+round(min_freq./fs.*size(signal,1)),3:4) = 0;
signal_fft(1+end-round(min_freq./fs.*size(signal,1)):end,3:4) = 0;
H = signal_fft(:,[3,4])./signal_fft(:,[1,2]);
feedback_ref = real(ifft(H));
feedback_ref_short = feedback_ref(1:max_samples,:);

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

% Function to calculate median of real and imaginary part independently
cmedian = @(x) median(real(x))+1i.*median(imag(x));
% Function to calculate the ifft of a reduced spectrum which belongs to a real function
real_ifft = @(x) real(ifft([x;conj(x(end-1:-1:2))]));

% Remove outliers and frequencies which dont "fit" into "max_range"
feedback_left_fft_median = cmedian(feedback_left_fft);
feedback_right_fft_median = cmedian(feedback_right_fft);
feedback_left_fft_median(1:1+round(min_freq./fs.*fft_samples)) = 0;
feedback_right_fft_median(1:1+round(min_freq./fs.*fft_samples)) = 0;
feedback_left_median = real_ifft(feedback_left_fft_median(:));
feedback_right_median = real_ifft(feedback_right_fft_median(:));
feedback_left_median_short = feedback_left_median(1:max_samples);
feedback_right_median_short = feedback_right_median(1:max_samples);

% A variant using the mean instead of the median values
feedback_left_fft_mean = mean(feedback_left_fft);
feedback_right_fft_mean = mean(feedback_right_fft);
feedback_left_fft_mean(1:1+round(min_freq./fs.*fft_samples)) = 0;
feedback_right_fft_mean(1:1+round(min_freq./fs.*fft_samples)) = 0;
feedback_left_mean = real_ifft(feedback_left_fft_mean(:));
feedback_right_mean = real_ifft(feedback_right_fft_mean(:));
feedback_left_mean = feedback_left_mean(1:max_samples);
feedback_right_mean = feedback_right_mean(1:max_samples);

figure;
subplot(2,1,1);
plot(feedback_ref_short(:,1),'k','LineWidth',2);
hold on;
plot(feedback_left_mean,'LineWidth',2);
plot(feedback_left_median_short,'LineWidth',2);
subplot(2,1,2);
plot(feedback_ref_short(:,2),'k','LineWidth',2);
hold on;
plot(feedback_right_mean,'LineWidth',2);
plot(feedback_right_median_short,'LineWidth',2);

% Function to dynamically select the window that covers the most energy
function range = selectmain(in,level)
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

level1 = 0;
while diff(selectmain(feedback_left_median_short,level1)) <= max_range
  level1 = level1 - 1;
end
level1 = level1 + 1;

level2 = 0;
while diff(selectmain(feedback_right_median_short,level2)) <= max_range
  level2 = level2 - 1;
end
level2 = level2 + 1;

feedback1 = single(feedback_left_median_short);
feedback2 = single(feedback_right_median_short);

range1 = int32(selectmain(feedback_left_median_short,level1)-1);
range2 = int32(selectmain(feedback_right_median_short,level2)-1);

% Write coefficients and ranges to files
fp = fopen('src/configuration/feedback1.bin','wb');
fwrite(fp,feedback1,'single');
fclose(fp);
fp = fopen('src/configuration/feedback2.bin','wb');
fwrite(fp,feedback2,'single');
fclose(fp);
fp = fopen('src/configuration/range1.bin','wb');
fwrite(fp,range1,'int32');
fclose(fp);
fp = fopen('src/configuration/range2.bin','wb');
fwrite(fp,range2,'int32');
fclose(fp);

[~, maxidx1] = max(abs(feedback1));
[~, maxidx2] = max(abs(feedback2));

printf("latency1 = %.2fms\nlatency2 = %.2fms\n",(maxidx1-1).*1000./fs,(maxidx1-1).*1000./fs);
printf("range1 = [%i %i]\nrange2 = [%i %i]\n",range1(1),range1(2),range2(1),range2(2));

printf('done\n');
