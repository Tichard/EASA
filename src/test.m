1;
clear;
clc;
clf;

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



Fs = 48000;
order = 3;
low = 10;
high = 50000;


a = floor(log10(low));
b = floor(log10(high));  

df = 1; % df : biggest value < smallest step
N = high/df
T = N/Fs; % min observation period
t = 0:1/Fs:(N-1)/Fs;

sinu = [];
i = 1;
for p = a:b
for u = 1:df:9.5
  f = u*10^p;
    
  sinu = [sinu cos(2*pi*f*t)];
      
  endfor
endfor 


%recording @ <Fs>Hz sample rate, 8 bits, stereo
%recorder = audiorecorder (Fs, 16);
%playing the frequency @ <Fs>Hz sample rate
player = audioplayer (sinu, Fs);
%record the response signal
play (player);
%record (recorder);
%while isplaying(player)
%endwhile        
%retrieving the data
%data = getaudiodata(recorder);     
%stop(player); 