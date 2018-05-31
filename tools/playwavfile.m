function playwavfile(filename, ear, device)
  % Get audio data
  [signal, fs] = audioread(filename);
  if isempty(signal)
    error('Could not read wav file');
  end
  
  % Find device ID for audio playback
  playdev = audiodevinfo(0,sprintf('%s (JACK Audio Connection Kit)',device));
  if isempty(playdev)
    error(sprintf('Could not find playback device: %s\n',device));
  end

  if size(signal,2) < 2
    % Compose signal for left, right, or both ears
    switch ear
      case 'l'
        signal = [signal, zeros(size(signal))];
      case 'r'
        signal = [zeros(size(signal)), signal];
      case 'b'
        signal = [signal, signal];
      otherwise
        error('unknown ear definition (l/r/b)');
    end
  end
  
  if size(signal,2) > 2
    error('More than 2 channels not supported');
  end

  % Playback with 24bit samples on "playdev" (depends on capabilities of device, choose highest possible)
  signal = [signal; zeros(round(0.2.*fs),2)];
  player = audioplayer(signal, fs, 24, playdev);
  play(player);
  pause(size(signal,1)./fs);
  stop(player);
  pause(0.1);
end
