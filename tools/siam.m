function [threshold, values, reversals, measures, presentations, answers, adjustments, offsets] =...
  siam(presentationhandle, answerhandle, target, minreversals, discardreversals, minmeasures, startvalue, steps, feedback)

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

