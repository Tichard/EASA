%------------------------------------TEST.M-------------------------------------

%{
	> [File Name] test.m
	> [Platform] Octave GNU
	> [Version] alpha
	> [Author] Richard
	> [Date] 10/08/2016
	> [Language] .m file
	> [Description] Tests function file
%}


%-----------------------------------INCLUDES------------------------------------
%load packages 
pkg load audio; %player/recorder
pkg load signal; %Blackman-Harris windows

%load the implemented functions
addpath ("./src");

%-----------------------------------FUNCTION------------------------------------

function test_measure(f,n)
	
	Fs = 48000;
	T = 20;
	t = 0:1/Fs:T-(1/Fs); %time vector
	sinu = sin(2*pi*f*t);
	
	player = audioplayer (sinu, Fs);
	play (player);
	
	measure(f,n,1);
	
	stop (player);
endfunction

%------------------------------------SCRIPT-------------------------------------
clear; %clear workspace
clc; %clear command shell

%test the sweep function
%sweep(10,20000,2);

%test the measure function
test_measure(1000,2);

%--------------------------------------EOF--------------------------------------
