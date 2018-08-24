function event = gamepad_event()

persistent fid = [];
device = '/dev/input/js0';

if isempty(fid) || fid < 0 || feof(fid) || ferror(fid)
  if ~isempty(fid) && fid > 0
    fclose(fid);
    fid = [];
  end
  if exist(device,'file') == 2
    fid = fopen(device,'rb');
  else
    pause(1);
  end
end
event = '';
if fid > 0
  keycode = fread(fid,8,'char').';
  if ~isempty(keycode)
    switch keycode(5:end)
      case [1 0 1 0]
        event = 'A pressed';
      case [0 0 1 0]
        event = 'A released';
      case [1 0 1 1]
        event = 'B pressed';
      case [0 0 1 1]
        event = 'B released';
      case [1 0 1 3]
        event = 'X pressed';
      case [0 0 1 3]
        event = 'X released';
      case [1 0 1 4]
        event = 'Y pressed';
      case [0 0 1 4]
        event = 'Y released';
      case [1 0 1 11]
        event = 'START pressed';
      case [0 0 1 11]
        event = 'START released';
      case [1 0 1 10]
        event = 'SELECT pressed';
      case [0 0 1 10]
        event = 'SELECT released';
      case [1 0 1 7]
        event = 'RT pressed';
      case [0 0 1 7]
        event = 'RT released';
      case [1 0 1 6]
        event = 'LT pressed';
      case [0 0 1 6]
        event = 'LT released';
      case [1 -128 2 1]
        event = 'VERTICAL max';
      case [0 0 2 1]
        event = 'VERTICAL neutral';
      case [-1 127 2 1]
        event = 'VERTICAL min';
      case [-1 127 2 0]
        event = 'HORIZONTAL max';
      case [0 0 2 0]
        event = 'HORIZONTAL neutral';
      case [1 -128 2 0]
        event = 'HORIZONTAL min';
      otherwise
        %keycode
    end
  end
end
end
