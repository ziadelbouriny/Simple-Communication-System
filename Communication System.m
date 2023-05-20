%%converting the type to .wav
[y, Fs] = audioread('Recording.m4a');
audiowrite('sound.wav', y, Fs);

%%reading the file and sample frequency
[y, Fs] = audioread('sound.wav');

p = audioplayer(y, Fs);
play(p);

%%getting t
y = y(:,1);
t_sec = length(y) ./ Fs;
t = linspace(0, t_sec, t_sec * Fs);

%%convert to frequency
y_f = fftshift(fft(y));
N = length(y_f);
y_mag = abs(y_f);
y_phase = angle(y_f);
Fvec = linspace(-Fs/2 , Fs/2, N);

%%plotting
figure(1);
subplot(3,1,1);
plot(t,y);
title('Original audio in time domain');

subplot(3,1,2);
plot(Fvec, y_mag);
title('Original audio magnitude in freq domain');

subplot(3,1,3);
plot(Fvec, y_phase);
title('Original audio phase in freq domain');

%%channel
imp_res = 0;

while imp_res == 0
    
    fprintf("Choose the desired impulse response:\n1 - Delta Function\n2 - exp(-2 * pi * 5000 .* t)\n3 - exp(-2 * pi * 1000 .* t)\n4 - 2 * delta(t) + 0.5 .* delta(t-1)\n");
    imp_res = input("Choice = ");
    
    switch (imp_res)
        case 1
            h = dirac(t);
            h(h == Inf) = 1;
    
        case 2
            h = exp(-2 * pi * 5000 .* t);
    
        case 3
            h = exp(-2 * pi * 1000 .* t);
    
        case 4
            h = (2 .* (t == 0)) + (0.5 .* (t == 1));
    
        otherwise
            imp_res = 0;
            fprintf("Enter the choice correctly\n");
    end
end

%%convolution
y_conv = conv(y, h);
t_conv_sec = length(y_conv) ./ Fs;
t_conv = linspace(0, t_conv_sec, t_conv_sec * Fs);

%%convert to frequency
y_conv_f = fftshift(fft(y_conv));
N_conv = length(y_conv_f);
y_conv_mag = abs(y_conv_f);
y_conv_phase = angle(y_conv_f);
Fvec_conv = linspace(-Fs/2 , Fs/2, N_conv);

%%plotting
figure(2);
subplot(3,1,1);
plot(t_conv, y_conv);
title('After passing by the system in time domain');

subplot(3,1,2);
plot(Fvec_conv, y_conv_mag);
title('Signal after passing by the system magnitude in freq domain');

subplot(3,1,3);
plot(Fvec_conv, y_conv_phase);
title('Signal after passing by the system phase in freq domain');

%%noise 
%%getting sigma
fprintf("Please input sigma of noise you want to add\n");
sigma = input("\sigma = ");

%%adding noise
Y = y_conv(1:length(y));
noise = sigma * randn(size(Y));
signal_noise = noise + Y;

p = audioplayer(signal_noise, Fs);
play(p);

%%noise in freq
signal_noise_f = fftshift(fft(signal_noise));
N_signal_noise_f = length(signal_noise_f);
signal_noise_fmag = abs(signal_noise_f);
signal_noise_fphase = angle(signal_noise_f);
Fvec_signal_noise_f = linspace(-Fs/2 , Fs/2, length(signal_noise_f));

%%plotting
figure(3);
subplot(3,1,1);
plot(t,signal_noise);
title('Noise audio in time domain');

subplot(3,1,2);
plot(Fvec_signal_noise_f, signal_noise_fmag);
title('Noise audio magnitude in freq domain');

subplot(3,1,3);
plot(Fvec_signal_noise_f, signal_noise_fphase);
title('Noise audio phase in freq domain');

%%reciver

%%cutting
num_samples = length(signal_noise);
cut_f = 3400;
freq = linspace(-Fs/2 , Fs/2 , num_samples);
cut = find(abs(freq) > cut_f);
signal_noise_f(cut) = 0;
output = real(ifft(ifftshift(signal_noise_f)));

output_f = fftshift(fft(output));
N_output_f = length(output_f);
output_f_mag = abs(output_f);
output_f_phase = angle(output_f);
Fvec_output_f = linspace(-Fs/2 , Fs/2, N_output_f);

figure(4);
subplot(3,1,1);
plot(t,output);
title('Output audio in time domain');

subplot(3,1,2);
plot(Fvec_output_f, output_f_mag);
title('Output audio magnitude in freq domain');

subplot(3,1,3);
plot(Fvec_output_f, output_f_phase);
title('Output audio phase in freq domain');

p = audioplayer(output, Fs);
play(p);


