%  (Error-) Calculation inversion RECEIVER for various parameters

function [max_error_receiv, mean_error_receiv] = Calculation_inversion_receiver(N ,D, mu, srate, f_min, f_max, N_fft)


%% Loading impulse responses
v_HpIR = zeros(8128, 0);

S_tmp = load('impulse_responses\HpTF_A1.mat');
v_HpIR =[v_HpIR S_tmp.M_HpIR_r(:,1)];

S_tmp = load('impulse_responses\HpTF_B1.mat');
v_HpIR =[v_HpIR S_tmp.M_HpIR_l(:,[1 3 4]) S_tmp.M_HpIR_r(:,[1 3 4 5])  ];

S_tmp = load('impulse_responses\HpTF_C1.mat');
v_HpIR =[v_HpIR S_tmp.M_HpIR_l(:,3) S_tmp.M_HpIR_r(:,[3 4 5])  ];

S_tmp = load('impulse_responses\HpTF_C2.mat');
v_HpIR =[v_HpIR  S_tmp.M_HpIR_r(:,5)  ];

S_tmp = load('impulse_responses\HpTF_C3.mat');
v_HpIR =[v_HpIR  S_tmp.M_HpIR_r(:,4)  ];

% Measured impulse responses of six receiver pairs can be found here: https://cs.uol.de/s/KtbD5tkFWRL9bPd


%% Calculation mean TRCF (Target Response Correction function)
c_devs = {'A1', 'B1', 'C1', 'C2', 'C3'};

vf_trcf = zeros(N_fft/2+1, 10);
for dev = 1:5
    S_tmp = load(['impuls_responses\HRIR_' c_devs{dev} '.mat']);
    % Diffuse-field TRCF, left
    vf_trcf(:,dev    ) = rms( abs(fftR( S_tmp.M_HRIR_open(:,S_tmp.vi_ch_df, 1), N_fft )), 2 ) ./ ...
                         rms( abs(fftR( S_tmp.M_HRIR_mics(:,S_tmp.vi_ch_df, 1), N_fft )), 2 );
    % Diffuse-field TRCF, right             
    vf_trcf(:,dev + 5) = rms( abs(fftR( S_tmp.M_HRIR_open(:,S_tmp.vi_ch_df, 2), N_fft )), 2 ) ./ ...
                         rms( abs(fftR( S_tmp.M_HRIR_mics(:,S_tmp.vi_ch_df, 2), N_fft )), 2 );
end

% HRIR can be found in: https://cs.uol.de/s/KtbD5tkFWRL9bPd

vf_trcf_mean = average_resp(vf_trcf, 2, 'median');


%% Preparation filter calculation:
v_HpIR_mean = average_imp(v_HpIR, 2, 'mean');           % Mean of receivers' impulse responses
vf_HpTF = fftR(v_HpIR_mean, N_fft);

vf_resp_desired = vf_trcf_mean ./ (max( abs(vf_HpTF), db2mag(20))) ./ exp(1i*angle(vf_HpTF));

[~, n_delay] = max(abs(hilbert( ifftR(vf_resp_desired) )));         % Remove delay

% Delta-response with delay of HpTF, for filter calculations
vf_in = [zeros(n_delay,1);1;zeros(N_fft-n_delay-1,1)];

% Regularization: Reduces filter output above 15 kHz
[br,ar] = butter(4, 0.7, 'high');


%% Calculation inversion filter and error to target function
target = vf_trcf_mean.^2;                                       
target_norm = target./sqrt(mean(target.^2));

for o = 1:length(v_HpIR(1,:));
   for k = 1:length(N)
       for p = 1:length(D)
           for j = 1:length(mu)
               % Inversion filter of Kirkeby Nelson
               [v_Ht, ~] = kn_inversion(vf_in,N(k),D(p),impz(br, ar, 1024),mu(j),ifftR(vf_resp_desired));
               v_entz = conv(v_Ht,v_HpIR(:,o));
               y_energy = abs(fftR(v_entz,8128)).^2;
               y_energy_norm = y_energy./sqrt(mean(y_energy.^2));
               
               x_freqz = linspace(0,srate/2,length(y_energy)).';
               freq_mask = x_freqz >= f_min & x_freqz <= f_max;
               
               max_error_receiv(k,p,j,o) = max(abs(10.*log10(y_energy_norm(freq_mask))-10.*log10(target_norm(freq_mask))));
               
               % Mean spectral error on a auditory scale 
                mean_error_receiv(k,p,j,o) = auditory_distance(vf_trcf_mean, fftR(v_entz, 8128), x_freqz, [ 500 4000], 0); 
               
               clear v_Ht
               clear v_entz
               clear y_energy
               clear y_energy_norm
           end
       end
   end
end

endfunction
