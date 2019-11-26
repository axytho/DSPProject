fs = 16000;
t2FS = linspace(0,2,fs*2); % N  = 2fs; T = 1/fs
t5FS = linspace(0,2,fs*5);
sig = zeros(fs*2, 1);
sig(100) = 1;

power = 0;
sigNoise = wgn(1, fs*2, power, 1, 2019)';

[simin,nbsecs,fs] = initparams(sig,fs);
sim('recplay');
out = simout.signals.values;

[simin,nbsecs,fs] = initparams(sigNoise,fs);
sim('recplay');
outNoise = simout.signals.values;

L = size(out, 1);
Y = fft(out);
H = mag2db(abs(Y(1:L/2+1)/L));
f = (0:L/2)/(L)*fs;
t = linspace(1, L, L); 
outNoise2 = fftfilt(out, simin(:,1));

figure('Name','IR1');

subplot(2,1,1);
plot(t, out);
title('Impulse response (time-domain)');
xlabel('Samples (filter taps)');
ylabel('Amplitude (dB)');

subplot(2,1,2);
plot(f', H);
title('Impulse response (frequency-domain)');
xlabel('Frequency (Hz)');
ylabel('Amplitude (dB)');

figure('Name','Convolution');

subplot(2,1,1);
plot(t, outNoise);
title('Output of transmitted white noise signal');
xlabel('Samples (filter taps)');
ylabel('Amplitude (dB)');

subplot(2,1,2);
plot(t5FS, outNoise2);
title('Convolution of transmitted white noise signal with estimated IR');
xlabel('Samples (filter taps)');
ylabel('Amplitude (dB)');