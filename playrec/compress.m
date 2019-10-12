function out = compress(in, set_FFTN, set_cfreqs, set_gaintable, set_calibration)
  % Use persistent variables to store config
  persistent FFTN;
  persistent cidxoffset;
  persistent cmatrix;
  persistent gaintable;
  persistent calibration;
  
  % Everything that can be pre-calculated should
  % be calculated only once; HERE!
  if nargin > 1
    % Set "constants"
    FFTN = set_FFTN;
    cfreqs = set_cfreqs;
    calibration = set_calibration;
    gaintable = set_gaintable;
    % Assign center frequencies to fft bins
    cidx = interp1(linspace(0,1-1/FFTN,FFTN),1:FFTN,cfreqs,'nearest','extrap');
    % Define frequency bands by weighting FFT coeffients
    cmatrix = zeros(FFTN/2+1,length(cidx)-2);
    for i=2:length(cidx)-1
      cmatrix(cidx(i-1):cidx(i),i-1) = linspace(0,1,cidx(i)-cidx(i-1)+1);
      cmatrix(cidx(i):cidx(i+1),i-1) = linspace(1,0,cidx(i+1)-cidx(i)+1);
    end
    % Calculate offsets for addressing gaintable linearly
    cidxoffset = (0:(length(cidx)-3)).*size(gaintable,1);
    cidxoffset = [cidxoffset;cidxoffset+numel(gaintable)./2];
    % Convert gaintable to factors
    gaintable = 10.^(gaintable./20);
    return;
  end
  
  % Calculate FFT with zero padding
  in_fft = fft(in,FFTN);
  
  % Remove mirror frequencies
  in_fft = in_fft(1:FFTN/2+1,:);
  
  % Calculate power in each band
  in_levels = abs(in_fft.').^2 * cmatrix;
  
  % Convert to dB
  in_levels_db = 10*(log10(in_levels)) + calibration;
  
  % Build linear index to look up corresponding gains
  gaintableidx = 1 + round(min(max(0,in_levels_db),99)) + cidxoffset;
  
  % Project gains back gains to FFT bins
  gains = cmatrix * gaintable(gaintableidx).';
  
  % Apply gains
  in_fft = in_fft .* gains;
  
  % Restore mirror frequencies
  out_fft = [in_fft; conj(in_fft(FFTN/2:-1:2,:))];
  
  % Transform to time domain
  out = ifft(out_fft,FFTN);
  
  % Remove zero-padded portion of the signal
  out = real(out(1:size(in,1),:));
  
end
