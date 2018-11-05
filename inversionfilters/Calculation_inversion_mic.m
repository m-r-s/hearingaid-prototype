% (Error-) Calculation inversion microphones for different parameters

function [max_error_mic, v_irsens_df, v_h, v_tot]  = Calculation_inversion_mic(N, D, srate, f_min, f_max)

% Load impuls responses
c_files = dir(['impulse_responses' filesep 'Sens*']);
% Measured impuls responses of six microphone pairs can be found here: https://cs.uol.de/s/KtbD5tkFWRL9bPd
% There the Sens* data indicates the microphone measurements

v_irsens = [];
v_irsens_df = [];
for f = 1:length(c_files)
   s_tmp = load(['impulse_responses' filesep c_files(f).name]);
   v_irsens = [v_irsens, s_tmp.M_ir_sens(:,s_tmp.vi_ch_df)];       % Saves relevant angle of incidence
   v_irsens_df = [v_irsens_df, s_tmp.v_ir_sens_df];
end

v_irsens_mean = average_imp(v_irsens, 2,'median');


% Calculation of inversion filter and error to mean value
T_neg = 0.01;                                   % Paramter for inversion filter calcutation
[b,a] = butter(4, 20000/22050, 'high');         % High pass regularization
v_b = impz(b,a,200);                            % Impulse response describing the regularization filter
beta = 0.001;                                   % Regularization parameter, see Kirkeby and Nelson

max_error_mic = zeros(length(N),length(D),length(c_files));
for o = 1:length(c_files)
    for k = 1:length(N)
       for p = 1:length(D)
           % Inversion filter by Kirkeby-Nelson
           [v_h, ~] = kn_inversion(v_irsens_mean, N(k),round(T_neg*srate) + D(p), v_b, beta);    
           v_tot = conv(v_h,v_irsens_df(:,o));
           y_energy = abs(fftR(v_tot, 8128)).^2;     % Energy of Fourier Transform
           
           x_freqz = linspace(0,srate/2,length(y_energy)).';
           freq_mask = x_freqz >= f_min & x_freqz <= f_max;
                             
           Energie_mean = mean(y_energy(freq_mask));   
           max_error_mic(k,p,o) = max(abs(10.*log10(y_energy(freq_mask)) - 10.*log10(Energie_mean)));
                                  % Logarithmic calculation because of better representation of human ear behavior      
       end
    end
end  


endfunction
