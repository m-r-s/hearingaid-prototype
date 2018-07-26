#!/usr/bin/octave -q
close all
clear
clc

fs0 = 48000;

feedback_files_dir = '/tmp/';

files = dir(fullfile(feedback_files_dir,'*.wav'));
filenames = sort({files(:).name});

num_files = length(filenames);
num_relocations = num_files-1;

[signal, fs] = audioread(fullfile(feedback_files_dir,filenames{1}));
assert(fs==fs0);

[feedback, range] = estimate_feedback(signal,fs,'median');

%% Figures for uncompensated feedback path
feedback_fft = fft(feedback);
max_amplitude = max(abs(feedback(:)));

figure('Position',[0 0 600 600],'Visible','on');
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 6 6].*1.4);
for i=1:2
  subplot(2,2,i);
  [fb_max_amp, fb_max_timeidx] = max(abs(feedback(:,i)));
  h = plot((0:length(feedback(:,i))-1)./fs.*1000,feedback(:,i)./max_amplitude,'color',[1 1 1].*0.67);
  hold on;
  plot(((range(i,1):range(i,2))-1)./fs.*1000,feedback(range(i,1):range(i,2),i)./max_amplitude,'k');
  text((fb_max_timeidx-1)./fs.*1000,-1,sprintf('%.1fms',(fb_max_timeidx-1)./fs.*1000),'HorizontalAlignment','center', 'VerticalAlignment', 'bottom');
  xlim([0 10]);
  ylim([-1.2 1.2]);
  xlabel('Latency / ms');
  ylabel(sprintf('Amplitude / *%.3E',max_amplitude));
  set(gca,'XTick',0:1:10);
  legend(h,{sprintf('channel %i',i)});
end
for i=1:2
  subplot(2,2,i+2);
  spectrum = 20*log10(abs(feedback_fft(:,i)));
  [fb_max_gain, fb_max_freqidx] = max(spectrum);
  freqs = linspace(0,fs-1,length(spectrum));
  h = plot(log(freqs),spectrum,'k');
  hold on;
  text(log(freqs(fb_max_freqidx)),fb_max_gain,sprintf('%.1fdB @ %.0fHz',fb_max_gain,freqs(fb_max_freqidx)),'HorizontalAlignment','center', 'VerticalAlignment', 'bottom');
  ylim([-80 0]);
  xlim(log([100 16000]));
  xlabel('Frequency / Hz');
  ylabel('Amplitude / dB');
  set(gca,'XTick',log([125 250 500 1000 2000 4000 8000 16000]));
  set(gca,'XTicklabel',[125 250 500 1000 2000 4000 8000 16000]);
  legend(h,{sprintf('channel %i',i)});
end

%% Figures for re-measured feedback paths
for i=1:num_relocations
  [signal, fs] = audioread(fullfile(feedback_files_dir,filenames{1+i}));
  [feedback, range] = estimate_feedback(signal,fs,'median');
  feedback_fft = fft(feedback);
  assert(fs==fs0);
  for i=1:2
    subplot(2,2,i);
    [fb_max_amp, fb_max_timeidx] = max(abs(feedback(:,i)));
    h = plot((0:length(feedback(:,i))-1)./fs.*1000,feedback(:,i)./max_amplitude,'color',[1 0 0].*0.67);
  end
  for i=1:2
    subplot(2,2,i+2);
    spectrum = 20*log10(abs(feedback_fft(:,i)));
    [fb_max_gain, fb_max_freqidx] = max(spectrum);
    freqs = linspace(0,fs-1,length(spectrum));
    h = plot(log(freqs),spectrum,'color',[1 0 0].*0.67);
  end
  drawnow;
end

print('-depsc2','-r300','feedback.eps');


