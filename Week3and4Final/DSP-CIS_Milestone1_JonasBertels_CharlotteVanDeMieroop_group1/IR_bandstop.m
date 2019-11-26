fs = 16000;
power = 0; % in dBm
sigBand = wgn(1, fs*2, power, 1, 2019)';

b = fir1(320,[700*pi/16000 3000*pi/16000],'stop');

frequencySig = fft(sigBand, 320);
[h,w] = freqz(b, 1, 320);

figure('Name', 'IR bandstop');

subplot(2,1,1);
plot(w/pi,20*log10(abs(h)))
ax = gca;
ax.YLim = [-100 100];
ax.XTick = 0:.5:2;
title('Bandstop filter');
xlabel('Normalized Frequency (\times\pi rad/sample)')
ylabel('Magnitude (dB)');


% Bandstop signal
bandstop_sig = h.*frequencySig;
subplot(2,1,2);
plot(w/pi,20*log10(abs(bandstop_sig)));
ax = gca;
ax.YLim = [-100 100];
ax.XTick = 0:.5:2;
title('Bandstop filtered white noise signal');
xlabel('Normalized Frequency (\times\pi rad/sample)')
ylabel('Magnitude (dB)');

% Filter signal

frequencySig = fft(sigBand, 320);
[h,w] = freqz(b, 1, 320);
bandstop_sig = h.*frequencySig;
sig = abs(ifft(bandstop_sig, fs * 2));

%sigNoise = wgn(1, fs*2, power, 1, 2019)';
hsize = 320;
[simin,nbsecs,fs] = initparams(sig,fs);
sim('recplay');
out = simout.signals.values;

u = simin(:,1);
y = [out; zeros(size(u,1)-size(out, 1) + hsize - 1, 1)];

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