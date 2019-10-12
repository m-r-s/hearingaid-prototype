function out = process(in, fs, samples)

if nargin > 1
  M = samples;
  N = M*4;
  FFTN = 2.^(nextpow2(N)+1);
  calibration = 100 - 10*log10(FFTN*M/2);

  cfreqs = [75 125 250 500 1000 2000 4000 8000 16000]./fs;
  gaintablecomp = linspace(99,0,100).' .* ones(1,length(cfreqs)-2);
  gaintable = [gaintablecomp gaintablecomp];
  overlapadd(zeros(M,2), N, 2);
  compress(zeros(N,2), FFTN, cfreqs, gaintable, calibration);
else
  out = overlapadd(in);
end
