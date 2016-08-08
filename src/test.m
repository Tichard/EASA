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

function v = rms(spectrum)
  %computes the RMS in frequency domain
  v = sum(abs(spectrum).^2)/length(spectrum);
endfunction

function [fourier, H, THD] = analyze (signal, Fs, fgen, order)
  N = length(signal)
  t = 0:1/Fs:(N-1)/Fs;
  f = (0:N/2-1)*Fs/N;
  tf = 2*abs(fft(signal)/N);
  tfreal = tf(1:N/2);
  
  H = zeros(1,order);
  
  for o = 1:order
	index = ceil(o*fgen*N/Fs);
	if index < 5
	  H(o) = max(tfreal(index:index+5));
	elseif index < N/2
	  H(o) = max(tfreal(index:index+5));
	else H(o) = NaN;
	endif
  endfor
  
  fourier(1,:) = f;
  fourier(2,:) = tfreal;
  
  % fundamental frequency injected in the system
  fund = H(1)*cos(2*pi*fgen*t);
  % parasite signal created by the system
  hn = signal - fund;
  
  if H(2)!= NaN
	THD(1) = 100*sqrt(sum(H(2:order).^2))/H(1);
	THD(2) = 100*sqrt(sum(H(2:order).^2)/sum(H(1:order).^2));
	THD(3) = rms(hn)/rms(fund);
	else THD = [NaN NaN NaN];
  endif
endfunction


Fs = 48000;
order = 4;
low = 10;
high = 20000;

a = floor(log10(low));
b = floor(log10(high));

df = (10^a)/2; % df : biggest value < smallest step
N = Fs/df
T = (N+1)/Fs; % min observation period
t = 0:1/Fs:2*T-(1/Fs);

%recording @ <Fs>Hz sample rate, 8 bits, stereo
recorder = audiorecorder (Fs, 16, 1)

f = 440;
sinu = cos(2*pi*f*t);

%playing the frequency @ <Fs>Hz sample rate
player = audioplayer (sinu, Fs);
%record the response signal
play (player);
record (recorder);
pause(T);

%retrieving the data
signal = getaudiodata(recorder);    
stop(player);

plot(signal);
%computing the data
[fourier, H, THD] = analyze(signal, Fs, f, order);