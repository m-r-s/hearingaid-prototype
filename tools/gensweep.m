function [signal, fs] = gensweep(type, variable, frequency)
  fs = 48000; % Hz
  reference_level = 130; % dB SPL
  sweep_duration = 0.250; % s
  sweep_width = [0.95 1.05];
  flank_duration = 0.010; % s
  sweep_samples = round(fs.*sweep_duration);
  flank_samples = round(fs.*flank_duration);

  % Generate stimulus
  if type > 0
    signal = sinesweepphase(sweep_samples, sweep_width.*frequency./fs, rand(1).*2.*pi);
    signal = normalize(signal, variable - reference_level);
    signal = flank(signal, flank_samples);
  else
    signal = zeros(sweep_samples,1);
  end
end
