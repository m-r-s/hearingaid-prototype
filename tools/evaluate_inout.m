#!/usr/bin/octave -q
close all
clear
clc


[signal, fs] = audioread('inout.wav');

analysis_length = 100; % ms

analysis_samples = floor(fs.*analysis_length./1000);
analysis_frames = size(signal,1)./analysis_samples;

level_in1 = zeros(analysis_frames,1);
level_in2 = zeros(analysis_frames,1);
level_out1 = zeros(analysis_frames,1);
level_out1 = zeros(analysis_frames,1);

freq_in1 = zeros(analysis_frames,1);
freq_in2 = zeros(analysis_frames,1);
freq_out1 = zeros(analysis_frames,1);
freq_out1 = zeros(analysis_frames,1);

analysis_window = hanning(analysis_samples);
analysis_window = analysis_window ./ sqrt(mean(analysis_window.^2));

for i=1:analysis_frames
  in1 = signal(1+(i-1).*analysis_samples:i.*analysis_samples,1) .* analysis_window;
  in2 = signal(1+(i-1).*analysis_samples:i.*analysis_samples,2) .* analysis_window;
  out1 = signal(1+(i-1).*analysis_samples:i.*analysis_samples,3) .* analysis_window;
  out2 = signal(1+(i-1).*analysis_samples:i.*analysis_samples,4) .* analysis_window;
  
  level_in1(i) = 10*log10(mean(in1.^2));
  level_in2(i) = 10*log10(mean(in2.^2));
  level_out1(i) = 10*log10(mean(out1.^2));
  level_out2(i) = 10*log10(mean(out2.^2));
 
  [~, maxidx_in1] = max(abs(fft(in1)));
  [~, maxidx_in2] = max(abs(fft(in2)));
  [~, maxidx_out1] = max(abs(fft(out1)));
  [~, maxidx_out2] = max(abs(fft(out2)));
  
  freq_in1(i) = (maxidx_in1-1)./analysis_samples.*fs;
  freq_in2(i) = (maxidx_in2-1)./analysis_samples.*fs;
  freq_out1(i) = (maxidx_out1-1)./analysis_samples.*fs;
  freq_out2(i) = (maxidx_out2-1)./analysis_samples.*fs;
end

freq_bins = logspace(log10(100),log10(20000),20);
freq_color = hsv(length(freq_bins)-1).*0.8;

figure('Position',[0 0 400 400],'Visible','on');
plot([0 0],[-90 10],'k');
hold on;
plot([-90 10],[0 0],'k');
plot([-90 10],[-90 10],'k');
plot([-90   0],[-80 10],'k--');
plot([-90 -10],[-70 10],'k--');
plot([-90 -20],[-60 10],'k--');
plot([-90 -30],[-50 10],'k--');
plot([-90 -40],[-40 10],'k--');
plot([-90 -50],[-30 10],'k--');
plot([-90 -60],[-20 10],'k--');
plot([-90 -70],[-10 10],'k--');


sample_levels = [-80 -60 -40 -20 0];
out1_mean = zeros(length(freq_bins)-1,length(sample_levels));

h = [];
for i=1:length(freq_bins)-1
  freq_mask = freq_in1 >= freq_bins(i) & freq_in1 < freq_bins(i+1);
  x = level_in1(freq_mask);
  y = level_out1(freq_mask);
  p = polyfit(x,y,3);
  c = freq_color(i,:);
  out1_mean(i,:) = polyval(p,sample_levels);
  
  scatter(x,y,20,c);
  if mod(i-1,2) == 0
    h(i) = plot(-90:10,polyval(p,-90:10),'Color',c);
  end
end
legend(h,num2str(round(freq_bins(1:2:end).')),'location','southeast');

xlim([-90 0]);
ylim([-80 10]);
xlabel('Input / dB FS');
ylabel('Output / dB FS');

set(gcf,'PaperUnits','inches','PaperPosition',[0 0 4 4].*1.4);
print('-depsc2','-r300','inout_functions.eps');


figure('Position',[0 0 400 400],'Visible','on');
plot(log([100 16000]),[0 0],'k');
hold on;

level_color = hsv(length(sample_levels)).*0.8;

h = [];
for i=1:length(sample_levels)
  c = level_color(i,:);
  plot(log(freq_bins(1:end-1)),sample_levels(i).*ones(length(freq_bins)-1,1),'--','Color',c);
  h(i) = plot(log(freq_bins(1:end-1)),out1_mean(:,i),'-','Color',c);
end

xlim(log([100 16000]));
ylim([-90 10]);
xlabel('Frequency / Hz');
ylabel('Levels / dB');
set(gca,'xtick',log(freq_bins(1:2:end-1)));
set(gca,'xticklabel',round(freq_bins(1:2:end-1)));
legend(h,num2str(sample_levels.'),'location','southeast');

set(gcf,'PaperUnits','inches','PaperPosition',[0 0 4 4].*1.4);
print('-depsc2','-r300','inout_gain.eps');
