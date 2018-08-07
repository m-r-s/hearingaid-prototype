function signal = sinesweepphase(samples, frequency, phase)
%usage: signal = sinesweepphase(samples, frequency, phase)
%
% samples          - number of samples
% frequency        - normalized frequencies [0..1]
% phase            - phase [0..2*pi]

phase_diff_start = 2.*pi.*frequency(1);
phase_diff_stop = 2.*pi.*frequency(2);

phase_diff = logspace(log10(phase_diff_start),log10(phase_diff_stop),samples);

if nargin >= 4
  phase_diff(1) = phase_diff(1) + phase;
end

signal = sin(cumsum(phase_diff)).';
end

