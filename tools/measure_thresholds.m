function thresholds = measure_thresholds(freqs, ear)
  thresholds = nan(size(freqs));
  for i=1:length(freqs)
    threshold = measure_sweep(freqs(i), ear);
    if ~isempty(threshold)
      thresholds(i) = threshold;
    end
  end
end

