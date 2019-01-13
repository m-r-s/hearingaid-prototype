% Copyright 2018 Marc René Schädler
%
% This file is part of the mobile hearing aid prototype project
% The the mobile hearing aid prototype project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
%
% The mobile hearing aid prototype project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with the mobile hearing aid prototype project. If not, see http://www.gnu.org/licenses/.

function [signal, fs] = gensweep(type, variable, frequency)
  fs = 48000; % Hz
  reference_level = 93.979; % dB SPL
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
