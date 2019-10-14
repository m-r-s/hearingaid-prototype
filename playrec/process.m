function out = process(in, fs, M, N, FFTN)

if nargin > 1
  calibration = 100 - 10*log10(FFTN*M/2);

  cfreqs = [75 125 250 500 1000 2000 4000 8000 16000]./fs;
  gaintablecomp = 30*linspace(1,0,100).' .* ones(1,length(cfreqs)-2);
  gaintablezero = zeros(100,length(cfreqs)-2);
  gaintable = [gaintablecomp gaintablecomp]-10;
  overlapadd(zeros(M,2), N, 2);
  compress(zeros(N,2), FFTN, cfreqs, gaintable, calibration);
else
  out = overlapadd(in);
end
