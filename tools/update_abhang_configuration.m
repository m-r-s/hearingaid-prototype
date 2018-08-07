#!/usr/bin/octave -q
close all
clear
clc

fs = 48000;

[signal, fs] = audioread('/dev/shm/feedback.wav');
assert(fs==48000);

[feedback, range] = estimate_feedback(signal, fs);

feedback1 = feedback(:,1);
feedback2 = feedback(:,2);
range1 = range(1,:);
range2 = range(2,:);

% Write coefficients and ranges to files
fp = fopen('abhang/src/configuration/feedback1.bin','wb');
fwrite(fp,single(feedback1),'single');
fclose(fp);
fp = fopen('abhang/src/configuration/feedback2.bin','wb');
fwrite(fp,single(feedback2),'single');
fclose(fp);
fp = fopen('abhang/src/configuration/range1.bin','wb');
fwrite(fp,int32(range1),'int32');
fclose(fp);
fp = fopen('abhang/src/configuration/range2.bin','wb');
fwrite(fp,int32(range2),'int32');
fclose(fp);

[~, maxidx1] = max(abs(feedback1));
[~, maxidx2] = max(abs(feedback2));
latency1 = (maxidx1-1).*1000./fs;
latency2 = (maxidx2-1).*1000./fs;

printf("latency1 = %.2fms\nlatency2 = %.2fms\n",latency1,latency2);
printf("range1 = [%i %i]\nrange2 = [%i %i]\n",range1(1),range1(2),range2(1),range2(2));

