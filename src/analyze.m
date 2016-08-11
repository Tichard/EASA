%-----------------------------------ANALYZE.M-----------------------------------

%{
	> [File Name] analyze.m
	> [Platform] Octave GNU
	> [Version] alpha
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
	
	Sc = abs(fft(signal)/N); %fft in complex domain
	S = 2*Sc(1:N/2); %fft in real domain
	
	H = zeros(1,order);	
	for o = 1:order  %for all harmonics
		index = ceil(o*fgen*N/Fs); %index of the frequency
		if index+1 < N/2
			H(o) = max(S(index:index+1));
		else H(o) = 0.0001; % set to -80dB
		endif
	endfor
	
	fourier(1,:) = f;
	fourier(2,:) = S;
	
	% fundamental frequency injected in the system
	f0 = H(1)*sin(2*pi*fgen*t)';
	F0c = 2*abs(fft(f0)/N); %fft in complex domain
	F0 = F0c(1:N/2); %fft in real domain
	
	% parasite signal created by the system (harmonics + noise)
	HN = S - F0; %fft in real domain
	
	% Choose the THD wanted :
	%THD = 100*sqrt(sum(H(2:order).^2))/H(1); %THD_F
	%THD = 100*sqrt(sum(H(2:order).^2)/sum(H(1:order).^2)); %THD_R
	THD = 100*rms(HN)/rms(F0); %THD+N
		
	SNR = 20*log10(rms(F0)/rms(HN)); %SNR to dB
	
endfunction


function v = rms(S)
	%computes the RMS in real frequency domain
	 v = sqrt(sum(S.^2)/2);
endfunction


%--------------------------------------EOF--------------------------------------