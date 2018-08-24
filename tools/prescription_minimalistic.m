function [gt_data, gt_freqs, gt_levels] = prescription_minimalistic(freqs, thresholds_left, thresholds_right, offset, marginfactor, rolloff)
  gt_freqs = [250 500 1000 1500 2000 3000 4000 6000 8000];
  gt_levels = -10:1:110;
  reference_freqs  = [125 250 500 1000 2000 4000 8000 16000];
  reference_levels = [ 50  40  30   30   30   40   50    60]+offset;
  thresholds_left_ext = [0 0 thresholds_left 0 0];
  thresholds_right_ext = [0 0 thresholds_right 0 0];
  freqs_ext = [0 50 freqs 16000 48000];
  gt_data_left = zeros(length(gt_levels),length(gt_freqs));
  gt_data_right = zeros(length(gt_levels),length(gt_freqs));
  maxgain = 40;
  maxlevel = 100;
  for i=1:length(gt_freqs)
    reference_level = interp1(reference_freqs,reference_levels,gt_freqs(i),'extrap');
    threshold_level_left = interp1(freqs_ext,thresholds_left_ext,gt_freqs(i),'extrap');
    threshold_level_right = interp1(freqs_ext,thresholds_right_ext,gt_freqs(i),'extrap');
    low_level_gain_left = min(maxgain,max(0,threshold_level_left-reference_level));
    low_level_gain_right = min(maxgain,max(0,threshold_level_right-reference_level));
    margin_left = marginfactor.*(70-(reference_level+low_level_gain_left));
    margin_right = marginfactor.*(70-(reference_level+low_level_gain_right));
    gt_data_left(:,i) = interp1([gt_levels(1);reference_level+margin_left;reference_level+margin_left+low_level_gain_left.*rolloff;gt_levels(end)],[low_level_gain_left;low_level_gain_left;0;0],gt_levels);
    gt_data_right(:,i) = interp1([gt_levels(1);reference_level+margin_right;reference_level+margin_right+low_level_gain_right.*rolloff;gt_levels(end)],[low_level_gain_right;low_level_gain_right;0;0],gt_levels);
  end
  gt_data = [gt_data_left.';gt_data_right.'];
  gt_data = gt_data + min(0,maxlevel - (gt_data+gt_levels));
end
