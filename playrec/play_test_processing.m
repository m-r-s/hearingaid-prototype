close all
clear
clc

graphics_toolkit qt

clear overlapadd
clear compress


fs = 48000;
tone = sin(2*pi*linspace(0,1000,fs)).';
toneamp = tone.*10.^(linspace(-97,3,fs).'./20);

in = [tone toneamp];
out = zeros(size(in));

M = 128;
N = 256;
FFTN = 512;

tic
process([], fs, M, N, FFTN);
toc

profile off;
profile clear;
profile on;
for i=1:M:size(in,1)
  in_tmp = in((i:i+M-1),:);
  tic;
  out_tmp = process(in_tmp);
  printf('%.3f\n',toc./(M/fs));
  out(i:(i+M-1),:) = out_tmp;
end
profile off;

figure;
subplot(2,2,1);
plot(in(:,1));
subplot(2,2,2);
plot(in(:,2));
subplot(2,2,3);
plot(out(:,1));
subplot(2,2,4);
plot(out(:,2));

