clear;
clc;
clf;
1;
%------------------------------FUNCTION-------------------------------

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

function sweep(Fs,low,high,order,boolPlot)
  
  a = floor(log10(low));
  b = floor(log10(high));
  
  df = (10^a)/2; % df : biggest value < smallest step
  N = Fs/df
  T = (N+1)/Fs; % min observation period
  t = 0:1/Fs:2*T-(1/Fs);
  
  %recording @ <Fs>Hz sample rate, 8 bits, stereo
  recorder = audiorecorder (Fs, 16, 1)
  
  i = 1;
  for p = a:b
	for u = 1:05:9.5
	f = u*10^p;
	sinu = cos(2*pi*f*t);
  
	%playing the frequency @ <Fs>Hz sample rate
	player = audioplayer (sinu, Fs);
	%record the response signal
	play (player);
	record (recorder);
	sleep(T);
  
	%retrieving the data
	signal = getaudiodata(recorder);    
	stop(player);    
  
	%computing the data
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
	subplot(211),
	  semilogx(r(1,:),r(2,:),'k',r(1,:),r(3,:),'r',r(1,:),r(4,:),'g');
	  title('Harmonic Response')
	  axis ([low high])
	  xlabel('f (Hz)')
	  ylabel('dB')
	  legend('F_0','F_1','F_2');
	subplot(212),
	  semilogx(r(1,:),r(6,:),'r',r(1,:),r(7,:),'g');
	  title('THD')      
	  axis ([low high])
	  xlabel('f (Hz)')
	  ylabel('%')
	  legend('THD_R','THD+N');
  endif
  
  stop(player);
  stop(recorder);
endfunction

%------------------------------SCRIPT---------------------------------
Fs = 48000;
order = 4;
low = 10;
high = 20000;

sweep(Fs,low,high,order,1);
