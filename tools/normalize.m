% Copyright 2018 Marc René Schädler
%
% This file is part of the mobile hearing aid prototype project
% The the mobile hearing aid prototype project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
%
% The mobile hearing aid prototype project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with the mobile hearing aid prototype project. If not, see http://www.gnu.org/licenses/.

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
