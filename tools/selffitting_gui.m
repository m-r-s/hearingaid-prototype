close all
clear
clc

thresholds_freqs = [125 250 500 1000 2000 4000 8000 16000];

plot_freqs = 1000 .* 2.^(-3:0.5:4);
normal_hearing_threshold = hl2spl(plot_freqs, 0);
plot_levels = 0:5:100;
plot_colors = jet(length(plot_levels)).*0.8;

figure('Position', [ 500 200 1200 1000],
       'NumberTitle', 'off',
       'Name', 'Simple self-fitting GUI',
       'toolbar', 'none',
       'menubar', 'none');
h.thresholds_freqs = thresholds_freqs;
h.plot_freqs = plot_freqs;
h.normal_hearing_threshold = normal_hearing_threshold;
h.plot_levels = plot_levels;
h.plot_colors = plot_colors;

figure_positions = {[0.075 0.37 0.4 0.5],[0.55 0.37 0.4 0.5]};
position_title = {'L E F T', 'R I G H T'};
for i=1:2
  h.ax(i) = axes ('position', figure_positions{i});
  box('on');
  h_threshold = plot(log(thresholds_freqs), hl2spl(thresholds_freqs,zeros(size(thresholds_freqs))),'-k','linewidth',2);
  hold on;
  title(position_title{i});
  plot(log(plot_freqs), normal_hearing_threshold,'--k','linewidth',2);
  xlim(log([min(plot_freqs) max(plot_freqs)]));
  ylim([-10 110]);
  set(gca,'xtick',log(plot_freqs(1:2:end)));
  set(gca,'xticklabel',plot_freqs(1:2:end));
  set(gca,'ytick',0:10:100);
  xlabel('Frequency / Hz');
  ylabel('Levels / dB SPL');
  for j=1:length(plot_levels)
    plot(log(plot_freqs),ones(size(plot_freqs)).*plot_levels(j),'--','color',plot_colors(j,:),'linewidth',2);
  end
  h_amplified = zeros(size(plot_levels));
  for j=1:length(plot_levels)
    h_amplified(j) = plot(log(plot_freqs),ones(size(plot_freqs)).*plot_levels(j),'-','color',plot_colors(j,:),'linewidth',2);
  end
  h.h_activedata{i} = h_amplified;
  h.h_threshold{i} = h_threshold;
end

function s = gt_data2string(gt_data)
  [num_rows, num_cols] = size(gt_data);
  s = '[';
  for i=1:num_rows
    s = [s, '['];
    for j=1:num_cols
      s = [s, sprintf('%.2f',gt_data(i,j))];
      if j < num_cols
        s = [s, ' '];
      else
        s = [s, ']'];
      end
    end
    if i < num_rows
      s = [s, ';'];
    else
      s = [s, ']'];
    end
  end
end

function text2speech(message)
  system(['echo text2speech "',message,'" | nc -w 1 127.0.0.1 33338']);
end

function mhacontrol(command)
  system(['echo mhacontrol "',command,'" | nc -w 1 127.0.0.1 33338']);
end

function mhaplay(filename)
  system(['echo mhaplay "',filename,'" "yes" | nc -w 1 127.0.0.1 33338']);
end

function thresholdnoise(status)
  system(['echo thresholdnoise "',status,'" | nc -w 1 127.0.0.1 33338']);
end

function live(status)
  system(['echo live "',status,'" | nc -w 1 127.0.0.1 33338']);
end

function feedback(duration)
  if isnumeric(duration)
    duration = num2str(duration);
  end
  system(['echo feedback "',duration,'" | nc -w 1 127.0.0.1 33338']);
end

function record(duration)
  system(['echo record "',duration,'" | nc -w 1 127.0.0.1 33338']);
end

function send_gaintable(gt_data)
  system(['echo " | nc -w 1 127.0.0.1 33338']);
end

