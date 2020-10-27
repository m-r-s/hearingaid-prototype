clc
clear
close all

h.gui = figure('Position', [300 100 400 900],
               'NumberTitle', 'off',
               'Name', 'Gain table comparison',
               'toolbar', 'none',
               'menubar','none');

h.nogain = [struct2cell(load('nogain.mat')){:}];
h.mitigation_6dB = [struct2cell(load('6dB_mitigation.mat')){:}];
h.critical = [struct2cell(load('horror_scenario.mat')){:}];

h.delay_value = 0;

h.filename = 'white_noise.wav';
[h.y, h.fs] = audioread(h.filename);
h.player = audioplayer(h.y, h.fs);
                             
function mhacontrol(command)
  system(['echo mhacontrol "',command,'" | nc -w 1 127.0.0.1 33337']);
end

function update_gaintable(obj)
  h = guidata(obj);
  string = get(obj, 'string');
  switch string
    case 'transparent'
      write_gaintable(h.nogain);
      set(h.transparent_fitting, 'fontweight', 'bold', 'fontsize', 14);
      set(h.mitigated_fitting_6dB, 'fontweight', 'normal', 'fontsize', 12);
      set(h.mute, 'fontweight', 'normal', 'fontsize', 12);
      set(h.critical_fitting, 'fontweight', 'normal', 'fontsize', 12);
    case '6 dB mitigation'
      write_gaintable(h.mitigation_6dB);
      set(h.transparent_fitting, 'fontweight', 'normal', 'fontsize', 12);
      set(h.mitigated_fitting_6dB, 'fontweight', 'bold', 'fontsize', 14);
      set(h.mute, 'fontweight', 'normal', 'fontsize', 12);
      set(h.critical_fitting, 'fontweight', 'normal', 'fontsize', 12);
    case 'mute'
      system(['echo "mha.transducers.mhachain.altplugs.select = (none)" | nc -w 1 127.0.0.1 33337']);
      set(h.transparent_fitting, 'fontweight', 'normal', 'fontsize', 12);
      set(h.mitigated_fitting_6dB, 'fontweight', 'normal', 'fontsize', 12);
      set(h.mute, 'fontweight', 'bold', 'fontsize', 14);
      set(h.critical_fitting, 'fontweight', 'normal', 'fontsize', 12);
    case 'critical'
      write_gaintable(h.critical);
      set(h.transparent_fitting, 'fontweight', 'normal', 'fontsize', 12);
      set(h.mitigated_fitting_6dB, 'fontweight', 'normal', 'fontsize', 12);
      set(h.mute, 'fontweight', 'normal', 'fontsize', 12);
      set(h.critical_fitting, 'fontweight', 'bold', 'fontsize', 14);
  endswitch
  guidata(obj, h);
end

function write_gaintable(gtdata)
  gtdatastring = gtdata2mhaconfig(gtdata);
  system(['echo "mha.transducers.mhachain.altplugs.dynamiccompression.mhachain.dc.gtdata=' gtdatastring '" | nc -w 1 127.0.0.1 33337 | grep -m1 "(MHA:success)"']);
  system(['echo "mha.transducers.mhachain.altplugs.select = dynamiccompression" | nc -w 1 127.0.0.1 33337']);
end

function playback(obj)
  h = guidata(obj);
  h.playback_string = get(obj, 'string');
  switch h.playback_string
    case 'stop'
      stop(h.player);   % stop playback
      set(h.playback_info, 'string', 'Stopped. Press "play" to continue');
      set(h.play, 'fontweight', 'bold', 'fontsize', 12);
      set(h.stop, 'fontweight', 'normal', 'fontsize', 10);
    case 'play'
      play(h.player);   % start playback
      set(h.playback_info, 'string', 'Press "stop" to stop playback');
      set(h.play, 'fontweight', 'normal', 'fontsize', 10);
      set(h.stop, 'fontweight', 'bold', 'fontsize', 12);
  endswitch
  guidata(obj, h);
end

function update_playback(obj)
  h = guidata(obj);
  if h.playback_string == 'play'
    stop(h.player);
  end
  string = get(h.playback_popup, 'string');
  value = get(h.playback_popup, 'value');
  selection = string{value};
  h.filename = [selection '.wav'];
  guidata(obj, h);
  pcplay(obj);
end

