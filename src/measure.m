%-----------------------------------MEASURE.M-----------------------------------

%{
	> [File Name] measure.m
	> [Platform] Octave GNU
	> [Version] 1.00
	> [Author] Richard
	> [Date] 10/08/2016
	> [Language] .m file
	> [Description] Records and computes the harmonic response and several
	> distortion rates to a given frequency calling "analyse.m" function
%}


function measure(f, order)
	
	%assertion
	if nargin < 2
		order = 3;
	%else exit;
	endif
	
	f = min(max(f,10),30000);
	order = min(max(order,1),4);
	
	Fmax = 2*order*f;
	
	Fs = min(max(2*Fmax,1000),192000); %sampling rate (1kHz<Fs<192kHz)
	df = f/50; % df : 20pts per harmonic
	N = ceil(Fs/df); %number of samples
	T = min(2*max(N/Fs,0.5),6); % min observation period

	%recording @ <Fs>Hz sample rate, 16 bits, mono
	recorder = audiorecorder (Fs, 16, 1);

	record (recorder);
	sleep(T);

	%retrieving the data
	data = getaudiodata(recorder);    
	stop(recorder);

	signal = data(end-N:end-1); %extract the response signal
	[fourier, H, THD, SNR] = analyze(signal, Fs, f, order);
	
	plot(fourier(1,2:end),(fourier(2,2:end)));
		title('FFT')
		xlabel('f (Hz)')
		ylabel('|S(f)|')
		axis ([10 (order+1)*f]);
		
	for i = 1:order
		printf('F_%u (%u Hz): %d dB_rel\n\r',i-1,i*f,20*log10(H(i)/H(1)));
	endfor
	printf('THD+N : %d %%\n\rSNR : %d dB\n\r',THD,SNR);

endfunction
%--------------------------------------EOF--------------------------------------