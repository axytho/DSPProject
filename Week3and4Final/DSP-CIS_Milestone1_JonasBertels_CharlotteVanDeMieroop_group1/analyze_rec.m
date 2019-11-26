% variables
fs = 16000;
dftsize = fs;
sig = zeros(1, fs*2);

t = linspace(0,2,fs*2); % N  = 2fs; T = 1/fs

% original signal
% sig = (sin(400*2*pi*t)+0.5)';

% frequencies = [100, 200, 500, 1000, 1500, 2000, 4000, 6000];
% for frequency = frequencies
%     sig = sig + sin(frequency*2*pi*t);
% end
% sig = sig';

power = 0; % in dBm
sig = wgn(1, fs*2, power, 1, 2019)';

[simin,nbsecs,fs] = initparams(sig,fs);
sim('recplay');
out = simout.signals.values;

figure('Name','Spectograms');
subplot(2,1,1);
spectrogram(sig,128,120,dftsize,fs);
title('Spectogram of the transmitted white noise signal');
subplot(2,1,2);
spectrogram(out,128,120,dftsize,fs);
title('Spectogram of the recorded signal');

x = linspace(0, fs/2, dftsize/2 + 1);

figure('Name','Power Spectral Densities');
subplot(2,1,1);
plot(x, pwelch(sig,dftsize*2,0,dftsize,fs));
title('PSD of the transmitted white noise signal');
xlabel('Frequency (Hz)');
ylabel('Power/frequency (dB/Hz)');

subplot(2,1,2);
plot(x, pwelch(out,dftsize*2,0,dftsize,fs));
title('PSD of the recorded signal');
xlabel('Frequency (Hz)');
ylabel('Power/frequency (dB/Hz)');
