#!/usr/bin/octave -q
close all
clear
clc

%graphics_toolkit qt;

fs = 48000;

addpath('playrec');

pagesize = 128;
pagebufferlength = 2;

if playrec('isInitialised')
  playrec('reset')
  sleep(0.1);
end

if ~playrec('isInitialised')
  playrec('init', fs, 0, 0, 2, 2);
  pause(0.1);
end

in = zeros(pagesize,2);
out = zeros(pagesize,2);

assert(playrec('isInitialised'));

if playrec('pause')
  playrec('pause', 0);
end

playrec('delPage');

%figure;
%h = imagesc(zeros(2,pagesize));

pagelist = zeros(pagebufferlength,1);
for i=1:pagebufferlength
  pagelist(i) = playrec('playrec',out,[1 2],pagesize,[1 2]);
end

pagebufferidx = 1;
while true;
  playrec('block', pagelist(pagebufferidx));
  tic;
  in = playrec('getRec', pagelist(pagebufferidx));
  playrec('delPage', pagelist(pagebufferidx));
%  in_fft = fft(in);
%  in_fft2 = in_fft.*conj(in_fft);
  out = process(in);
  pagelist(pagebufferidx) = playrec('playrec',out,[1 2],pagesize,[1 2]);
%  set(h,'cdata',in.');
%  drawnow;
  pagebufferidx = pagebufferidx + 1;
  if pagebufferidx > pagebufferlength
    pagebufferidx = 1;
  end
  printf('rtf=%.3f\n',toc/(pagesize/fs));
end
