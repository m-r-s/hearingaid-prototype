% Copyright 2018 Marc René Schädler
%
% This file is part of the mobile hearing aid prototype project
% The the mobile hearing aid prototype project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
%
% The mobile hearing aid prototype project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with the mobile hearing aid prototype project. If not, see http://www.gnu.org/licenses/.

function playwavfile(filename, ear, device, blocking)
  
  persistent player;
  
  if nargin < 2
    ear = 'b';
  end
  
  if nargin < 3
    device = 'system';
  end
  
  if nargin < 4
    blocking = 1;
  end
  
  % Get audio data
  [signal, fs] = audioread(filename);
  if isempty(signal)
    error('Could not read wav file');
  end
  
  % Find device ID for audio playback
  playdev = audiodevinfo(0,sprintf('%s (JACK Audio Connection Kit)',device));
  if isempty(playdev)
    error(sprintf('Could not find playback device: %s\n',device));
  end

  if size(signal,2) < 2
    % Compose signal for left, right, or both ears
    switch ear
      case 'l'
        signal = [signal, zeros(size(signal))];
      case 'r'
        signal = [zeros(size(signal)), signal];
      case 'b'
        signal = [signal, signal];
      otherwise
        error('unknown ear definition (l/r/b)');
    end
  end
  
  if size(signal,2) > 2
    error('More than 2 channels not supported');
  end

  % Playback with 24bit samples on "playdev" (depends on capabilities of device, choose highest possible)
  signal = [signal; zeros(round(0.2.*fs),2)];
  player = audioplayer(signal, fs, 24, playdev);
  play(player);
  if blocking
    pause(size(signal,1)./fs);
    stop(player);
  end
end
