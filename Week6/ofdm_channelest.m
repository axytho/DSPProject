% Exercise session 4: DMT-OFDM transmission scheme
close all;
% Convert BMP image to bitstream
fs= 16000;
M=16;
Nframe = 2002;
SNR = 300;
Lfilter = 400;
Lprefix = 400;
impulseresponseStruct = load('h.mat');
h = impulseresponseStruct.h;
H = fft(h);
noiseStruct = load('noisePower.mat');
noisePower = noiseStruct.noiseOut;
noisePower = noisePower(1:end-1)';

trainblock = randi([0, 1], (Nframe/2-1)*M, 1);
trainrect = repmat(trainblock, 100, 1);
size(trainrect);
t = (1:32000)*1/16000;
sinewave = sin(440*2*pi*t)';

pulse = ones(500,1);

[simin,nbsecs,fs] = initparams(sinewave,pulse, Lfilter ,fs);
sim('recplay');
out = simout.signals.values;
load chirp.mat;
out_aligned = alignIO(out, pulse);

figure();
subplot(3,1,1);
plot(out_aligned);

subplot(3,1,2);
plot(simin);

subplot(3,1,3);
plot(out);

%plot(pulse)

%The problem seems to be that some pixels are just widely off, while others
% are actually almost fine, the BER with this h is 3 times higher than with
% a channel of 1
% The channel heavily surpresses anything above 2000 Hz which is 1/4
% of the 8000 = pi so we should only code in the first 4th of the 
% function, not beyond that.

% QAM modulation
qamTrain = qam_mod(trainrect, M);


% OFDM modulation
[ofdmStream, remainder] = ofdm_mod(qamTrain, Nframe, Lprefix);
%[ofdmStream, badbits] = ofdm_qam(bitStream, b, Lprefix);

% Channel

noisyOfdmStream = awgn(ofdmStream,SNR);
%h = rand(1, Lfilter);
%h = [0.5, 0.6, 0.7, 0.3, 0.4, 0.7];
Rx = filter(h, 1, noisyOfdmStream);

%rxOfdmStream = noisyOfdmStream;
% OFDM demodulatio

[rxQamStream, hEstimated] = ofdm_demod(Rx, Nframe, remainder, Lprefix, qamTrain(1:(Nframe/2 - 1), :), true);

%rxQamStream = ofdm_deqam(rxOfdmStream, b, badbits, Lprefix, h);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, M);
%rxBitStream = rxQamStream;

% Compute BER
berTransmission = biterr(trainrect,rxBitStream); % Gray is best for constellation

hChannel = h';
HChannel = fft(hChannel);


hEstimated = hEstimated(1:Lfilter)';
HEstimated = fft(hEstimated);



t = (1:size(hChannel, 1) )/fs;
f = (1:size(HChannel, 1))*fs/Lfilter;
tEst = (1:size(hEstimated, 2))/fs;
fEst = (1:size(HEstimated, 2))*fs/Lfilter;


% figure('name','Acoustic impulse and frequency response')
% 
% subplot(2,1,1)
% plot(t, hChannel);
% title('Acoustic impulse response h')
% xlabel('t');
% ylabel('Acoustic impulse response h');
% 
% subplot(2,1,2)
% plot(f, mag2db(abs(HChannel)));
% title('Acoustic impulse frequency response H')
% xlabel('f');
% ylabel('Acoustic impulse frequency response H');
% 
% 
% 
% figure('name','Estimated channel impulse and frequency response')
% 
% subplot(2,1,1)
% plot(tEst, hEstimated);
% title('Estimated channel impulse response h')
% xlabel('t');
% ylabel('Estimated channel impulse response h');
% 
% subplot(2,1,2)
% plot(fEst, mag2db(abs(HEstimated)));
% title('Estimated channel frequency response H')
% xlabel('f');
% ylabel('Estimated channel frequency response H');

