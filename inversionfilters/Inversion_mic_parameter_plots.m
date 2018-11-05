% Choice of parameters and plot illustration inversion of microphones

clc
clear 
close all

addpath ../tools

% Parameters:
N = [8 12 16 24 32];                        % Length of filter
D = linspace(0,10,11);                      % Delay
colors = hsv(length(D)).*0.8;               % Distribution of colours for delays

srate = 48000;                              % Sampling rate
f_min = 500;
f_max = 4000;

% NOTE: Inversionfilter and equalized impulse responses are not saved druing
% for loop
[max_error_mic, v_irsens_df, v_h, v_tot]  = Calculation_inversion_mic(N, D, srate, f_min, f_max);


%% Plot max_error of mean over impulse responses
figure
imagesc(mean(max_error_mic,3));colorbar
xlabel('Delay / samples'); set(gca ,'YTick' ,1:1:length(N),'YTickLabel' ,N )
ylabel('Length of filter')
title('Mean over all max\_error\_mic')


%% Plot max_error of worst impuls responses
figure
imagesc(max(max_error_mic,[],3));colorbar
xlabel('Delay / samples'); set(gca ,'YTick' ,1:1:length(N),'YTickLabel' ,N )
ylabel('Length of filter')
title('Maximum of all max\_error\_mic')


%% Plot max_error of mean + 2*std over impuls responses
figure
imagesc(mean(max_error_mic,3)+std(max_error_mic,[],3).*2);colorbar
xlabel('Delay / samples'); set(gca ,'YTick' ,1:1:length(N),'YTickLabel' ,N )
ylabel('Length of filter')
title('Mean + 2*Std of all max\_error\_mic')
