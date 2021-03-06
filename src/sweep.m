%------------------------------------SWEEP.M------------------------------------

%{
	> [File Name] sweep.m
	> [Platform] Octave GNU
	> [Version] alpha
	> [Author] Richard
	> [Date] 15/08/2016
	> [Language] .m file
	> [Description] Generates a stepped frequency sweep and computes 
	> the harmonic response and several distortion rates calling "analyse.m"
	> function
%}


function sweep(low,high,n,boolPlot)
	
	%assertion
	if nargin < 1
		low = 20;
		high = 20000;
		n = 0;
		boolPlot = 1;
	elseif nargin < 3
		n = 0;
		boolPlot = 1;
	elseif nargin < 4
		boolPlot = 1;
	%else exit;	
	endif
	
	if low>high
		tmp = low;
		low = high;
		high = tmp;
	endif
	low = max(low,10);
	high = min(high,30000);
	order = min(max(n+1,1),4);
	
	a = floor(log10(low));
	b = floor(log10(high));
	
	Fmax = order*(10^(b+1));
	
	Fs = 192000; %sampling rate
	df = 1; % df < smallest step
	N = ceil(Fs/df); %number of samples
	T = min(max(2/df,0.3),3);
	t = 0:1/Fs:2*T-(1/Fs); %time vector
	
	%recording @ <Fs>Hz sampling rate, 16 bits, mono
	recorder = audiorecorder (Fs, 16, 1);
	
	i = 1;
	for p = a:b
		for u = 1:0.5:9.5
		
			f = u*10^p; %frequency			
	
			sinu = sin(2*pi*f*t);
			
			%playing the frequency @ <Fs>Hz sample rate
			player = audioplayer (sinu, Fs);
			play (player);
			
			%record the response signal
			record (recorder);
			sleep(T);
			
			%retrieving the data
			data = getaudiodata(recorder);    
			stop(player);
			
			%extract the response signal
			signal = data(end-N:end-1);%.* blackmanharris(N); %Blackman-Harris window
			[fourier, H, THD, SNR] = analyze(signal, Fs, f, order);
			
			%computing the data
			r(1,i) = f;
			r(2:order+1,i) = 20*log10(H(1:order));
			r(order+2,i) = THD;
			r(order+3,i) = SNR;
			i++;      
		endfor
	endfor 
	
	if boolPlot
		clf;  %clear previous plots
		subplot(211),
			semilogx(r(1,:),r(2:order+1,:));
			title('Harmonic Response');
			xlabel('f (Hz)');
			ylabel('dBV');
			legend('F_0','F_1','F_2','F_3','location','southoutside','orientation','horizontal');
			grid on;
			axis ([low high -100 10]);
		subplot(212),
			w = plotyy (r(1,:), r(order+2,:), r(1,:), r(order+3,:), @semilogx);
			title('Distortion measures');
			xlabel('f (Hz)');
			ylabel(w(1),'%');
			ylabel(w(2),'dBV');
			legend('THD+N','SNR','location','southoutside','orientation','horizontal');
			grid on
			axis (w(1), [low high 0 max(r(order+2,1:find(r(1,:)==high)-1))])
			axis (w(2), [low high])
	endif
	
	stop(player);
	stop(recorder);
endfunction

%--------------------------------------EOF--------------------------------------