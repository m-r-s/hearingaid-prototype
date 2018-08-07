function out = normalize(in, gain)
% usage: out = normalize(in, gain)
%
% in     - signal
% gain   - gain to apply after normalization

if nargin < 2
  gain = 0;
end

norm_factor = sqrt(mean(in.^2));
gain_factor = 10.^(gain./20);
assert(numel(norm_factor)==1);
assert(numel(gain_factor)==1);

out = in.*(gain_factor./norm_factor);
end
