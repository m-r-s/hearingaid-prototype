function out = overlapadd(in, set_N, set_M)
  % Use persistent variables to implement buffers
  persistent N;
  persistent M;
  persistent num_samples;
  persistent num_channels;
  persistent window;
  persistent in_buffer;
  persistent out_buffer;
  
  % Everything that can be pre-calculated should
  % be calculated only once; HERE!
  if nargin > 1
    % Set "constants"
    N = set_N;
    M = set_M;
    [num_samples num_channels] = size(in);
    % Windowing function
    window = sqrt(hanning(N,'periodic')) .* sqrt(2.*num_samples./N);
    % Initialize buffers with zeros
    in_buffer = zeros(N,M);
    out_buffer = zeros(N,M);
    return;
  end
  
  % Shift input and output
  in_buffer = [in_buffer((num_samples+1):N,:); in];
  out_buffer = [out_buffer((num_samples+1):N,:); zeros(num_samples,num_channels)];
  
  % Select data to process
  in_tmp = in_buffer .* window;
  
  % Process data
  out_tmp = compress(in_tmp);
  
  % Apply remaining part of window
  out_tmp = out_tmp .* window;
  
  % Write processed data to output buffer
  out_buffer = out_buffer + out_tmp; 
  
  % Return oldest processed samples for playback
  out = out_buffer(1:num_samples,:);
end
