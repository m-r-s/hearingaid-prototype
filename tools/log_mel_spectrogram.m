function [log_mel_spec freq_centers] = log_mel_spectrogram(signal, fs, win_shift, win_length, freq_range, num_bands, band_factor)
% usage: log_mel_spec = log_mel_spectrogram(signal, fs)
%   signal      waveform signal
%   fs          sampling rate in Hz
%
% usage [log_mel_spec freq_centers] = log_mel_spectrogram(signal, fs, win_shift, win_length, freq_range, num_bands, band_factor)
%   win_shift   window shift in ms
%   win_length  window length in ms
%   freq_range  [lower upper] frequency
%   num_bands   number of Mel-bands in freq_range
%   band_factor spectral super-sampling factor
%
% - Log Mel-spectrogram v1.1 (modified!) -
%
% This script extracts spectro-temporal representations called
% "logarithmically scaled Mel-spectrograms" from audio signals.
% It roughly resembles basic auditory principles such as a limited spectral
% resolution and a compressive intensity perception.
%
% Copyright (C) 2015-2019 Marc René Schädler
% E-mail marc.r.schaedler@uni-oldenburg.de
% Institute Carl-von-Ossietzky University Oldenburg, Germany
%
%-----------------------------------------------------------------------------
%
% Release Notes:
% v1.0 - Inital release
% v1.1 - Add option for spectral super-sampling and increase upper frequency limit
% Changes reference level from 130 dB SPL to -20*log10(20*10^-6) dB SPL

%% Default settings and checks

% Make signal a row vector
assert(sum(size(signal) > 1) == 1, 'signal must be a vector');
signal = signal(:).';

% Set the default window shift to 10 ms
if nargin < 3 || isempty(win_shift)
  win_shift = 10; % ms
end

% Set the default window length to 25 ms
if nargin < 4 || isempty(win_length)
  win_length = 25; % ms
end

% Set the default frequency range from 64Hz to fs/2 (max. 12kHz)
if nargin < 5 || isempty(freq_range)
  freq_range = [64 min(floor(fs./2), 12000)];
end

% Cover the maximum frequency range with equally Mel-spaced filters
% this results in 23 Mel-bands for freq range = [64 4000]
if nargin < 6 || isempty(num_bands)
  channel_dist = (hz2mel(4000) - hz2mel(64))./(23+1); % Distance between center frequencies in Mel
  num_bands = floor((hz2mel(freq_range(2)) - hz2mel(freq_range(1)))./channel_dist)-1;
  freq_range(2) = mel2hz(hz2mel(freq_range(1))+channel_dist.*(num_bands+1));
end

% Set the default band_factor to 1
if nargin < 7 || isempty(band_factor)
  band_factor = 1;
end


%% Calculation of Mel-spectrogram

% Convert lengths and shifts to samples
M = round(win_shift./1000.*fs);
N = round(win_length./1000.*fs);
num_coeff = 2.^ceil(log2(N));

% Signal framing
num_frames = 1 + floor ((length(signal) - N) ./ M);
frames = zeros(N, num_frames);
for i=1:num_frames
  frames(:,i) = signal(1+(i-1)*M:N+(i-1)*M);
end

% Windowing
window_function = hamming(N);

% Normalize root-mean-square to preserve energy
window_function = window_function ./ sqrt(mean(window_function.^2));

% Apply window function
signal_frame = bsxfun(@times, frames, window_function);

% Calculate spectrum of each frame
spec = 1./num_coeff .* abs(fft(signal_frame, num_coeff, 1));

% Mel-transformation
freq_centers = mel2hz(linspace(hz2mel(freq_range(1)), hz2mel(freq_range(2)), (num_bands+1).*band_factor+1));
mel_spec = triafbmat(fs, num_coeff, freq_centers, [1 1].*band_factor) * spec;

% Return only real center frequencies
freq_centers = freq_centers(1+band_factor:end-band_factor);


%% Logarithmic compression

% 0 dB FS ~ RMS 93.979 dB SPL ~ digital 1 = 1 Pa
log_mel_spec = 20.*log10(mel_spec) - 20.*log10(20.*10.^-6);
end


function [transmat, freq_centers_idx] = triafbmat(fs, num_coeff, freq_centers, width)
% Generate a matrix that joins spectral bins via triangular filters

% Caching whitelist (feel free to add Matlab versions)
caching = is_octave();

if caching
  % Build a config id string
  config = strrep(sprintf('c%.0f', [fs num_coeff freq_centers.*100 width]),'-','_');
  % Load cache
  persistent cache;
end

% Only generate Matrices which are not cached
if ~caching || isempty(cache) || ~isfield(cache, config)
  width_left = width(1);
  width_right = width(2);
  freq_centers_idx = round(freq_centers./fs .* num_coeff);
  num_bands = length(freq_centers)-(width_left+width_right);
  transmat = zeros(num_bands, num_coeff);
  for i=1:num_bands
    left = freq_centers_idx(i);
    center = freq_centers_idx(i+width_left);
    right = freq_centers_idx(i+width_left+width_right);
    start_raise = 0;
    stop_raise = 1;
    start_fall = 1;
    stop_fall = 0;
    if (left >= 1)
      transmat(i,left:center) = linspace(start_raise, stop_raise, center-left+1);
    end
    if (right <= num_coeff)
      transmat(i,center:right) = linspace(start_fall, stop_fall, right-center+1);
    end
  end
  if caching
    % Save to cache
    cache.(config).transmat = transmat;
    cache.(config).freq_centers_idx = freq_centers_idx;
  end
else
  % Load from cache
  transmat = cache.(config).transmat;
  freq_centers_idx = cache.(config).freq_centers_idx;
end
end


function f = mel2hz (m)
% Convert frequency from Mel to Hz
f = 700.*((10.^(m./2595))-1);
end


function m = hz2mel (f)
% Convert frequency from Hz to Mel
m = 2595.*log10(1+f./700);
end


function r = is_octave ()
  persistent x;
  if (isempty (x))
    x = exist ('OCTAVE_VERSION', 'builtin');
  end
  r = x;
end
