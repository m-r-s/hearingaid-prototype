% Copyright 2018 Marc René Schädler
%
% This file is part of the mobile hearing aid prototype project
% The the mobile hearing aid prototype project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
%
% The mobile hearing aid prototype project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with the mobile hearing aid prototype project. If not, see http://www.gnu.org/licenses/.

function mhaplayback(signal, fs)
  audiofile = [tempname('/dev/shm/') '.wav'];
  audiowrite(audiofile, signal, fs, 'BitsPerSample', 32);
  system(['echo mhaplay "',audiofile,'" relative 130 no > ~/hearingaid-prototype/commandqueue']);
end
