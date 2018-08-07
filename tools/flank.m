function out = flank(in, rise, fall)
% usage: out = flank(in, rise, fall)
%
% in      - signal
% raise   - raise samples
% fall    - fall samples

if nargin < 3 || isempty(fall)
  fall = rise;
end

out = in;  
out(1:rise,:) = bsxfun(@times,in(1:rise,:), flank_samples(0,pi,rise));
out(1+end-fall:end,:) = bsxfun(@times,in(1+end-fall:end,:), flank_samples(pi,0,fall));
end

function out = flank_samples(start,stop,samples)
out = 0.5 .* (1-cos(linspace(start,stop,samples))).';
end
