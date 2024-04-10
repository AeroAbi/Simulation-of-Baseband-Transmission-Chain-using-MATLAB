%generate baseband signal
%parameters
Fe=24000;       %Sampling frequency
Te=1/Fe;        %Sampling period
Rb=3000;        %Bit rate
N=1000;         %Number of generated bits

%bit generation
bits=randi([0,1],1,N);

%Modulator 1
M= 2;                       %Modulation order 
Rs1=Rb/log2(M);             %Symbol rate
Ns1=Fe/Rs1 ;                %Oversampling factor
symbols1=2*bits-1;          %mapping
%Psymbols=pammod(bits,M);   %mapping
%disp(Psymbols);

%Modulator2
M2= 4;                %QPSK    
Rs2=Rb/log2(M2);      %%Symbol rate
Ns2=Fe/Rs2 ;          %Oversampling factor
% reshapebits=reshape(bits,[2,N/2]);
% decisym=bi2de(reshapebits');    %transpose
% symbols2=decisym*2-3;    %mapping 

symbols2 = 2*bits(1:2:length(bits)) + bits(2:2:length(bits));
symbols2 = symbols2 - 3*(symbols2 == 0); %to get -3
symbols2 = symbols2 - 2*(symbols2 == 1); % to get -1
symbols2 = symbols2 - 1*(symbols2 == 2); %to get 1
                 

%Modulator3
M3=2 ;                     %Modulation order FOR Zero-mean binary symbols               
Rs3=Rb/log2(M3);           %Symbol rate
Ns3=Fe/Rs3 ;                %Oversampling factor
symbols3=pammod(bits,M3);  %Mapping for sq root raised cosine

%oversampling-increasing the sampling rate of already sampled signal
%kron- If A is an m-by-n matrix and B is a p-by-q matrix, then kron(A,B) is an m*p-by-n*q matrix formed by taking all possible products between the elements of A and the matrix B.
diracsM1=kron(symbols1,[1 zeros(1,Ns1-1)]);
diracsM2=kron(symbols2,[1 zeros(1,Ns2-1)]); %transpose
diracsM3=kron(symbols3,[1 zeros(1,Ns3-1)]);

%shaping filter
h1= rectpulse(1, Ns1);  
signal1=filter(h1,1,diracsM1);
%plot(signal1);
h2= rectpulse(1, Ns2); 
signal2=filter(h2,1,diracsM2);
h3= rcosdesign(0.2, 5, Ns3); %L-range of time period to for impulse reponse%h = rcosdesign(α, L, Ns);
signal3=filter(h3,1,diracsM3);  %roll off factor α = 0.5.
%plot(h3);
% title('Signal3 Plot');
% ylabel(' raised cosine filter impulse reponse')


%TO ESTIMATE PSD-returns the power spectral density (PSD) estimate, pxx, of the input signal, x
PSD1=pwelch(signal1,[],[],[],'twosided');     %cumulated periodgram,
figure
semilogy(PSD1);
semilogy(linspace(0,Fe,length(PSD1)),PSD1);  %semilogy(min,max-fe,length(PSD1),PSD1)
title('Signal1 PSD');
xlabel('Frequency in Hz')
ylabel(' S(f)')
PSD2=pwelch(signal2,[],[],[],'twosided');
figure
semilogy(PSD2);
semilogy(linspace(0,Fe,length(PSD2)),PSD2);
title('Signal2 PSD');
xlabel('Frequency in Hz')
ylabel(' S(f)')
PSD3=pwelch(signal3,[],[],[],'twosided'); %plot PSD
figure
semilogy(PSD3);
semilogy(linspace(0,Fe,length(PSD3)),PSD3);
title('Signal3 PSD');
xlabel('Frequency in Hz')
ylabel(' S(f)')


%PLOT in timescale
%SIGNALS
figure
timescale=[0:Te:(length(signal1)-1)*Te];  %time from 0 to length elemnts of signal-[x(0) x1....x(M-1)]
plot(timescale,signal1)
title('Signal1 Plot');
xlabel('Time in secs')
ylabel(' Modulator 1 Signal')
%axes(-1.5 -0.5 0.5 1.5);
figure
timescale=0:Te:(length(signal2)-1)*Te;  
plot(timescale,signal2)
title('Signal2 Plot');
xlabel('Time in secs')
ylabel(' Modulator 2 Signal')
figure
timescale=[0:Te:(length(signal3)-1)*Te];  
plot(timescale,signal3)
title('Signal3 Plot');
xlabel('Time in secs')
ylabel(' Modulator 3 Signal')

%comparing 3modulatorsPSDs
figure
frequencySignal1=linspace(-Fe/2,Fe/2,length(PSD1));
semilogy(frequencySignal1,fftshift(PSD1/max(PSD1)),'b')
xlabel('Frequency (Hz)')
ylabel('PSD of the transmitted signal')
%legend('Modulator 1')
hold on
frequencySignal2=linspace(-Fe/2,Fe/2,length(PSD2));
semilogy(frequencySignal2,fftshift(PSD2/max(PSD2)),'r')
xlabel('Frequency (Hz)')
ylabel('PSD of the transmitted signal')
%legend('Modulator 2')
hold on
frequencySignal3=linspace(-Fe/2,Fe/2,length(PSD3)); 
semilogy(frequencySignal3,fftshift(PSD3/max(PSD3)),'k') %black
grid
xlabel('Frequency (Hz)')
ylabel('PSD of the transmitted signal')
legend('Modulator 1','Modulator 2','Modulator 3')