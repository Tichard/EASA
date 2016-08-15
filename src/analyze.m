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
		endif
	endfor
	
	% parasite signal created by the system (harmonics + noise)
	HN = S;
	i = ceil((fgen*N/Fs));
	HN(i:i+2) = 0; %excluding fundamental bin
	HN(1:3) = 0; %excluding potentialy VLF and DC bin
	
	
	fourier(1,:) = f;
	fourier(2,:) = S;
	
	% Choose the THD wanted :
	%THD = 100*sqrt(sum(H(2:order).^2))/H(1); %THD_F
	%THD = 100*sqrt(sum(H(2:order).^2)/sum(H(1:order).^2)); %THD_R
	THD = 100*rms(HN)/rms(S); %THD+N
	
	SNR = 20*log10(rms(S)/rms(HN)); %SNR to dBV
	
endfunction


function v = rms(S)
	%computes the RMS in real frequency domain
	 v = sqrt(sum(S.^2)/2);
endfunction

%--------------------------------------EOF--------------------------------------