#!/usr/bin/octave -q
close all
clear
clc

[signal, fs] = audioread('feedback.wav');
signal_fft = fft(signal);
H = signal_fft(:,[4,3])./signal_fft(:,[1,2]);
feedback = real(ifft(H));
max_samples = round(fs.*0.01);
max_amplitude = max(abs(feedback(:)));
feedback_fft = fft(feedback(1:max_samples,:));

figure('Position',[0 0 800 800],'Visible','on');
for i=1:2
  subplot(2,2,i);    
  plot((0:max_samples-1)./fs.*1000,feedback(1:max_samples,i),'k');
  xlim([0 10]);
  ylim([-1.1 1.1].*max_amplitude);
  xlabel('Latency / ms');
  ylabel('Amplitude');
  set(gca,'XTick',0:1:10);
  legend({sprintf('channel %i',i)});
end

audiowrite('feedback_impulseresponse.wav',feedback(1:max_samples,:),fs,'BitsPerSample',32);

for i=1:2
  subplot(2,2,i+2);
  plot(log(linspace(0,fs-1,length(feedback_fft))),20*log10(abs(feedback_fft(:,i))),'k');
  ylim([-80 0]);
  xlim(log([100 16000]));
  xlabel('Frequency / Hz');
  ylabel('Amplitude / dB');
  set(gca,'XTick',log([125 250 500 1000 2000 4000 8000 16000]));
  set(gca,'XTicklabel',[125 250 500 1000 2000 4000 8000 16000]);
  legend({sprintf('channel %i',i)});
end

set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 8].*1.4);
print('-depsc2','-r300','feedback.eps');
