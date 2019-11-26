
close all
fs = 16000;
sig = zeros(fs*2, 1);
sig(100:105) = 1;

%sigNoise = wgn(1, fs*2, power, 1, 2019)';
hsize = 400;
[simin,nbsecs,fs] = initparams(sig,fs);
sim('recplay');
out = simout.signals.values;

size(out)

u = simin(:,1);
y = [out(0.22*fs:end); zeros(0.22*fs-1, 1);zeros(size(u,1)-size(out, 1) + hsize - 1, 1)];
size(u)
size(y)

figure('Name','Variables');

subplot(2,1,1);
plot(u);
title('Input signal u');

subplot(2,1,2);
plot(y);
title('Output signal y');

figure('Name','IR2');

toep = toeplitz([u; zeros(hsize-1, 1)], [u(1), zeros(1, hsize-1)]);
h = y\toep;
subplot(2,1,1);
plot(h);
title('Impulse response (time-domain)');
xlabel('Samples (filter taps)');
ylabel('Amplitude (dB)');

f = linspace(0, fs, hsize);
H = abs(fft(h));

subplot(2,1,2);
plot(f', H);
title('Impulse response (frequency-domain)');
xlabel('Frequency (Hz)');
ylabel('Amplitude (dB)');

figure('Name','Convolution');

yConv=cconv(h,u);
subplot(2,1,1);
plot(yConv);
title('Convolution of h and u');
save('IRest.mat', 'h');
