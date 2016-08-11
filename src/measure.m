%-----------------------------------MEASURE.M-----------------------------------

%{
	> [File Name] measure.m
	> [Platform] Octave GNU
	> [Version] alpha
	> [Author] Richard
	> [Date] 10/08/2016
	> [Language] .m file
	> [Description] Records and computes the harmonic response and several
	> distortion rates to a given frequency calling "analyse.m" function
%}


function measure(f, order,boolPlot)
	
	%assertion
	if nargin < 2
		order = 3;
		boolPlot = 0;
	elseif nargin < 3	
		boolPlot = 0;
	%else exit;
	endif
	
	f = min(max(f,10),30000);
	order = min(max(order,1),4);
	
	Fmax = 2*order*f; % x2 because I can...
	
	Fs = min(max(2*Fmax,1000),192000); %sampling rate (1kHz<Fs<192kHz)
	df = f/50; % df : 20pts per harmonic
	N = ceil(Fs/df); %number of samples
	T = min(2*max(N/Fs,0.2),6); % min observation period

	%recording @ <Fs>Hz sample rate, 16 bits, mono
	recorder = audiorecorder (Fs, 16, 1);

	record (recorder);
	sleep(T);

	%retrieving the data
	data = getaudiodata(recorder);    
	stop(recorder);

	%extract the response signal
	signal = data(end-N:end-1); %if wanted, use a window here
	[fourier, H, THD, SNR] = analyze(signal, Fs, f, order);
	
	if boolPlot
		clf; %clear previous plots
		plot(fourier(1,2:end),(fourier(2,2:end)));
			title('FFT')
			xlabel('f (Hz)')
			ylabel('|S(f)|')
			axis ([10 (order+1)*f]);
	endif
	
	printf('Fundamental (%u Hz): %d dB\n\r',f,20*log10(H(1)));
	for i = 2:order
		printf('F_%u (%u Hz): %d dB\n\r',i-1,i*f,20*log10(H(i)));
	endfor
	printf('THD+N : %d %%\n\rSNR : %d dB\n\r',THD,SNR);

endfunction
%--------------------------------------EOF--------------------------------------