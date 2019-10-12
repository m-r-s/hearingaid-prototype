close all
clear
clc

graphics_toolkit qt

clear overlapadd
clear compress


fs = 48000;
sweep = real(exp(1i*2*pi*cumsum(linspace(10/fs,10000/fs,fs)))).';
tone = sin(2*pi*linspace(0,1000,fs)).';
noise = randn(fs,1);
clicks = zeros(fs,1);
clicks(1:100:fs) = 10.^(linspace(0,130,480)./20);

in = [tone tone];
out = zeros(size(in));

N = 192;
FFTN = 256;
M = N/4;
calibration = 100 - 10*log10(FFTN*M/2);

cfreqs = [75 125 250 500 1000 2000 4000 8000 16000]./fs;
gaintablecomp = linspace(99,0,100).' .* ones(1,length(cfreqs)-2);
gaintablenone = zeros(100,length(cfreqs)-2);
gaintablezero = -inf(100,length(cfreqs)-2);
gaintable = [gaintablecomp gaintablecomp];

tic
overlapadd(zeros(M,2),N,2);
compress(zeros(N,2), FFTN, cfreqs, gaintable, calibration);
toc

profile clear;

for i=1:M:size(in,1)
  in_tmp = in((i:i+M-1),:);
  tic;
  out_tmp = overlapadd(in_tmp);
  printf('%.3f\n',toc./(M/fs));
  out(i:(i+M-1),:) = out_tmp;
end

figure;
subplot(2,2,1);
plot(in(:,1));
subplot(2,2,2);
plot(in(:,2));
subplot(2,2,3);
plot(out(:,1));
subplot(2,2,4);
plot(out(:,2));

