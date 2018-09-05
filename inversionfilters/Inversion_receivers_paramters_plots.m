% Choice of parameters plus plots concering error due to inversion of receivers

clc
clear
close all

% Parameters:
N = 2.^(4:9);                          % Length of filter
D = (2:2:15);                          % Delays
colors = hsv(length(D)).*0.8;   
mu = 2.^(-10:0);
 

srate = 44100;
f_min = 500;
f_max = 4000;
N_fft = 8128;

[max_error_receiv, mean_error_receiv] = Calculation_inversion_receiver(N ,D, mu, srate, f_min, f_max, N_fft);


%% Plots
% NOTE: There is a various amount of measurements of impuls responses for
% the different receivers. This has to been taken into account for the
% accumulation of the meanvalues


%% Plot max_error for mean over impuls responses                              
figure("name","max\_error for mean over impuls responses")
clear mean
mean = mean(max_error_receiv,4);
for t = 1:length(mu)
    subplot(4,3,t)
    imagesc(mean(:,:,t));colorbar
    set(gca,'XTickLabel',D)
    xlabel('Delay / samples');
    set(gca,'YTick',[1:1:length(N)], 'YTickLabel',N)
    ylabel('Length of filter')
    title(['mu =' num2str(mu(t))])
end



%% Plot mean_error for mean over impuls responses
figure("name","mean\_error for mean over impuls responses")
clear mean
mean = mean(mean_error_receiv,4);
for t = 1:length(mu)
    subplot(4,3,t)
    imagesc(mean(:,:,t));colorbar
    set(gca,'XTickLabel',D)
    xlabel('Delay / samples');
    set(gca,'YTick',[1:1:length(N)], 'YTickLabel',N)
    ylabel('Length of filter')
    title(['mu =' num2str(mu(t))])
end
