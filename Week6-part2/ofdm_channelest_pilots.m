% Exercise session 4: DMT-OFDM transmission scheme
close all;
% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');



fs= 16000;
M=4;
Nframe = 2002;
SNR = 300;
Lfilter = 400;
Lprefix = 400;
trainblock = randi([0, 1], (Nframe/2-1)*M, 1);
trainblock = upsample(downsample(trainblock,2),2);
trainrect = repmat(trainblock, 3, 1);
impulseresponseStruct = load('h.mat');
h = impulseresponseStruct.h;
H = fft(h);
noiseStruct = load('noisePower.mat');
noisePower = noiseStruct.noiseOut;
noisePower = noisePower(1:end-1)';

t = (1:32000)*1/16000;
sinewave = sin(440*2*pi*t)';

pulse = [ones(10,1); zeros(240,1); ones(10,1); zeros(230,1); ones(10,1)];



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

sizeTrain = length(ofdmStream);

% Channel
[simin,nbsecs,fs] = initparams(ofdmStream,pulse, Lfilter ,fs);
sim('recplay');
out = simout.signals.values;
load chirp.mat;
Rx = alignIO(out, pulse, Lfilter);

Rx = Rx(1:sizeTrain);
%h = rand(1, Lfilter);
%h = [0.5, 0.6, 0.7, 0.3, 0.4, 0.7];
%Rx = filter(h, 1, noisyOfdmStream);
figure();
subplot(2, 1, 1);
plot(Rx);

subplot(2,1,2);
plot(out);

%rxOfdmStream = noisyOfdmStream;
% OFDM demodulatio

[rxQamStream, hEstimated] = ofdm_demod_pilot(Rx, Nframe, remainder, Lprefix, qamTrain(1:(Nframe/2 - 1), :), true);

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



figure('name','Estimated channel impulse and frequency response')

subplot(2,1,1)
plot(tEst, hEstimated);
title('Estimated channel impulse response h')
xlabel('t');
ylabel('Estimated channel impulse response h');

subplot(2,1,2)
plot(fEst, mag2db(abs(HEstimated)));
title('Estimated channel frequency response H')
xlabel('f');
ylabel('Estimated channel frequency response H');

