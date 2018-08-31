#!/usr/bin/octave -q
% Copyright 2018 Marc René Schädler
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

