% This script can be used to calculate the coefficients for the 
% input compensation filter which is used by openMHA
%
% Authors: Florian Denk, Max Bodenstein, Marc René Schädler
%

clc
clear 
close all

addpath ../tools

% Considered lengths of filters in samples
N = [4 6 8 12 16 24 32 48 64];
% Considered delays relative to the to-be-inverted impulse response in samples
D = -4:20;
% Regularization parameter
mu = [1 0.5 0.25 0.1 0.05 0.02 0.01 0.005 0.002];
% Target sample frequency
fs = 48000;

% Use the following parameters
N_select = 16;
D_select = 0;
mu_select = 0.25;

% Calculate inversion filters for the given parameters
[inversion_filters, average_deviations, weighted_average_deviation]  = calc_inversion_mic(N, D, mu, fs);
inversion_filter = inversion_filters{N==N_select,D==D_select,mu==mu_select};
average_deviation = average_deviations{N==N_select,D==D_select,mu==mu_select};

%% Plot average weighted deviation
figure;
colormap('jet');
range = min(weighted_average_deviation(:)) + [0 0.5];
num_plots = ceil(sqrt(size(weighted_average_deviation,3)));
for i=1:size(weighted_average_deviation,3)
  subplot(num_plots,num_plots,i);
  imagesc(weighted_average_deviation(:,:,i),range);
  title(sprintf('mu = %.8f',mu(i)));
  hold on;
  colorbar
  xticks(1:2:length(D));
  xticklabels(D(1:2:end));
  xlabel('Delay / samples');
  yticks(1:1:length(N))
  yticklabels(N);
  ylabel('filter duration / samples')
  if mu(i) == mu_select
    scatter(find(D==D_select),find(N==N_select),50,'k','x');  
  end
end

% Average deviation
figure;
plot(log([50 20000]),[0 0],'k','linewidth',2);
title(sprintf('Average deviation for selected parameters (N=%i,D=%i,mu=%.5f)',N_select,D_select,mu_select));
grid on;
hold on;
plot(log([1:size(average_deviation,1)-1]./size(average_deviation,1).*fs),average_deviation(2:end,:),'linewidth',2);
xticks(log(1000.*2.^(-4:4)));
xlim(log([50 20000]));
xticklabels(1000.*2.^(-4:4));
yticks(-10:10);
ylim([-10 10]);
xlabel('Frequency / Hz');
ylabel('Deviation / dB');


% Compare to reference coefficients
figure;
reference = [0.05715807311106352 -0.09143269871454363 0.1279991931078954 -0.1229917176472585 0.03865469459901275 0.1208478993167953 -0.8820088913999001 -0.2804647683673479 0.01220373264309236 -0.1613181711981604 0.1851746406520001 -0.1149274499260817 0.04848940622236251 0.03877744359967165 -0.0533381761233464 0.06159030633073432]; 
plot(log(1:fs-1),20*log10(abs(fft(reference,fs)(:,2:end))),'k','linewidth',2);
title('Comparison with reference filter (e.g., currently used coefficients)');
grid on;
hold on;
plot(log(1:fs-1),20*log10(abs(fft(inversion_filter,fs)(2:end,:))),'r','linewidth',2);
legend({'reference',sprintf('new (N=%i,D=%i,mu=%.5f)',N_select,D_select,mu_select)});
xticks(log(1000.*2.^(-4:4)));
xlim(log([50 20000]));
xticklabels(1000.*2.^(-4:4));
yticks(-10:10);
ylim([-10 10]);
xlabel('Frequency / Hz');
ylabel('Gain / dB');

% Print new filter coefficients
printf('START FILTER COEFFICIENTS\n');
printf('%.15f ',inversion_filter);
printf('\nEND FILTER COEFFICIENTS\n');
