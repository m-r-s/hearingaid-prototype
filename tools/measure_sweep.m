% Copyright 2018 Marc René Schädler
%
% This file is part of the mobile hearing aid prototype project
% The the mobile hearing aid prototype project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
%
% The mobile hearing aid prototype project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with the mobile hearing aid prototype project. If not, see http://www.gnu.org/licenses/.

function threshold = measure_sweep(frequency, ear)
  % SIAM configuration
  target = 0.75;
  minreversals = 10;
  discardreversals = 4;
  minmeasures = 12;
  startvalue = 70; % dB HL
  steps = [8 8 4 2];
  
  % Initialize return
  threshold = [];
  
  % Configure presentstimulus
  presentstimulus([], [], frequency, ear);
  % Interpret start value as dB SPL
  startvalue_corrected = startvalue;

  % Demo stimulus to get close to threshold
  answer = 0;
  while answer == 0
    validanswer = 0;
    presentstimulus(1, startvalue_corrected);
    while validanswer == 0
      switch gamepad_event()
        case 'A'
          validanswer = 1;
          answer = 1;
        case 'X'
          validanswer = 1;
          answer = 0;
        case 'B'
          validanswer = 1;
          answer = [];
          return
      end
    end
    if answer == 0
      startvalue_corrected = startvalue_corrected + steps(1);
    end
  end

  % Start single interval adaptive measurement
  threshold = ...
    siam(@presentstimulus, @getanswer, target, minreversals, discardreversals, minmeasures, startvalue_corrected, steps, 0);
end

function offset = presentstimulus(presentation, value, frequency, ear)
  offset = nan;

  % Use persistent variables for configuration
  persistent cache;
  if nargin > 2
    cache.count = 0;
    cache.id = rand(1);
    cache.frequency = frequency;
    cache.ear = ear;
  else
    frequency = cache.frequency;
    ear = cache.ear;
  end

  cache.count = cache.count + 1;
  if isempty(presentation)
    return
  end

  % Generate the sweep using the sweep stimulus function
  [signal, fs] = gensweep(presentation, value, frequency);

  % Compose stimulus for left, right, or both ears
  switch ear
    case 'l'
      stimulus = [signal, zeros(size(signal))];
    case 'r'
      stimulus = [zeros(size(signal)), signal];
    case 'b'
      stimulus = [signal, signal];
    otherwise
      error('unknown ear definition (l/r/b)');
  end

  % Playback stimulus
  pause(0.25);
  mhaplayback(stimulus, fs);
end

function answer = getanswer(count)
  validanswer = 0;
  while validanswer == 0
    switch gamepad_event();
      case 'A'
        validanswer = 1;
        answer = 1;
      case 'X'
        validanswer = 1;
        answer = 0;
      case {'B'}
        validanswer = 1;
        answer = [];
    end
  end
end
