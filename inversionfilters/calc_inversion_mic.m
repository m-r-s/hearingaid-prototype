function [inversion_filters, average_deviation, weighted_average_deviation]  = calc_inversion_mic(N, D, mu, fs)

% FFT sample width
FFTN = 2.^12;
% Corresponding frequency vector for FFT bins
freqs = linspace(0,fs-1/FFTN,FFTN);

% Frequency weights for evaluation of inversion filter
evaluate_weights = 1./freqs;
evaluate_weights(1:find(freqs>100,1,'first')) = 0;
evaluate_weights(find(freqs<8000,1,'last'):end) = 0;
evaluate_weights = evaluate_weights./sum(evaluate_weights);

% Load measured impulse responses
files = dir(['impulse_responses' filesep 'Sens*.mat']);
% Measured impulse responses of six headphone pairs can be found here: https://cs.uol.de/s/KtbD5tkFWRL9bPd
% There the Sens* data indicates the microphone measurements

impulse_responses = cell(1,length(files));
average_impulse_responses = cell(1,length(files));
for i=1:length(files)
  if ~isempty(strfind(files(i).name,'wind'))
    continue
  end
  % Load measurement
  structure_tmp = load(['impulse_responses' filesep files(i).name]);
  % Select channels for diffuse field estimation
  impulse_responses_diffuse_field = structure_tmp.M_ir_sens(:,structure_tmp.vi_ch_df);
  % Resample to target sampling frequency
  impulse_responses{i} = resample(impulse_responses_diffuse_field,fs,44100);
  % Calculate the average diffuse field impulse response for each measurement
  average_impulse_responses{i} = average_imp(impulse_responses{i}, 2,'median');
  % Normalize average amplitude of measurement at 1000 Hz
  reference_level = abs(fft(average_impulse_responses{i},FFTN)(find(freqs>1000,1,'first'),:));
  impulse_responses{i} = impulse_responses{i}./reference_level;
  average_impulse_responses{i} = average_impulse_responses{i}./reference_level;
end

% Join average responses into matrix
average_impulse_responses = [average_impulse_responses{:}];

% Calculate a common average diffuse field impulse response for all measurements
impulse_response_common = average_imp([impulse_responses{:}], 2,'median');

% Filter coefficients describing high pass filter for regularization
[b, a] = butter(4, 16000./(fs./2), 'high');
% Impulse response describing the regularization filter
regularization_filter = impz(b,a,200);

weighted_average_deviation = zeros(length(N),length(D),length(mu));
inversion_filters = cell(length(N),length(D),length(mu));
average_deviation = cell(length(N),length(D),length(mu));
for i=1:length(N)
  for j=1:length(D)
    for k=1:length(mu)
      % Calculate inversion filter according to Kirkeby-Nelson
      inversion_filter = kn_inversion(impulse_response_common, N(i),round(0.010042*fs) + D(j), regularization_filter, mu(k));
      % Apply inversion filter to the average impulse responses
      average_impulse_responses_compensated = conv2(average_impulse_responses,inversion_filter);
      % Calculate the spectral energy of the compensated responses in dB
      compensated_energy_db = 10.*log10(abs(fft(average_impulse_responses_compensated, FFTN)).^2);
      % Normalize energy of each compensated response to a reference of 0 dB at 1000 Hz
      compensated_energy_deviation_db = compensated_energy_db-compensated_energy_db(find(freqs>1000,1,'first'),:);
      average_deviation{i,j,k} = compensated_energy_deviation_db;
      % Weight the deviation from the reference energy and integrate over measurements
      weighted_average_deviation(i,j,k) = sum(sqrt(mean(abs(compensated_energy_deviation_db).^2,2)).*evaluate_weights(:));
      % Set gain of impulse response at 1000 Hz to 1 (=0dB).
      inversion_filter = inversion_filter./abs(fft(inversion_filter,FFTN))(find(freqs>=1000,1));
      inversion_filters{i,j,k} = inversion_filter;
    end
  end
end

end