function pcplay(obj)
  h = guidata(obj);
  [h.y, h.fs] = audioread(h.filename);
  h.player = audioplayer(h.y, h.fs);
  if h.playback_string == 'play'
    play(h.player);
  end
  guidata(obj, h);
end

function getSound(obj)
  h = guidata(obj);
  new_item = uigetfile('*.wav');
  [~,new_item,~] = fileparts(new_item);
  tmp = get(h.playback_popup, 'string');
  tmp{end+1} = new_item;
  set(h.playback_popup,'string',tmp);
end

function delay(obj)
  h = guidata(obj);
  string = get(obj, 'string');
  switch string
    case 'none'
      set(h.delay_slider, 'visible', 'off');
      set(h.slider_min, 'visible', 'off');
      set(h.slider_max, 'visible', 'off');
      set(h.delay_custom, 'string', 'custom');
      system(['echo "mha.transducers.mhachain.delay.delay = [0 0]" | nc -w 1 127.0.0.1 33337']);
    case '5 ms'
      set(h.delay_slider, 'visible', 'off');
      set(h.slider_min, 'visible', 'off');
      set(h.slider_max, 'visible', 'off');
      set(h.delay_custom, 'string', 'custom');
      system(['echo "mha.transducers.mhachain.delay.delay = [624 624]" | nc -w 1 127.0.0.1 33337']);
    case '10 ms'
      set(h.delay_slider, 'visible', 'off');
      set(h.slider_min, 'visible', 'off');
      set(h.slider_max, 'visible', 'off');
      set(h.delay_custom, 'string', 'custom');
      system(['echo "mha.transducers.mhachain.delay.delay = [3024 3024]" | nc -w 1 127.0.0.1 33337']);
    case 'custom'
      set(h.delay_slider, 'visible', 'on');
      set(h.slider_min, 'visible', 'on');
      set(h.slider_max, 'visible', 'on');
      set(h.delay_custom, 'string', [num2str(round(get(h.delay_slider, 'value')*10)/10) ' ms']);
      system(['echo "mha.transducers.mhachain.delay.delay = [' num2str(h.delay_value) ' ' num2str(h.delay_value) ']" | nc -w 1 127.0.0.1 33337']);
  endswitch
end

function custom_delay(obj)
  h = guidata(obj);
  h.delay_value = (get(h.delay_slider, 'value') - 3.7)*480;
  system(['echo "mha.transducers.mhachain.delay.delay = [' num2str(round(h.delay_value)) ' ' num2str(round(h.delay_value)) ']" | nc -w 1 127.0.0.1 33337']);
  set(h.delay_custom, 'string', [num2str(round(get(h.delay_slider, 'value')*10)/10) ' ms']);
  guidata(obj, h);
end

uicontrol ('style', 'text',
  'units', 'normalized',
  'string', 'Choose a preset',
  'fontsize', 16,
  'horizontalalignment', 'center',
  'backgroundcolor', [1 1 1],
  'position', [0.1 0.925 0.8 0.05]);             
h.gaintable_buttongroup = uibuttongroup ('position', [0.1 0.575 0.8 0.35],
  'backgroundcolor', [0.7 0.7 0.7]);
h.transparent_fitting = uicontrol (h.gaintable_buttongroup, 'style', 'pushbutton',
  'units', 'normalized',
  'string', 'transparent',
  'fontsize', 14,
  'fontweight', 'demi',
  'callback', @update_gaintable,
  'position', [0.05 0.7625 0.9 0.1875]);
h.critical_fitting = uicontrol (h.gaintable_buttongroup, 'style', 'pushbutton',
  'units', 'normalized',
  'string', 'critical',
  'fontsize', 12,
  'fontweight', 'normal',
  'callback', @update_gaintable,
  'position', [0.05 0.525 0.9 0.1875]);
h.mitigated_fitting_6dB = uicontrol (h.gaintable_buttongroup, 'style', 'pushbutton',
  'units', 'normalized',
  'string', '6 dB mitigation',
  'fontsize', 12,
  'fontweight', 'normal',
  'callback', @update_gaintable,
  'position', [0.05 0.2875 0.9 0.1875]);
h.mute = uicontrol (h.gaintable_buttongroup, 'style', 'pushbutton',
  'units', 'normalized',
  'string', 'mute',
  'fontsize', 12,
  'fontweight', 'normal',
  'callback', @update_gaintable,
  'position', [0.05 0.05 0.9 0.1875]);

