%-----------------------------------ANALYZE.M-----------------------------------

%{
	> [File Name] analyze.m
	> [Platform] Octave GNU
	> [Version] 1.00
	> [Author] Richard
	> [Date] 10/08/2016
	> [Language] .m file
	> [Description] Computes the harmonic response and several distortion rates 
	> from a response signal to a 'fgen' Hz sinewave sampled at 'Fs' Hz
%}


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
		elseif index+2 < N/2
		H(o) = max(tfreal(index-2:index+2));
		else H(o) = 0.001;
		endif
	endfor
	
	fourier(1,:) = f;
	fourier(2,:) = tfreal;
	
	% fundamental frequency injected in the system
	fund = (H(1)*cos(2*pi*fgen*t))';
	% parasite signal created by the system (harmonics + noise)
	hn = signal - fund;
	
	%THD(1) = 100*sqrt(sum(H(2:order).^2))/H(1); %THD_F
	THD = 100*sqrt(sum(H(2:order).^2)/sum(H(1:order).^2)); %THD_R
	%THD(3) = rms(hn)/rms(fund); %THD+N
		
	SNR = 20*log10(rms(fund)/rms(hn)); %SNR to dB
	
endfunction

function v = rms(signal)
	%computes the RMS in time domain
	v = norm(signal)/sqrt(length(signal));
endfunction

%--------------------------------------EOF--------------------------------------