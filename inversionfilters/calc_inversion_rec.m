function [inversion_filters, average_deviation, weighted_average_deviation] = calc_inversion_rec(N ,D, mu, fs)

% FFT sample width
FFTN = 2.^12;
% Corresponding frequency vector for FFT bins
freqs = linspace(0,fs-1/FFTN,FFTN);

% Frequency weights for evaluation of inversion filter
evaluate_weights = 1./freqs;
evaluate_weights(1:find(freqs>100,1,'first')) = 0;
evaluate_weights = evaluate_weights./sum(evaluate_weights);

% Load measured head phone related transfer functions (HpTF)
files = dir(['impulse_responses' filesep 'HpTF*.mat']);
% Measured impulse responses of six headphone pairs can be found here: https://cs.uol.de/s/KtbD5tkFWRL9bPd
% There the HpTF* data indicates the receiver measurements

impulse_responses = cell(1,length(files));
average_impulse_responses = cell(1,length(files));
for i=1:length(files)
  if ~isempty(strfind(files(i).name,'wind'))
    continue
  end
  % Load measurement
  structure_tmp = load(['impulse_responses' filesep files(i).name]);
  % Join left and right channel (i.e., assume symmetry) and
  % resample to target sampling frequency
  impulse_responses{i} = resample([structure_tmp.M_HpIR_l structure_tmp.M_HpIR_r],fs,44100);
  % Select only measurements where the low frequency component (125 Hz) indicates
  % that the in-ear headphone correctly positioned (i.e., high amplitude)
  select = 20*log10(abs(fft(impulse_responses{i},FFTN)))(round(125/fs.*FFTN),:)>40;
  if any(select)
    impulse_responses{i} = impulse_responses{i}(:,select);
    % Calculate the average impulse response for each measurement
    average_impulse_responses{i} = average_imp(impulse_responses{i}, 2,'median');
    % Normalize average amplitude of measurement at 1000 Hz
    reference_level = abs(fft(average_impulse_responses{i},FFTN)(find(freqs>1000,1,'first'),:));
    impulse_responses{i} = impulse_responses{i}./reference_level;
    average_impulse_responses{i} = average_impulse_responses{i}./reference_level;
  else
    impulse_responses(i) = {};
  end
end

% Join average responses into matrix
average_impulse_responses = [average_impulse_responses{:}];

% Calculate a common average diffuse field impulse response for all measurements
impulse_response_common = average_imp([impulse_responses{:}], 2,'median');

% Load HRIR measurements with dummy head to derive a target response correction
% function to preserve the effect of the ear canal
files = dir(['impulse_responses' filesep 'HRIR_*.mat']);
% Measured head related impulse responses (HRIR) with and withput six headphone pairs can be found here: https://cs.uol.de/s/KtbD5tkFWRL9bPd

target_gains = {};
for i=1:length(files)
  if ~isempty(strfind(files(i).name,'wind'))
    continue
  end
  % Load measurement
  structure_tmp = load(['impulse_responses' filesep files(i).name]);
  % Select channels for diffuse field estimation
  impulse_response_left_open = structure_tmp.M_HRIR_open(:,structure_tmp.vi_ch_df,1);
  impulse_response_left_mic = structure_tmp.M_HRIR_mics(:,structure_tmp.vi_ch_df,1);
  impulse_response_right_open = structure_tmp.M_HRIR_open(:,structure_tmp.vi_ch_df,2);
  impulse_response_right_mic = structure_tmp.M_HRIR_mics(:,structure_tmp.vi_ch_df,2);  
  
  target_gains_left = rms(abs(fft(impulse_response_left_open,FFTN)),2)./rms(abs(fft(impulse_response_left_mic,FFTN)),2);
  target_gains_right = rms(abs(fft(impulse_response_right_open,FFTN)),2)./rms(abs(fft(impulse_response_right_mic,FFTN)),2);
  target_gains{end+1} = target_gains_left;
  target_gains{end+2} = target_gains_right;
end

% Join target gains into matrix
target_gains = [target_gains{:}];

% Calculate average target gain
target_gains_average = average_resp(target_gains,2,'median');

% Filter coefficients describing high pass filter for regularization
[b, a] = butter(4, 16000./(fs./2), 'high');
% Impulse response describing the regularization filter
regularization_filter = impz(b,a,200);

% Generate an approximated FIR response
target_gains_average(end/2+2:end) = 0;
target_response = 2.*real(ifft(target_gains_average));
target_response_cut = find(cumsum(target_response(1:FFTN./2).^2./sum(target_response(1:FFTN./2).^2))>(1-10.^(-40/20)),1);
target_response = circshift(target_response,target_response_cut)(1:2.*target_response_cut+1);

weighted_average_deviation = zeros(length(N),length(D),length(mu));
inversion_filters = cell(length(N),length(D),length(mu));
average_deviation = cell(length(N),length(D),length(mu));
for i=1:length(N)
  for j=1:length(D)
    for k=1:length(mu)
      % Calculate inversion filter according to Kirkeby-Nelson
      inversion_filter = kn_inversion(impulse_response_common, N(i),round(0.021375*fs)+D(j), regularization_filter, mu(k), target_response);
      % Apply inversion filter to the average impulse responses
      average_impulse_responses_compensated = conv2(average_impulse_responses,inversion_filter);
      % Calculate the spectral energy of the compensated responses in dB
      compensated_energy_db = 20.*log10(abs(fft(average_impulse_responses_compensated, FFTN)));
      % Normalize energy of each compensated response to a reference of 0 dB at 1000 Hz
      compensated_energy_deviation_db = compensated_energy_db-20*log10(abs(target_gains_average));
      average_deviation{i,j,k} = compensated_energy_deviation_db;
      % Weight the deviation from the reference energy and integrate over measurements
      weighted_average_deviation(i,j,k) = sum(sqrt(mean(abs(compensated_energy_deviation_db(1:FFTN/2,:)).^2,2)).*evaluate_weights(1:FFTN/2).');
      % Set gain of impulse response at 1000 Hz to 1 (=0dB).
      inversion_filter = inversion_filter./abs(fft(inversion_filter,FFTN))(find(freqs>=1000,1));
      inversion_filters{i,j,k} = inversion_filter;
    end
  end
end

end