uicontrol ('style', 'text',
  'units', 'normalized',
  'string', 'Select delay',
  'fontsize', 16,
  'horizontalalignment', 'center',
  'backgroundcolor', [1 1 1],
  'position', [0.1 0.475 0.375 0.05]); 
h.delay_buttongroup = uibuttongroup ('position', [0.1 0.325 0.375 0.15],
  'backgroundcolor', [0.7 0.7 0.7]);
h.delay_none = uicontrol (h.delay_buttongroup, 'style', 'radiobutton',
  'units', 'normalized',
  'string', 'none',
  'fontsize', 12,
  'backgroundcolor', [0.7 0.7 0.7],
  'selected', 'on',
  'callback', @delay,
  'position', [0.1 0.77 0.8 0.15]);
h.delay_5ms = uicontrol (h.delay_buttongroup, 'style', 'radiobutton',
  'units', 'normalized',
  'string', '5 ms',
  'fontsize', 12,
  'backgroundcolor', [0.7 0.7 0.7],
  'callback', @delay,
  'position', [0.1 0.54 0.8 0.15]);
h.delay_10ms = uicontrol (h.delay_buttongroup, 'style', 'radiobutton',
  'units', 'normalized',
  'string', '10 ms',
  'fontsize', 12,
  'backgroundcolor', [0.7 0.7 0.7],
  'callback', @delay,
  'position', [0.1 0.31 0.8 0.15]);
h.delay_custom = uicontrol (h.delay_buttongroup, 'style', 'radiobutton',
  'units', 'normalized',
  'string', 'custom',
  'fontsize', 12,
  'backgroundcolor', [0.7 0.7 0.7],
  'callback', @delay,
  'position', [0.1 0.08 0.8 0.15]);
  
h.slider_min = uicontrol ('style', 'text',
  'units', 'normalized',
  'string', '3.7',
  'backgroundcolor', [1 1 1],
  'visible', 'off',
  'position', [0 0.25 0.1 0.05]);
h.delay_slider = uicontrol ('style', 'slider',
  'units', 'normalized',
  'string', 'delay',
  'callback', @custom_delay,
  'value', 3.7,
  'min', 3.7,
  'max', 20,
  'visible', 'off',
  'position', [0.1 0.25 0.8 0.05]);
h.slider_max = uicontrol ('style', 'text',
  'units', 'normalized',
  'string', '20',
  'backgroundcolor', [1 1 1],
  'visible', 'off',
  'position', [0.9 0.25 0.1 0.05]);

uicontrol ('style', 'text',
  'units', 'normalized',
  'string', 'Select playback',
  'fontsize', 8,
  'horizontalalignment', 'left',
  'backgroundcolor', [1 1 1],
  'position', [0.525 0.435 0.225 0.05]);
h.playback_popup = uicontrol ('style','popupmenu',
  'units', 'normalized',
  'string', {'white_noise','classical_music','pop_music'},
  'callback', @update_playback,
  'position', [0.525 0.385 0.375 0.05]);

h.open_sound = uicontrol ('style', 'pushbutton',
  'units', 'normalized',
  'string', 'Open...',
  'fontsize', 8,
  'fontweight', 'normal',
  'callback', @getSound,
  'position', [0.775 0.445 0.125 0.03]);

h.playback_info = uicontrol ('style', 'text',
  'units', 'normalized',
  'string', 'Press "play" for playback of sound',
  'fontsize', 8,
  'horizontalalignment', 'center',
  'backgroundcolor', [1 1 1],
  'position', [0.25 0.15 0.5 0.05]); 
h.playback_buttongroup = uibuttongroup ('position', [0.25 0.05 0.5 0.1],
'backgroundcolor', [0.7 0.7 0.7]);
h.stop = uicontrol (h.playback_buttongroup, 'style', 'pushbutton',
  'units', 'normalized',
  'string', 'stop',
  'fontsize', 10,
  'fontweight', 'normal',
  'callback', @playback,
  'position', [0.05 0.1 0.4 0.8]);
h.play = uicontrol (h.playback_buttongroup, 'style', 'pushbutton',
  'units', 'normalized',
  'string', 'play',
  'fontsize', 12,
  'fontweight', 'demi',
  'callback', @playback,
  'position', [0.55 0.1 0.4 0.8]);

set(h.delay_buttongroup,'SelectedObject',h.delay_none);
h.playback_string = 'stop';
guidata(gcf, h);
