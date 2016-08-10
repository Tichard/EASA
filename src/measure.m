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
	
	order = min(max(order,1),4);
	
	Fmax = 4*order*f;
	
	Fs = min(max(Fmax,1000),192000) %sampling rate (1kHz<Fs<192kHz)
	df = f/2; % df : biggest value < smallest step
	N = ceil(Fs/df); %number of samples
	T = N/Fs; % min observation period

	%recording @ <Fs>Hz sample rate, 16 bits, mono
	recorder = audiorecorder (Fs, 16, 1);

	record (recorder);
	sleep(1);

	%retrieving the data
	data = getaudiodata(recorder);    
	stop(recorder);

	signal = data(end-N:end-1); %extract the response signal
	[fourier, H, THD, SNR] = analyze(signal, Fs, f, order);
	
	plot(fourier(1,:),fourier(2,:));
	printf('F_0 : %d dB\n\rF_1 : %d dB\n\rF_2 : %d dB\n\rTHD : %d %%\n\rSNR : %d dB\n\r',
			H(1),H(2),H(3),THD,SNR);

endfunction
%--------------------------------------EOF--------------------------------------