function update_gaintable (obj)
  tic
  h = guidata (obj);
  offset = 30+30.*(0.5-get(h.offset_slider,'value'));
  rolloff = 1+2.^-(get(h.rolloff_slider,'value').*3);
  marginfactor = get(h.marginfactor_slider,'value');
  center = 50+get(h.center_slider,'value').*40;
  focus = round(get(h.focus_slider,'value').*100)./10;
  
  thresholds_left = zeros(size(h.thresholds_freqs));
  thresholds_right = zeros(size(h.thresholds_freqs));
  
  for i=1:length(h.thresholds_freqs)
    thresholds_left(i) = str2num(get(h.thresholds_left{i},'string'));
    thresholds_right(i) = str2num(get(h.thresholds_right{i},'string'));
  end
  
  set(h.h_threshold{1},'ydata',hl2spl(h.thresholds_freqs,thresholds_left));
  set(h.h_threshold{2},'ydata',hl2spl(h.thresholds_freqs,thresholds_right));

  [gt_data, gt_freqs, gt_levels] = prescription_minimalistic(h.thresholds_freqs, thresholds_left, thresholds_right, offset, marginfactor, rolloff, center, focus);
  for i=1:2
    gain = interp2(gt_levels,gt_freqs.',gt_data(1+(i-1).*length(gt_freqs):i.*length(gt_freqs),:),h.plot_levels.',h.plot_freqs,'linear');
    for j=1:length(h.plot_levels)
      set(h.h_activedata{i}(j),'ydata',h.plot_levels(j)+gain(:,j));
    end
  end
  mhacontrol(['mha.transducers.mhachain.altplugs.dynamiccompression.mhachain.dc.gtdata = ',gt_data2string(gt_data)]);
  toc
  drawnow;
end

function update_live(obj)
  h = guidata (obj);
  if get(h.live_checkbox,'value')
    live('on');
  else
    live('off');
  end
end

function update_noise(obj)
  h = guidata (obj);
  if get(h.noise_checkbox,'value')
    thresholdnoise('on');
  else
    thresholdnoise('off');
  end
end

function start_recording()
  record('10');
end

function update_amplification(obj)
  h = guidata (obj);
  if get(h.amplification_checkbox,'value')
    mhacontrol('mha.transducers.mhachain.altplugs.select = dynamiccompression');
  else
    mhacontrol('mha.transducers.mhachain.altplugs.select = identity');
  end
end

function measure_feedback(obj)
  feedback(3);
end

function update_playback(obj)
  h = guidata (obj);
  string = get(h.playback_popup,'string');
  value = get(h.playback_popup,'value');
  selection = string{value};
  switch selection
    case 'off'
      filename = '';
    case 'last record'
      filename ='/dev/shm/recording.wav';
    otherwise
      filename = ['/home/pi/hearingaid-prototype/recordings/' selection '.wav'];
  end
  mhaplay(filename);
end

for i=1:length(thresholds_freqs)
  uicontrol ('style', 'text',
    'units', 'normalized',
    'string', num2str(thresholds_freqs(i)) ,
    'horizontalalignment', 'center',
    'position', [0.02+i*0.05 0.95 0.05 0.05]);
  h.thresholds_left{i} = uicontrol ('style', 'edit',
    'units', 'normalized',
    'string', '0',
    'callback', @update_gaintable,
    'position', [0.02+i*0.05 0.90 0.05 0.05]);
end

for i=1:length(thresholds_freqs)
  uicontrol ('style', 'text',
    'units', 'normalized',
    'string', num2str(thresholds_freqs(i)) ,
    'horizontalalignment', 'center',
    'position', [0.50+i*0.05 0.95 0.05 0.05]);
  h.thresholds_right{i} = uicontrol ('style', 'edit',
    'units', 'normalized',
    'string', '0',
    'callback', @update_gaintable,
    'position', [0.50+i*0.05 0.90 0.05 0.05]);
end

uicontrol ('style', 'text',
  'units', 'normalized',
  'string', 'gain' ,
  'horizontalalignment', 'left',
  'position', [0.05 0.25 0.15 0.05]);

