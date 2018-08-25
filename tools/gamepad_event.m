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
