clear;
clc;
clf;
1;
%------------------------------FUNCTION-------------------------------

function [fourier, H, THD] = analyze (signal, Fs, fgen, order)
  N = length(signal);
  %frqmax = round((order+1)*fgen*N/Fs);

  t = 0:1/Fs:(N-1)/Fs;
  f = (0:N/2-1)*Fs/N;

  tf = 2*abs(fft(signal)/N);
  tfreal = tf(1:N/2);
  
  H = zeros(1,order);

  for o = 1:order
    index = ceil(o*fgen*N/Fs);
    if index < N/2
      H(o) = max(tfreal(index:index+1));
    else H(o) = NaN;
    endif
  endfor
  
  fourier(1,:) = f;
  fourier(2,:) = tfreal;

  THD(1) = 100*sqrt(sum(H(2:order).^2))/H(1);
  THD(2) = 100*sqrt(sum(H(2:order).^2))/sqrt(sum(H.^2));
  THD(3) = sqrt(sum(H(2:order).^2))/H(1);

  
endfunction


function sweep(Fs,order,boolPlot)
  
  df = 0.5;
  
  N = Fs/df;
  z = NaN*ones(1,2*order);
  t = 0:1/Fs:(N-1)/Fs;
  
  if nargin <2
    boolPlot = 0;
  endif
    
  % signal generating
  %start recording
  %start playing
  %
  %stop recording
    
  
  i = 1;
  for p = 0:4
    for u = 1:df:9
      f = u*10^p;
      signal = ((1+0.02*rand)*cos(2*pi*f*t)+(0.6+0.05*rand)*cos(2*pi*2*f*t)+(0.2+0.08*rand)*cos(2*pi*3*f*t)+0.1*rand);
      [fourier, H, THD] = analyze(signal, Fs, f, order);
      r(1,i) = f;
      r(2,i) = 20*log10(H(1));
      r(3,i) = 20*log10(H(2));
      r(4,i) = 20*log10(H(3));
      r(5,i) = THD(1);
      r(6,i) = THD(2);
      r(7,i) = THD(3);
      i++;
      endfor
  endfor
  
  
  if boolPlot
    subplot(211)
    semilogx(r(1,:),r(2,:),'k',r(1,:),r(3,:),'r',r(1,:),r(4,:),'g');
    title('Harmonic Response')
    axis ([1 30000 -18 6])
    xlabel('f (Hz)')
    ylabel('dB')
    
    subplot(212)
    semilogx(r(1,:),r(5,:),'k',r(1,:),r(6,:),'r',r(1,:),r(7,:),'g');
    title('THD')
    xlabel('f (Hz)')
    ylabel('%')
  endif

endfunction


%--------------------------------CODE---------------------------------

Fs = 48000;
N = 96000;
order = 3;

boolPlot =1;

sweep(Fs,order,boolPlot)
