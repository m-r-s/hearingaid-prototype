close all
clear
clc
graphics_toolkit qt

h.user = 'username';
h.ii = 1;
h.measurements = {};
h.measurements(1, :) = {'Measurement', 'Frequency', 'Amplitude', 'Phase'};
h.freqs = [177, 297, 500, 841, 1414, 2378, 4000, 6727, 11314];

h.gui = figure('Position', [10 10 2000 1200],
       'NumberTitle', 'off',
       'Name', 'Comb-filter phase measurement GUI',
       'toolbar', 'none',
       'menubar', 'none');

% Selection of the pure tone frequency and adaption of the figure axes
function set_freq(obj)
  h = guidata(obj);
  string = get(obj, 'string');
  h.f = str2num(string);
  set(h.dot,'visible','off')
  h.dot = plot(0, 0, 'o', 'color', 'r', 'markersize', 1);
  guidata(obj, h);
end

% Callback for click in the figure
function clickcallback(obj)
  h = guidata(obj);
  axesHandle  = get(obj, 'Parent');
  coordinates = get(gca, 'CurrentPoint');
  coordinates = coordinates(1, 1:2);
  [x_max, y_max] = size(get(obj, 'cdata'));
  y = coordinates(2);
  coordinates(2) = abs((coordinates(2) - 128));
  h.x = coordinates(1);
  h.y = coordinates(2)./128;
  guidata(obj, h);
  coord2param(obj);
  h = guidata(obj);
  h.fs = 48000;
  delay = 1+h.phi/(2*pi).*h.fs./h.f;
  b = zeros(1, 100);
  b(round(delay)) = h.a;
  system(['echo mha.transducers.mhachain.injector.B = [' sprintf('%.15f ',b) '] | nc -w 1 127.0.0.1 33337']);
  hold all
  delete(h.dot);
  h.dot = plot(h.x, y, 'o', 'markerfacecolor', 'r', 'markeredgecolor', 'r', 'markersize', 8);
  drawnow;
  guidata(obj, h);
end

% Convert input values to amplitude (a) and phase (phi)
function coord2param(obj)
  h = guidata(obj);
  h.a = h.y;
  h.phi = (5/2*pi)/160.*h.x;
  guidata(obj, h);
  amplification_rule(obj);
  h = guidata(obj);
  guidata(obj, h);
end

% Scale amplitude
function amplification_rule(obj)
  h = guidata(obj);
  switch h.f
    case 177
      h.a = 10.^((h.a*30-30)/20); % 0 dB to -30 dB
    case 297
      h.a = 10.^((h.a*30-30)/20); % 0 dB to -30 dB
    case 500
      h.a = 10.^((h.a*30-30)/20); % 0 dB to -30 dB
    case 841
      h.a = 10.^((h.a*30-35)/20); % -5 dB to -35 dB
    case 1414
      h.a = 10.^((h.a*35-45)/20); % -10 dB to -40 dB
    case 2378
      h.a = 10.^((h.a*35-50)/20); % -15 dB to -45 dB
    case 4000
      h.a = 10.^((h.a*30-30)/20); %  -5 dB to -35 dB  (0 dB to -30 dB)
    case 6727
      h.a = 10.^((h.a*30-35)/20); %  -5 dB to -35 dB
    case 11314
      h.a = 10.^((h.a*30-35)/20); %  -5 dB to -35 dB
  endswitch 
  guidata(obj, h);
end

% Saving of the data
function finish(obj)
  h = guidata(obj);
  h.measurements(end+1, :) = {h.ii, h.f, h.a, h.phi};
  progress = [num2str(h.ii), ' out of 9 complete'];
  set(h.measurement_complete, 'string', progress);
  if h.ii == 9 % # of measurements
    set(h.measurement_complete, 'string', 'Measurement complete!');
    filename = num2str([h.user, '.csv']);
    cell2csv(filename, h.measurements)
  end
  h.ii = h.ii + 1;
  guidata(obj, h);
end

% Toggle between amplification and no amplification
function play_reference(obj)
  h = guidata(obj);
  b = zeros(1, 100);
  string = get(obj, 'string');
  switch string
    case 'Amp off'
      system(['echo mha.transducers.mhachain.injector.B = [' sprintf('%.15f ',b) '] | nc -w 1 127.0.0.1 33337']);
    case 'Amp on'
      delay = 1+h.phi/(2*pi).*h.fs./h.f;
      b(round(delay)) = h.a;
      system(['echo mha.transducers.mhachain.injector.B = [' sprintf('%.15f ',b) '] | nc -w 1 127.0.0.1 33337']);
  endswitch
  guidata(obj, h);
end

% Keyboard event detection
function keyPress(obj, e)
  h = guidata(obj);
  switch e.Key
    case '1'
      play_reference(h.reference, [], []);
    case '2'
      play_reference(h.adjusted, [], []);
  endswitch
  guidata(obj);
