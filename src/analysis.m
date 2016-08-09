clear;
clc;
clf;
1;

%------------------------------FUNCTION-------------------------------

function v = rms(signal)
	%computes the RMS in time domain
	v = norm(signal)/sqrt(length(signal));
endfunction

function [fourier, H, THD, SNR] = analyze(signal, Fs, fgen, order)
	N = length(signal); %number of samples
	t = 0:1/Fs:(N-1)/Fs; %time vector
	f = (0:N/2-1)*Fs/N; %frequency vector
	
	tf = 2*abs(fft(signal)/N); %fft in complex domain
	tfreal = tf(1:N/2); %fft in real domain
	
	H = zeros(1,order);	
	for o = 1:order  %for all harmonics
		index = ceil(o*fgen*N/Fs); %index of the frequency
		if index < 3
		H(o) = max(tfreal(index:index+2));
		elseif index < N/2
		H(o) = max(tfreal(index-2:index+2));
		else H(o) = NaN;
		endif
	endfor
	
	fourier(1,:) = f;
	fourier(2,:) = tfreal;
	
	% fundamental frequency injected in the system
	fund = (H(1)*cos(2*pi*fgen*t))';
	% parasite signal created by the system (harmonics + noise)
	hn = signal - fund;
  
	if H(2)!= NaN
		%THD(1) = 100*sqrt(sum(H(2:order).^2))/H(1); %THD_F
		THD = 100*sqrt(sum(H(2:order).^2)/sum(H(1:order).^2)); %THD_R
		%THD(3) = rms(hn)/rms(fund); %THD+N
	else THD = NaN;
	endif
	
	SNR = 20*log10(rms(fund)/rms(hn)); %SNR to dB
	
endfunction

function sweep(Fs,low,high,order,boolPlot)
  
	a = floor(log10(low));
	b = floor(log10(high));
	
	df = (10^a)/2; % df : biggest value < smallest step
	N = Fs/df; %number of samples
	T = (N+1)/Fs; % min observation period
	t = 0:1/Fs:2*T-(1/Fs); %time vector

	%recording @ <Fs>Hz sample rate, 16 bits, mono
	recorder = audiorecorder (Fs, 16, 1);
  
	i = 1;
	for p = a:b
		for u = 1:0.5:9.5
			f = u*10^p;
			sinu = cos(2*pi*f*t);
			
			%playing the frequency @ <Fs>Hz sample rate
			player = audioplayer (sinu, Fs);
			%record the response signal
			play (player);
			record (recorder);
			while isplaying(player)
			endwhile
			
			%retrieving the data
			data = getaudiodata(recorder);    
			stop(player);
			
			signal = data(end-N:end-1); %extract the response signal
			[fourier, H, THD, SNR] = analyze(signal, Fs, f, order);
			
			%computing the data
			r(1,i) = f;
			r(2,i) = 20*log10(H(1));
			r(3,i) = 20*log10(H(2));
			r(4,i) = 20*log10(H(3));
			r(5,i) = THD;
			r(6,i) = SNR;
			i++;      
		endfor
	endfor 
  
	if boolPlot
		subplot(211),
			semilogx(r(1,:),r(2,:),'k',r(1,:),r(3,:),'r',r(1,:),r(4,:),'g');
			title('Harmonic Response')
			xlabel('f (Hz)')
			ylabel('dB')
			legend('F_0','F_1','F_2')
			grid on
			axis ([low high]);
		subplot(212),
			w = plotyy (r(1,:), r(5,:), r(1,:), r(6,:), @semilogx);
			title('Distortion measures') 
			xlabel('f (Hz)')
			ylabel(w(1),'%')
			ylabel(w(2),'dB')
			legend('THD_R','SNR_d_B')
			grid on
			axis (w(1), [low high 0 100])
			axis (w(2), [low high]);
	endif
  
	stop(player);
	stop(recorder);
endfunction

%------------------------------SCRIPT---------------------------------

Fs = 96000;
order = 4;
low = 10;
high = 20000;

sweep(Fs,low,high,order,1);
