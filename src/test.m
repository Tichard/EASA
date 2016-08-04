1;
%{
  [params,yest,yres,rmserr] = sinefit(data,t,freq,verbose,plot_flag);
  INPUTS :
  data =
  OUTPUTS :
  params(1)	Estimated sine wave DC offset.
  params(2)	Estimated sine wave amplitude.
  params(3)	Estimated sine wave frequency in Hz.
  params(4)	Estimated sine wave phase in radians.
  yest	Estimated sine wave vector.
  yres	Residual signal vector.
  rmserr	RMS of the residual signal.

 
Ts = 1/Fe;
n = numel(data);
t=(0:n-1)*Ts;
  
[params,yest,yres,rmserr] = sinefit(data,t,freq,verbose,plot_flag);
%}


%{
io  : 1 -> input
    : 0 -> output

id = audiodevinfo (io, rate, bits, chans);
id = audiodevinfo (io, name);


recorder = audiorecorder (fs, nbits, channels, id);
record (recorder);
getaudiodata (recorder);

player = audioplayer (y, fs, nbits, id)
play (player);
stop (player);

record (sec, fs);

%}
Fs = 48000;

df = 0.5;
N = Fs/df;
t = 0:1/Fs:(N-1)/Fs;

sinu = [];
i = 1;
for p = 0:1
  for u = 1:df:9.5
    f = u*10^p;
    sinu = [sinu cos(2*pi*f*t)];
    Freq(i) = f;
  endfor
endfor

time = length(sinu)/Fs;

player = audioplayer (sinu, Fs);
play (player);;
signal = aurecord (time, Fs, 1);

auplot(signal(:,1),Fs);
title('record')
xlabel('t (ms)')
ylabel('A')