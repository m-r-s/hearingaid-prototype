function mhaplayback(signal, fs)
  audiofile = [tempname('/devshm/') '.wav'];
  audiowrite(audiofile, signal, fs, 'BitsPerSample', 32);
  system(['echo mhaplay "',audiofile,'" relative 130 no > ~/hearingaid-prototype/commandqueue']);
end
