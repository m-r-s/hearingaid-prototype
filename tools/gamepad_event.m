% Copyright 2018 Marc René Schädler
%
% This file is part of the mobile hearing aid prototype project
% The the mobile hearing aid prototype project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
%
% The mobile hearing aid prototype project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with the mobile hearing aid prototype project. If not, see http://www.gnu.org/licenses/.

function event = gamepad_event()
persistent fid = [];
device = '/dev/input/js0';

if isempty(fid) || fid < 0 || feof(fid) || ferror(fid)
  if ~isempty(fid) && fid > 0
    fclose(fid);
    fid = [];
  end
  while ~(exist(device,'file') == 2)
    pause(1);
  end
  fid = fopen(device,'rb');
end
event = [];
if fid > 0
  while isempty(event)
    keycode = fread(fid,8,'char').';
    if ~isempty(keycode)
      switch keycode(5:end)
        case [1 0 1 0]
          event = 'A';
        case [1 0 1 1]
          event = 'B';
        case [1 0 1 3]
          event = 'X';
        case [1 0 1 4]
          event = 'Y';
        case [1 0 1 11]
          event = 'START';
        case [1 0 1 10]
          event = 'SELECT';
        case [1 0 1 7]
          event = 'RT';
        case [1 0 1 6]
          event = 'LT';
        case [1 128 2 1]
          event = 'VERTICAL max';
        case [0 0 2 1]
          event = 'VERTICAL neutral';
        case [255 127 2 1]
          event = 'VERTICAL min';
        case [255 127 2 0]
          event = 'HORIZONTAL max';
        case [0 0 2 0]
          event = 'HORIZONTAL neutral';
        case [1 128 2 0]
          event = 'HORIZONTAL min';
        otherwise
  %        keycode
      end
    end
  end
end
end
