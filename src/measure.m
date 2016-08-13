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


function measure(f, n, boolPlot)
	
	%assertion
	if nargin < 2
		n = 0;
		boolPlot = 0;
	elseif nargin < 3	
		boolPlot = 0;
	%else exit;
	endif
	
	f = min(max(f,10),30000);
	order = min(max(n+1,1),4);
	
	Fmax = order*f;
	
	Fs = 192000; %sampling rate (48kHz<Fs<192kHz)
	df = 1; % 1Hz precision
	N = ceil(Fs/df); %number of samples
	T = 2/df;
	
	%recording @ <Fs>Hz sampling rate, 16 bits, mono
	recorder = audiorecorder (Fs, 16, 1);

	record (recorder);
	sleep(T);

	%retrieving the data
	data = getaudiodata(recorder);    
	stop(recorder);

	%extract the response signal
	signal = data(end-N:end-1);%.* blackmanharris(N); %Blackman-Harris window
	
	[fourier, H, THD, SNR] = analyze(signal, Fs, f, order);
	
	if boolPlot
		clf; %clear previous plots
		plot(fourier(1,:),fourier(2,:),fourier(1,:),fourier(3,:));
			title('FFT')
			xlabel('f (Hz)')
			ylabel('|S(f)|')
			axis ([0 (order+1)*f]);
	endif
	
	printf('Fundamental (%u Hz): %d dBV\n\r',f,20*log10(H(1)));
	for i = 2:order
		printf('Harmonic %u (%u Hz): %d dBV\n\r',i-1,i*f,20*log10(H(i)));
	endfor
	printf('THD+N : %d %%\n\rSNR : %d dBV\n\r',THD,SNR);

endfunction

%--------------------------------------EOF--------------------------------------