close all
clear
clc

thresholds_freqs = [125 250 500 1000 2000 4000 8000 16000];
thresholds = [50 50 50 55 60 65 65 65;50 50 50 55 60 65 65 65];

plot_freqs = 1000 .* 2.^(-3:0.5:4);
normal_hearing_threshold = hl2spl(plot_freqs, 0);
plot_levels = 0:5:100;
plot_colors = jet(length(plot_levels)).*0.8;

figure('Position', [ 500 200 1200 800],
       'NumberTitle', 'off',
       'Name', 'Simple self-fitting GUI',
       'toolbar', 'none',
       'menubar', 'none');

h.thresholds_freqs = thresholds_freqs;
h.thresholds = thresholds;
h.plot_freqs = plot_freqs;
h.normal_hearing_threshold = normal_hearing_threshold;
h.plot_levels = plot_levels;
h.plot_colors = plot_colors;

figure_positions = {[0.075 0.4 0.4 0.5],[0.55 0.4 0.4 0.5]};
position_title = {'L E F T', 'R I G H T'};
for i=1:2
  h.ax(i) = axes ('position', figure_positions{i});
  box('on');
  plot(log(thresholds_freqs), hl2spl(thresholds_freqs,thresholds(i,:)),'-k','linewidth',2);
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

function send_gaintable(gt_data)
  system(['echo "mha.transducers.mhachain.altplugs.dynamiccompression.mhachain.dc.gtdata = ',gt_data2string(gt_data),'" | nc -w 1 127.0.0.1 33337 | grep -m1 -E "\(MHA:[^)]+\)"']);
end

function update_plot (obj)
  tic
  h = guidata (obj);
  offset = 30+30.*(0.5-get(h.offset_slider,'value'));
  rolloff = 1+2.^-(get(h.rolloff_slider,'value').*3);
  marginfactor = get(h.marginfactor_slider,'value');
  center = 50+get(h.center_slider,'value').*40;
  focus = round(get(h.focus_slider,'value').*100)./10;
  [gt_data, gt_freqs, gt_levels] = prescription_minimalistic(h.thresholds_freqs, h.thresholds(1,:), h.thresholds(2,:), offset, marginfactor, rolloff, center, focus);
  for i=1:2
    gain = interp2(gt_levels,gt_freqs.',gt_data(1+(i-1).*length(gt_freqs):i.*length(gt_freqs),:),h.plot_levels.',h.plot_freqs,'linear');
    for j=1:length(h.plot_levels)
      set(h.h_activedata{i}(j),'ydata',h.plot_levels(j)+gain(:,j));
    end
  end
  send_gaintable(gt_data);
  toc
end

uicontrol ('style', 'text',
  'units', 'normalized',
  'string', 'gain' ,
  'horizontalalignment', 'left',
  'position', [0.1 0.25 0.15 0.05]);

h.offset_slider = uicontrol ('style', 'slider',
  'units', 'normalized',
  'sliderstep', [0.1 0.1],
  'string', 'slider',
  'callback', @update_plot,
  'value', 0.5,
  'position', [0.2 0.25 0.7 0.05]);

uicontrol ('style', 'text',
  'units', 'normalized',
  'string', 'compression' ,
  'horizontalalignment', 'left',
  'position', [0.1 0.2 0.15 0.05]);

h.rolloff_slider = uicontrol ('style', 'slider',
  'units', 'normalized',
  'sliderstep', [0.1 0.1],
  'string', 'slider',
  'callback', @update_plot,
  'value', 0.5,
  'position', [0.2 0.2 0.7 0.05]);

uicontrol ('style', 'text',
  'units', 'normalized',
  'string', 'boost factor' ,
  'horizontalalignment', 'left',
  'position', [0.1 0.15 0.15 0.05]);
          
h.marginfactor_slider = uicontrol ('style', 'slider',
  'units', 'normalized',
  'sliderstep', [0.1 0.1],
  'string', 'slider',
  'callback', @update_plot,
  'value', 0.5,
  'position', [0.2 0.15 0.7 0.05]);

uicontrol ('style', 'text',
  'units', 'normalized',
  'string', 'boost level' ,
  'horizontalalignment', 'left',
  'position', [0.1 0.1 0.15 0.05]);

h.center_slider = uicontrol ('style', 'slider',
  'units', 'normalized',
  'sliderstep', [0.1 0.1],
  'string', 'slider',
  'callback', @update_plot,
  'value', 0.5,
  'position', [0.2 0.1 0.7 0.05]);
  
uicontrol ('style', 'text',
  'units', 'normalized',
  'string', 'focus' ,
  'horizontalalignment', 'left',
  'position', [0.1 0.05 0.15 0.05]);

h.focus_slider = uicontrol ('style', 'slider',
  'units', 'normalized',
  'sliderstep', [0.1 0.1],
  'string', 'slider',
  'callback', @update_plot,
  'value', 0.5,
  'position', [0.2 0.05 0.7 0.05]);
                            
guidata (gcf, h);
update_plot (gcf);
