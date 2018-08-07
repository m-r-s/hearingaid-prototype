function gt_data = prescription_minimalistic(freqs, thresholds_left, thresholds_right, offset, factor, rolloff)
  gt_freqs = [250 500 1000 1500 2000 3000 4000 6000 8000];
  gt_levels = -10:1:110;
  reference_freqs  = [125 250 500 1000 2000 4000 8000 16000];
  reference_levels = [ 20  10   0    0    0    0   10    20]+offset;
  thresholds_left_ext = [0 0 thresholds_left 0 0];
  thresholds_right_ext = [0 0 thresholds_right 0 0];
  freqs_ext = [0 50 freqs 16000 48000];
  gt_data_left = zeros(length(gt_levels),length(gt_freqs));
  gt_data_right = zeros(length(gt_levels),length(gt_freqs));
  maxgain = 40;
  for i=1:length(gt_freqs)
    reference_level = interp1(reference_freqs,reference_levels,gt_freqs(i),'extrap');
    threshold_level_left = interp1(freqs_ext,thresholds_left_ext,gt_freqs(i),'extrap');
    threshold_level_right = interp1(freqs_ext,thresholds_right_ext,gt_freqs(i),'extrap');
    low_level_gain_left = min(maxgain,factor.*max(0,threshold_level_left-reference_level))
    low_level_gain_right = min(maxgain,factor.*max(0,threshold_level_right-reference_level));
    gt_data_left(:,i) = interp1([gt_levels(1);reference_level;reference_level+low_level_gain_left.*rolloff;gt_levels(end)],[low_level_gain_left;low_level_gain_left;0;0],gt_levels);
    gt_data_right(:,i) = interp1([gt_levels(1);reference_level;reference_level+low_level_gain_right.*rolloff;gt_levels(end)],[low_level_gain_right;low_level_gain_right;0;0],gt_levels);
  end
  gt_data = [gt_data_left.';gt_data_right.'];
end
