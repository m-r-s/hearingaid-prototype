% Copyright 2018 Marc René Schädler
%
% This file is part of the mobile hearing aid prototype project
% The the mobile hearing aid prototype project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
%
% The mobile hearing aid prototype project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with the mobile hearing aid prototype project. If not, see http://www.gnu.org/licenses/.

close all
clear
clc

thresholds_freqs = [125 250 500 1000 2000 4000 8000 16000];
thresholds_init  = [ 39  71  71   62   60   58   58    36]; % dB SPL at mic
normal_threshold = [ 33  24  13    5   13   15   14    11]; % Estimated

plot_freqs = 1000 .* 2.^(-3:0.5:4);
plot_threshold = interp1(thresholds_freqs,normal_threshold,plot_freqs);
plot_levels = 0:5:100;
plot_colors = jet(length(plot_levels)).*0.8;

figure('Position', [ 500 200 1200 1000],
       'NumberTitle', 'off',
       'Name', 'Simple self-fitting GUI',
       'toolbar', 'none',
       'menubar', 'none');
h.thresholds_freqs = thresholds_freqs;
h.plot_freqs = plot_freqs;
h.plot_threshold = plot_threshold;
h.plot_levels = plot_levels;
h.plot_colors = plot_colors;

figure_positions = {[0.075 0.37 0.4 0.5],[0.55 0.37 0.4 0.5]};
position_title = {'L E F T', 'R I G H T'};
for i=1:2
  h.ax(i) = axes ('position', figure_positions{i});
  box('on');
  h_threshold = plot(log(thresholds_freqs), zeros(size(thresholds_freqs)),'-k','linewidth',2);
  hold on;
  title(position_title{i});
  plot(log(plot_freqs), plot_threshold,'--k','linewidth',2);
  xlim(log([min(plot_freqs) max(plot_freqs)]));
  ylim([-10 110]);
  set(gca,'xtick',log(plot_freqs(1:2:end)));
  set(gca,'xticklabel',plot_freqs(1:2:end));
  set(gca,'ytick',0:10:100);
  xlabel('Frequency / Hz');
  ylabel('Levels / dB SPL (in device)');
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

  set(h.h_threshold{1},'ydata',thresholds_left);
  set(h.h_threshold{2},'ydata',thresholds_right);

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

