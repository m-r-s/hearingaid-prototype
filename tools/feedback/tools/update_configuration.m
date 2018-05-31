#!/usr/bin/octave -q
close all
clear
clc

[signal, fs] = audioread('/tmp/feedback.wav');
assert(fs==48000);
signal = signal(1000:end-1000,:);

max_samples = 20*48;
max_range = 2*48;
min_freq = fs./max_samples;

signal_fft = fft(signal);
% Remove frequencies with periods that dont fit once in the window
signal_fft(1:1+round(min_freq./fs.*size(signal,1)),3:4) = 0;
signal_fft(1+end-round(min_freq./fs.*size(signal,1)):end,3:4) = 0;
H = signal_fft(:,[3,4])./signal_fft(:,[1,2]);
feedback = real(ifft(H));
feedback_short = feedback(1:max_samples,:);
feedback_fft = fft(feedback_short);

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
while diff(selectmain(feedback_short(:,1),level1)) <= max_range
  level1 = level1 - 1;
end
level1 = level1 + 1;

level2 = 0;
while diff(selectmain(feedback_short(:,2),level2)) <= max_range
  level2 = level2 - 1;
end
level2 = level2 + 1;

feedback1 = single(feedback_short(:,1));
feedback2 = single(feedback_short(:,2));

range1 = int32(selectmain(feedback_short(:,1),level1)-1);
range2 = int32(selectmain(feedback_short(:,2),level2)-1);

% Write coefficients and ranges to files
fp = fopen('../src/configuration/feedback1.bin','wb');
fwrite(fp,feedback1,'single');
fclose(fp);
fp = fopen('../src/configuration/feedback2.bin','wb');
fwrite(fp,feedback2,'single');
fclose(fp);
fp = fopen('../src/configuration/range1.bin','wb');
fwrite(fp,range1,'int32');
fclose(fp);
fp = fopen('../src/configuration/range2.bin','wb');
fwrite(fp,range2,'int32');
fclose(fp);

[~, maxidx1] = max(abs(feedback1));
[~, maxidx2] = max(abs(feedback2));

printf("latency1 = %.2fms\nlatency2 = %.2fms\n",(maxidx1-1).*1000./fs,(maxidx1-1).*1000./fs);
printf("range1 = [%i %i]\nrange2 = [%i %i]\n",range1(1),range1(2),range2(1),range2(2));

printf('done\n');
