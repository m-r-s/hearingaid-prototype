#!/usr/bin/octave -q
close all
clear
clc

[signal, fs] = audioread('inout.wav');

analysis_length = 100; % ms

analysis_samples = floor(fs.*analysis_length./1000);
analysis_frames = size(signal,1)./analysis_samples;

level_in = -inf*ones(analysis_frames,2);
level_out = -inf*ones(analysis_frames,2);

freq_in = zeros(analysis_frames,2);
freq_out = zeros(analysis_frames,2);

analysis_window = hanning(analysis_samples);
analysis_window = analysis_window ./ sqrt(mean(analysis_window.^2));


for i=1:analysis_frames
  in1 = signal(1+(i-1).*analysis_samples:i.*analysis_samples,1) .* analysis_window;
  in2 = signal(1+(i-1).*analysis_samples:i.*analysis_samples,2) .* analysis_window;
  out1 = signal(1+(i-1).*analysis_samples:i.*analysis_samples,3) .* analysis_window;
  out2 = signal(1+(i-1).*analysis_samples:i.*analysis_samples,4) .* analysis_window;
  
  level_in(i,1) = 10*log10(mean(in1.^2));
  level_in(i,2) = 10*log10(mean(in2.^2));
  level_out(i,1) = 10*log10(mean(out1.^2));
  level_out(i,2) = 10*log10(mean(out2.^2));
 
  [~, maxidx_in1] = max(abs(fft(in1)));
  [~, maxidx_in2] = max(abs(fft(in2)));
  [~, maxidx_out1] = max(abs(fft(out1)));
  [~, maxidx_out2] = max(abs(fft(out2)));
  
  freq_in(i,1) = (maxidx_in1-1)./analysis_samples.*fs;
  freq_in(i,2) = (maxidx_in2-1)./analysis_samples.*fs;
  freq_out(i,1) = (maxidx_out1-1)./analysis_samples.*fs;
  freq_out(i,2) = (maxidx_out2-1)./analysis_samples.*fs;
end

freq_bins = logspace(log10(88.4),log10(16000),16);
freq_color = hsv(length(freq_bins)).*0.8;

figure('Position',[0 0 800 800],'Visible','on');
sample_levels = [-80 -60 -40 -20 0];

for i=1:2
  subplot(2,2,i);
  plot([0 0],[-100 10],'k');
  hold on;
  plot([-100  10],[  0   0],'k');
  plot([-100  10],[-100 10],'k');
  plot([-100 -10],[ -80 10],'k--');
  plot([-100 -30],[ -60 10],'k--');
  plot([-100 -50],[ -40 10],'k--');
  plot([-100 -70],[ -20 10],'k--');
  plot([-100 -90],[   0 10],'k--');
  
  out_mean = nan(length(freq_bins),length(sample_levels));

  h = [];
  for j=1:length(freq_bins)
    if j == 1
      freq_mask = freq_in(:,i) >= freq_bins(j)  & freq_in(:,i) < freq_bins(j+1);
    elseif j==length(freq_bins)
      freq_mask = freq_in(:,i) >= freq_bins(j-1) & freq_in(:,i) < freq_bins(j);
    else
      freq_mask = freq_in(:,i) >= freq_bins(j-1) & freq_in(:,i) < freq_bins(j+1);
    end
    x = level_in(freq_mask,i);
    y = level_out(freq_mask,i);
    validmask = x > -100 & y > -100 & ~isnan(x) & ~isnan(y) & ~isinf(x) & ~isinf(y);
    x = x(validmask);
    y = y(validmask);
    c = freq_color(j,:);
    if length(x) > 6
      p = polyfit(x,y,4);
      out_mean(j,:) = polyval(p,sample_levels);
    end
    scatter(x,y,20,c);
    if mod(j-1,2) == 0
      h(j) = plot(-90:10,polyval(p,-90:10),'Color',c);
    end
  end
  legend(h,num2str(round(freq_bins(2:2:end).')),'location','southeast');

  xlim([-100 10]);
  ylim([-100 10]);
  xlabel('Input / dB FS');
  ylabel('Output / dB FS');

  subplot(2,2,i+2);

  plot(log([50 16000]),[0 0],'k');
  hold on;

  level_color = hsv(length(sample_levels)).*0.8;

  h = [];
  for j=1:length(sample_levels)
    c = level_color(j,:);
    plot(log(freq_bins(1:end-1)),sample_levels(j).*ones(length(freq_bins)-1,1),'--','Color',c);
    h(j) = plot(log(freq_bins),out_mean(:,j),'-','Color',c);
  end

  xlim(log([50 16000]));
  ylim([-100 10]);
  xlabel('Frequency / Hz');
  ylabel('Levels / dB');
  set(gca,'xtick',log(freq_bins(2:2:end-1)));
  set(gca,'xticklabel',round(freq_bins(2:2:end-1)));
  legend(h,num2str(sample_levels.'),'location','southeast');
end

set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 8].*1.4);
print('-depsc2','-r300','inout.eps');
