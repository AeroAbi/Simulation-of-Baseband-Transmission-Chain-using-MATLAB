clc;
clearvars all;
close all;

% Parameters for simulation
bit_rate = 3000;
sampling_freq = 24000;
symbol_period = 1/bit_rate;
sampling_period = 1/sampling_freq;
oversampling_factor = symbol_period/sampling_period;
data_size = 1000000;

% Part 1
SNRdB = 0:0.5:8;

% Create an array for storing the BER values
BER_values = zeros(size(SNRdB));

% Simulating for each SNR value
for eachSNRdB_index = 1:numel(SNRdB)
    % Calculating the SNR for the given SNR_dB value
    SNR_value = 10^(0.1 * SNRdB(eachSNRdB_index));

    % Generating the data bits
    data_bits = randi([0, 1], 1, data_size);
    symbols = 2*data_bits - 1;
    diracs = kron(symbols, [1, zeros(1, oversampling_factor-1)]);
    impulse_response_tx = ones(1, oversampling_factor);
    signal_tx = filter(impulse_response_tx, 1, diracs);

    % Calculating the noise power
    noise_power = oversampling_factor/(2*log2(2)*SNR_value);

    % Generating the AWGN noise
    awgn_noise = sqrt(noise_power) * randn(1, length(signal_tx));
    signal_tx = signal_tx + awgn_noise;

    % Receiver
    impulse_response_rx = ones(1, oversampling_factor/2);     %impulse response of Ts/2 duration
    signal_rx = filter(impulse_response_rx, 1, signal_tx);
    down_sampled_signal = signal_rx(8:oversampling_factor:end);
    rx_data_bits = down_sampled_signal > 0;
    BER_values(eachSNRdB_index) = length(find(abs(rx_data_bits - data_bits) > 0)) / numel(data_bits);
    fprintf("Symbol Error Rate @SNR = %fdB: %f\n", SNRdB(eachSNRdB_index), BER_values(eachSNRdB_index));
end

figure;
grid on;
semilogy(SNRdB, BER_values, 'LineWidth', 2, 'color', 'blue', 'LineStyle', '-.', 'Marker', 'x');
legend('Simulated BER');
title('Simulated Bit Error Rate (BER) vs SNR (Eb/N0)');
xlabel('Eb/N0 (dB)');
ylabel('Bit Error Rate (BER)');

BER_theory = berawgn(SNRdB, 'pam', 2);

figure;
semilogy(SNRdB, BER_theory, 'LineWidth', 2, 'color', 'red');
hold on;
grid on;
semilogy(SNRdB, BER_values, 'LineWidth', 2, 'color', 'blue', 'LineStyle', '-.', 'Marker', 'x');
legend('Theoretical BER', 'Simulated BER');
title('Simulated Bit Error Rate (BER) vs SNR (Eb/N0)');
xlabel('Eb/N0 (dB)');
ylabel('Bit Error Rate (BER)');