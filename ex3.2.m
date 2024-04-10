clc;
clearvars all;
close all;

% Parameters for simulation
bit_rate = 3000;                                       %Bit rate
sampling_freq = 24000;                                 %Sampling frequency
symbol_period = 1/bit_rate;                            %Sampling period
sampling_period = 1/sampling_freq;
oversampling_factor = symbol_period/sampling_period;   %Oversampling factor
data_size = 1000;                                      %Number of generated bits

% Generating the data bit   
data_bits = randi([0, 1], 1, data_size);

% Part 1
symbols = 2*data_bits - 1;                             %mapping

diracs = kron(symbols, [1, zeros(1, oversampling_factor-1)]);
impulse_response_tx = ones(1, oversampling_factor);

signal_tx = filter(impulse_response_tx, 1, diracs);    %shaping filter-transmitted signal

impulse_response_rx = ones(1, oversampling_factor);

signal_rx = filter(impulse_response_rx, 1, signal_tx); %(a)received filter

signal_rx_temp = signal_rx(1:100*oversampling_factor)/8;

%w/o channel
impulse_response_tx=impulse_response_rx;

%(b) g = h∗hr tracing, determine the optimal sampling instants
g=conv(impulse_response_tx,impulse_response_rx);
figure
plot(g)
grid
title('convoluted Plot');

%Optimal sampling instances-plot
sampling_instances = zeros(size(signal_rx_temp));
sampling_instances(8:oversampling_factor:end) = 1;
figure;
plot((0:(length(signal_rx_temp)-1)) * symbol_period, signal_rx_temp);
hold on;
stem((0:(length(signal_rx_temp)-1)) * symbol_period, sampling_instances);
title('Sampling instants Plot');

%sampling
down_sampled_signal = signal_rx(8:oversampling_factor:end);

%(C)eyediagram
eyediagram(down_sampled_signal, 2, 2*symbol_period);     

%(d)threshold detector-optimal threshold is 0
rx_data_bits = down_sampled_signal > 0;
%(e)SER
%fprintf("Symbol Error Rate = %d\n", length(find(abs(rx_data_bits - data_bits) > 0)));   %to print SER values
SER=length(find(abs(rx_data_bits - data_bits) > 0));

%(f)BER
BER=SER/length(data_bits);

%(g)sample at n0 = 3
down_sampled_signal = signal_rx(3:oversampling_factor:end);
rx_data_bits = down_sampled_signal > 0;
fprintf("Symbol Error Rate = %d\n", length(find(abs(rx_data_bits - data_bits) > 0)));
SERNo3=length(find(abs(rx_data_bits - data_bits) > 0));
BERNo3=SERNo3/length(rx_data_bits);


% 3.2.2-Part 2-ak ∈ {0, 1}

symbols = data_bits;                                %mapping

diracs = kron(symbols, [1, zeros(1, oversampling_factor-1)]);
impulse_response_tx = ones(1, oversampling_factor);

signal_tx = filter(impulse_response_tx, 1, diracs);       %shaping filter-transmitted signal

impulse_response_rx = ones(1, oversampling_factor);
signal_rx = filter(impulse_response_rx, 1, signal_tx);

down_sampled_signal = signal_rx(8:oversampling_factor:end);

%eyediagram(down_sampled_signal, 2, 2*symbol_period);

%threshold
rx_data_bits = down_sampled_signal > 0.5;

%BER
SER2=length(find(abs(rx_data_bits - data_bits) > 0));
fprintf("Symbol Error Rate = %d\n", length(find(abs(rx_data_bits - data_bits) > 0)));
BER2=SER2/length(data_bits);