function update_calib(obj)
  h = guidata (obj);
  if get(h.calib_checkbox,'value')
	% values taken from current openMHA.cfg
    mhacontrol('mha.transducers.calib_in.fir = [[-0.674757033017875 -0.339128228007168 0.030117856798366 -0.119542483672035 0.131726684555067 -0.071387589553860 0.056561094657502 -0.013365060531109 0.007091265106959 0.006913350591302 -0.002602409570910 0.023338189483743 -0.018652297865493 0.021281416315377 -0.014374905102702 0.015659551668403];[-0.674757033017875 -0.339128228007168 0.030117856798366 -0.119542483672035 0.131726684555067 -0.071387589553860 0.056561094657502 -0.013365060531109 0.007091265106959 0.006913350591302 -0.002602409570910 0.023338189483743 -0.018652297865493 0.021281416315377 -0.014374905102702 0.015659551668403]]');
    mhacontrol('mha.transducers.calib_out.fir = [[-0.723329250680037 1.285750531421244 -1.764370643350338 1.702299222653803 0.569187694811727 -1.301642333817312 0.540112043557634 -0.111972475691304 0.187607100395961 0.532899301077540 -0.733701264924906 0.290587502735630 0.470074681167595 -0.330332208101367 -0.010615612830630 -0.221018479662762 -0.020491963942295 0.385847945936633 -0.198969798086483 -0.123437157204177 0.152968427130900 -0.205009361694624 -0.071974598348291 0.041537565470939 -0.058703551389704 0.006171609199330 -0.037439953306526 -0.032735557865821 0.028903184718236 -0.019431703287974 -0.069837180982837 0.038967963643885 -0.015801874625706 -0.060091628384134 0.057102986709234 -0.043134256115441 -0.016815289718170 0.002879163232524 -0.031134102833679 0.026124175604008 -0.040758325083950 0.022598560658844 0.012982112833010 -0.029909215215110 0.018353193685970 0.012015086827306 0.031537385134343 -0.028980188877489 0.026113358679986 0.017332696993042 -0.018853690496196 0.059665425003585 -0.017281793549857 0.007285675861939 0.010218784848149 0.003173184622963 0.040817408121183 -0.024810702312558 0.007344195504224 0.007639434860116 -0.004797394889051 0.025321400227842 -0.005638659121956 -0.002191206231116];[-0.723329250680037 1.285750531421244 -1.764370643350338 1.702299222653803 0.569187694811727 -1.301642333817312 0.540112043557634 -0.111972475691304 0.187607100395961 0.532899301077540 -0.733701264924906 0.290587502735630 0.470074681167595 -0.330332208101367 -0.010615612830630 -0.221018479662762 -0.020491963942295 0.385847945936633 -0.198969798086483 -0.123437157204177 0.152968427130900 -0.205009361694624 -0.071974598348291 0.041537565470939 -0.058703551389704 0.006171609199330 -0.037439953306526 -0.032735557865821 0.028903184718236 -0.019431703287974 -0.069837180982837 0.038967963643885 -0.015801874625706 -0.060091628384134 0.057102986709234 -0.043134256115441 -0.016815289718170 0.002879163232524 -0.031134102833679 0.026124175604008 -0.040758325083950 0.022598560658844 0.012982112833010 -0.029909215215110 0.018353193685970 0.012015086827306 0.031537385134343 -0.028980188877489 0.026113358679986 0.017332696993042 -0.018853690496196 0.059665425003585 -0.017281793549857 0.007285675861939 0.010218784848149 0.003173184622963 0.040817408121183 -0.024810702312558 0.007344195504224 0.007639434860116 -0.004797394889051 0.025321400227842 -0.005638659121956 -0.002191206231116]]');
  else
    mhacontrol('mha.transducers.calib_in.fir = 1');
    mhacontrol('mha.transducers.calib_out.fir = 1');
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
    'string', num2str(thresholds_init(i)),
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
    'string', num2str(thresholds_init(i)),
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
  'string', {'off' 'last record' '35-29-25_fridge' '36-26-19_clock' '53-41-34_footsteps' '55-44-33_handwash' '63-57-37_microwave' '63-57-51_coffeemachine' '64-33-24_keyboardwriting' '64-42-35_foyer' '64-53-46_autobahn' '66-56-48_siren' '68-57-50_drivingnews' '68-59-52_street' '70-61-53_street' '72-57-49_bird' '72-63-60_coffeegrinder' '73-50-42_steeldrum-steps' '73-60-50_cardriveby' '73-63-57_steet-laughter' '75-25-17_phone' '77-54-46_ducks' '78-68-60_street' '78-69-62_lisboa-bride-bird' '79-59-50_bar' '81-54-34_coffeemachine' '81-61-47_traincrossing' '81-66-60_lisboa-plane-landing' '82-53-35_shakeout' '83-69-60_mainstreet' '83-73-65_traffic' '86-75-68_lisboa-bride-train' '88-73-65_lisboa-train' '100-64-37_flute'},
  'callback', @update_playback,
  'position', [0.85 0.225 0.1 0.025]);

h.amplification_checkbox = uicontrol ('style', 'checkbox',
  'units', 'normalized',
  'string', 'amplification',
  'value', 0,
  'callback', @update_amplification,
  'position', [0.85 0.15 0.1 0.025]);

h.noise_checkbox = uicontrol ('style', 'checkbox',
  'units', 'normalized',
  'string', 'threshold noise',
  'value', 0,
  'callback', @update_noise,
  'position', [0.85 0.175 0.1 0.025]);

h.calib_checkbox = uicontrol ('style', 'checkbox',
  'units', 'normalized',
  'string', 'calibration',
  'value', 1,
  'callback', @update_calib,
  'position', [0.85 0.125 0.1 0.025]);

h.feedback_button = uicontrol ('style', 'pushbutton',
  'units', 'normalized',
  'string', 'feedback',
  'callback', @measure_feedback,
  'position', [0.85 0.05 0.1 0.05]);


guidata(gcf, h);
update_calib(gcf);
update_amplification(gcf);
update_gaintable(gcf);
update_noise(gcf);
update_playback(gcf);
update_live(gcf);
