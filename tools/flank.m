% Copyright 2018 Marc René Schädler
%
% This file is part of the mobile hearing aid prototype project
% The the mobile hearing aid prototype project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
%
% The mobile hearing aid prototype project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with the mobile hearing aid prototype project. If not, see http://www.gnu.org/licenses/.

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
