% This script can be used to calculate the coefficients for the 
% outpu compensation filter which is used by openMHA
%
% Copyright 2018 Florian Denk, Max Bodenstein, Marc René Schädler
%
% This file is part of the mobile hearing aid prototype project
% The the mobile hearing aid prototype project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
%
% The mobile hearing aid prototype project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with the mobile hearing aid prototype project. If not, see http://www.gnu.org/licenses/.

clc
clear 
close all

addpath ../tools

% Considered lengths of filters in samples
N = [8 12 16 24 32 48 64 96];
% Considered delays relative to the to-be-inverted impulse response in samples
D = -4:20;
% Regularization parameter
mu = [1 0.5 0.25 0.1 0.05 0.02 0.01 0.005 0.002];
% Target sample frequency
fs = 48000;

% Use the following parameters
N_select = 64;
D_select = 0;
mu_select = 0.01;

% Calculate inversion filters for the given parameters
[inversion_filters, average_deviations, weighted_average_deviation]  = calc_inversion_rec(N, D, mu, fs);
inversion_filter = inversion_filters{N==N_select,D==D_select,mu==mu_select};
average_deviation = average_deviations{N==N_select,D==D_select,mu==mu_select};

%% Plot average weighted deviation
figure;
colormap('jet');
range = min(weighted_average_deviation(:)) + [0 5];
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
reference = [-0.0008493245925390666 0.212079412419309 -0.2154042301549152 -0.3025302897591955 0.199775619155252 -0.1870229266228919 -0.7938470989741924 0.8603675948896129 0.478909142449632 -0.6085003614478869 0.07361724294587288 -0.2227288472200418 0.5368590771510556 0.09111033102709504 -0.480841985504344 0.4390128813205694 0.1246445045880798 0.1269349882268854 -0.04198884835603302 -0.2353992092127431 0.2510197443337887 0.0874549322159773 -0.02924594207986645 0.03500546824173258 0.02306546293053465 0.02935658669200722 -0.04983617327855945 0.01127518725520369 -0.03557732411817455 -0.08252133997595766 0.09626162395832474 -0.03965187059451832 -0.02978787895722923 -0.02032215684247022 -0.07226667524292203 0.1197853714014079 -0.07509868745444499 -0.06716864521583707 0.01498418308780167 -0.0128555683058882 0.005643946502094473 -0.05468486125562624 -0.03084551017547309 0.01713430717627588 -0.04031926622896171 -0.0001434979760821464 -0.02137092800354339 -0.02993680876827081]; 
plot(log(1:fs-1),20*log10(abs(fft(reference,fs)(:,2:end))),'k','linewidth',2);
title('Comparison with reference filter (e.g., currently used coefficients)');
grid on;
hold on;
plot(log(1:fs-1),20*log10(abs(fft(inversion_filter,fs)(2:end,:))),'r','linewidth',2);
legend({sprintf('reference %i samples',length(reference)),sprintf('new (N=%i,D=%i,mu=%.5f)',N_select,D_select,mu_select)});
xticks(log(1000.*2.^(-4:4)));
xlim(log([50 20000]));
xticklabels(1000.*2.^(-4:4));
yticks(-30:3:30);
ylim([-30 30]);
xlabel('Frequency / Hz');
ylabel('Gain / dB');

% Print new filter coefficients
printf('START FILTER COEFFICIENTS\n');
printf('%.15f\n',inversion_filter);
printf('END FILTER COEFFICIENTS\n');