h.offset_slider = uicontrol ('style', 'slider',
  'units', 'normalized',
  'sliderstep', [0.1 0.1],
  'string', 'slider',
  'callback', @update_gaintable,
  'value', 0.5,
  'position', [0.15 0.25 0.65 0.05]);

uicontrol ('style', 'text',
  'units', 'normalized',
  'string', 'compression' ,
  'horizontalalignment', 'left',
  'position', [0.05 0.2 0.15 0.05]);

h.rolloff_slider = uicontrol ('style', 'slider',
  'units', 'normalized',
  'sliderstep', [0.1 0.1],
  'string', 'slider',
  'callback', @update_gaintable,
  'value', 0.5,
  'position', [0.15 0.2 0.65 0.05]);

uicontrol ('style', 'text',
  'units', 'normalized',
  'string', 'boost factor' ,
  'horizontalalignment', 'left',
  'position', [0.05 0.15 0.15 0.05]);
          
h.marginfactor_slider = uicontrol ('style', 'slider',
  'units', 'normalized',
  'sliderstep', [0.1 0.1],
  'string', 'slider',
  'callback', @update_gaintable,
  'value', 0.5,
  'position', [0.15 0.15 0.65 0.05]);

uicontrol ('style', 'text',
  'units', 'normalized',
  'string', 'boost level' ,
  'horizontalalignment', 'left',
  'position', [0.05 0.1 0.15 0.05]);

h.center_slider = uicontrol ('style', 'slider',
  'units', 'normalized',
  'sliderstep', [0.1 0.1],
  'string', 'slider',
  'callback', @update_gaintable,
  'value', 0.5,
  'position', [0.15 0.1 0.65 0.05]);
  
uicontrol ('style', 'text',
  'units', 'normalized',
  'string', 'focus' ,
  'horizontalalignment', 'left',
  'position', [0.05 0.05 0.15 0.05]);

h.focus_slider = uicontrol ('style', 'slider',
  'units', 'normalized',
  'sliderstep', [0.1 0.1],
  'string', 'slider',
  'callback', @update_gaintable,
  'value', 0.5,
  'position', [0.15 0.05 0.65 0.05]);

h.live_checkbox = uicontrol ('style', 'checkbox',
  'units', 'normalized',
  'string', 'live',
  'value', 1,
  'callback', @update_live,
  'position', [0.85 0.275 0.05 0.025]);
  
h.record_button = uicontrol ('style', 'pushbutton',
  'units', 'normalized',
  'string', 'record',
  'callback', @start_recording,
  'position', [0.90 0.275 0.05 0.025]);

uicontrol ('style', 'text',
  'units', 'normalized',
  'string', 'playback' ,
  'horizontalalignment', 'left',
  'position', [0.85 0.25 0.1 0.025]);
  
h.playback_popup = uicontrol ('style', 'popupmenu',
  'units', 'normalized',
  'string', {'off' 'last record'},
  'callback', @update_playback,
  'position', [0.85 0.225 0.1 0.025]);
  
h.amplification_checkbox = uicontrol ('style', 'checkbox',
  'units', 'normalized',
  'string', 'amplification',
  'value', 1,
  'callback', @update_amplification,
  'position', [0.85 0.175 0.1 0.025]);
  
h.noise_checkbox = uicontrol ('style', 'checkbox',
  'units', 'normalized',
  'string', 'threshold noise',
  'value', 0,
  'callback', @update_noise,
  'position', [0.85 0.125 0.1 0.025]);
  
h.feedback_button = uicontrol ('style', 'pushbutton',
  'units', 'normalized',
  'string', 'feedback',
  'callback', @measure_feedback,
  'position', [0.85 0.05 0.1 0.05]);

  
guidata(gcf, h);
update_gaintable(gcf);
update_playback(gcf);
update_live(gcf);
update_noise(gcf);
update_amplification(gcf);
