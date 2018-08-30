% Copyright 2018 Marc René Schädler
%
% This file is part of the mobile hearing aid prototype project
% The the mobile hearing aid prototype project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
%
% The mobile hearing aid prototype project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with the mobile hearing aid prototype project. If not, see http://www.gnu.org/licenses/.

function [threshold, values, reversals, measures, presentations, answers, adjustments, offsets] =...
  siam(presentationhandle, answerhandle, target, minreversals, discardreversals, minmeasures, startvalue, steps, feedback)

% This function implements the single‐interval adjustment‐matrix (SIAM) procedure for unbiased adaptive testing [1].
% [1] Kaernbach, C. (1990). A single‐interval adjustment‐matrix (SIAM) procedure for unbiased adaptive testing. The Journal of the Acoustical Society of America, 88(6), 2645-2655.

% Example config  
%  target = 0.75;
%  minreversals = 14;
%  discardreversals = 4;
%  minmeasures = 25;
%  startvalue = 10;
%  steps = [4 4 2 1];
%  feedback = 1;

% Initial values
value = startvalue;
direction = [];
count = 0;

threshold = [];
values = [];
reversals = [];
measures = [];
presentations = [];
answers = [];
adjustments = [];
offsets = [];

adjustment_matrix = [-1 target./(1-target); 1./(1-target) 0];
minstep = min(min(abs(adjustment_matrix(abs(adjustment_matrix)>0))));
adjustment_matrix = adjustment_matrix ./ minstep;

assert(discardreversals>=0 && discardreversals<minreversals);
assert(minmeasures >= 1);

% Measure loop
while sum(abs(reversals))<minreversals || sum(presentations(measures==1))<minmeasures
  count = count + 1;
  
  % Present random stimulus after third presentation
  if count < 4
    presentation = 1;
  else
    presentation = round(rand(1));
  end
  offset = presentationhandle(presentation, value);
  presentations(count) = presentation;
  values(count) = value;
  offsets(count) = offset;
  
  % Get answer
  answer = answerhandle(count, presentation, value);

  if isempty(answer)
    return
  end
  answers(count) = answer;
  
  % Determine adjustment
  adjustment = adjustment_matrix(2-presentation, 2-answer) .* steps(min(1+sum(abs(reversals)),end));
  adjustments(count) = adjustment;
  
  % Apply adjustment
  value = value + adjustment;
  
  % Detect reversals
  if isempty(direction) && adjustment ~= 0
    direction = adjustment;
  elseif (adjustment>0 && direction<0) || (adjustment<0 && direction>0)
    direction = adjustment;
    reversals(count) = sign(direction);
  else
    reversals(count) = 0;
  end
  
  % Mark measures
  if sum(abs(reversals)) > discardreversals
    measures(count) = 1;
  else
    measures(count) = 0;
  end
end

% Evaluate measurement
if sum(abs(reversals))>=minreversals && sum(measures)>=minmeasures
  reversalvalues = values(logical(abs(reversals)));
  usereversalvalues = reversalvalues(1+discardreversals:end);
  threshold = median(usereversalvalues);
end
end