end

h.finish = uicontrol('style', 'pushbutton',
  'units', 'normalized',
  'string', 'Save',
  'fontsize', 18,
  'fontweight', 'bold',
  'callback', @finish,
  'position', [0.75 0.1 0.2 0.1]);

h.amplification_buttons = uibuttongroup('position', [0.75 0.35 0.2 0.1]);
h.amp_off = uicontrol(h.amplification_buttons, 'style', 'radiobutton',
  'units', 'normalized',
  'string', 'Amp off',
  'fontsize', 10,
  'callback', @play_reference,
  'position', [0.1 0.4 0.3 0.2]);
h.amp_on = uicontrol(h.amplification_buttons, 'style', 'radiobutton',
  'units', 'normalized',
  'string', 'Amp on',
  'fontsize', 10,
  'callback', @play_reference,
  'position', [0.6 0.4 0.3 0.2]);

h.freq_buttons = uibuttongroup('position', [0.75 0.475 0.09 0.3]);
h.freq_177 = uicontrol(h.freq_buttons, 'style', 'radiobutton',
  'units', 'normalized',
  'selected', 'on',
  'string', '177',
  'fontsize',10,
  'fontweight','bold',
  'callback', @set_freq,
  'position', [0.05 0.85 0.9 0.05]); 
h.freq_297 = uicontrol(h.freq_buttons, 'style', 'radiobutton',
  'units', 'normalized',
  'string', '297',
  'fontsize',10,
  'fontweight','bold',
  'callback', @set_freq,
  'position', [0.05 0.75 0.9 0.05]); 
h.freq_500 = uicontrol(h.freq_buttons, 'style', 'radiobutton',
  'units', 'normalized',
  'string', '500',
  'fontsize',10,
  'fontweight','bold',
  'callback', @set_freq,
  'position', [0.05 0.65 0.9 0.05]);
h.freq_841 = uicontrol(h.freq_buttons, 'style', 'radiobutton',
  'units', 'normalized',
  'string', '841',
  'fontsize', 10,
  'fontweight','bold',
  'callback', @set_freq,
  'position', [0.05 0.55 0.9 0.05]);
h.freq_1414 = uicontrol(h.freq_buttons, 'style', 'radiobutton',
  'units', 'normalized',
  'string', '1414',
  'fontsize',10,
  'fontweight','bold',
  'callback', @set_freq,
  'position', [0.05 0.45 0.9 0.05]);
h.freq_2378 = uicontrol(h.freq_buttons, 'style', 'radiobutton',
  'units', 'normalized',
  'string', '2378',
  'fontsize',10,
  'fontweight','bold',
  'callback', @set_freq,
  'position', [0.05 0.35 0.9 0.05]);
h.freq_4000 = uicontrol(h.freq_buttons, 'style', 'radiobutton',
  'units', 'normalized',
  'string', '4000',
  'fontsize',10,
  'fontweight','bold',
  'callback', @set_freq,
  'position', [0.05 0.25 0.9 0.05]);
h.freq_6727 = uicontrol(h.freq_buttons, 'style', 'radiobutton',
  'units', 'normalized',
  'string', '6727',
  'fontsize',10,
  'fontweight','bold',
  'callback', @set_freq,
  'position', [0.05 0.15 0.9 0.05]);
h.freq_11314 = uicontrol(h.freq_buttons, 'style', 'radiobutton',
  'units', 'normalized',
  'string', '11314',
  'fontsize',10,
  'fontweight','bold',
  'callback', @set_freq,
  'position', [0.05 0.05 0.9 0.05]);
  
h.measurement_complete = uicontrol('style', 'text',
  'units', 'normalized',
  'string', '',
  'fontsize', 11,
  'fontweight', 'bold',
  'position', [0.75 0.225 0.2 0.1]);
  
img = imread('grid_extended.png');
min_x = 0;
max_x = 160;
min_y = 0;
max_y = 128;

fig_pos_click = {[0.05 0.1 0.65 0.8]};
h.ax_click = axes('position', fig_pos_click{});
box('on')
h_image = imagesc([min_x max_x], [min_y, max_y], img);

set(gca, 'xtick', [0 32 64 96 128 160]);
set(gca, 'xticklabel', {'0', '^{\pi}/_{2}', '\pi', '^{3\pi}/_{2}', '2\pi', '^{5\pi}/_{2}'});
set(gca, 'ytick', [0 64/3 128/3 64 256/3 320/3 128]);
set(gca, 'yticklabel', {'+15', '+10', '+5', '0', '-5', '-10', '-15'});
set(gca, 'linewidth', 3, 'fontsize', 20);
hold all

h.dot = plot(0, 0, 'o', 'color', 'r', 'markersize', 1);

set(h_image,'ButtonDownFcn',@clickcallback);
set(gcf, 'KeyPressFcn', @keyPress);
guidata(gcf, h);
