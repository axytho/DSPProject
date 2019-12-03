% Exercise session 4: DMT-OFDM transmission scheme
close all;
% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%set by user
Lt = 3; %controls size of our data block
Ld = 4;


fs= 16000;
M=4;
Nframe = 2002;
SNR = 300;
Lfilter = 400;
Lprefix = 400;
dataFrameSize = (Nframe/2-1);
trainblock = randi([0, 1], dataFrameSize*M, 1); % M because bits not qam
impulseresponseStruct = load('h.mat');
h = impulseresponseStruct.h;
H = fft(h);



t = (1:32000)*1/16000;
sinewave = sin(440*2*pi*t)';

pulse = [ones(10,1); zeros(240,1); ones(10,1); zeros(230,1); ones(10,1)];


% figure();
% subplot(3,1,1);
% plot(out_aligned);
% 
% subplot(3,1,2);
% plot(simin);
% 
% subplot(3,1,3);
% plot(out);

%plot(pulse)

%The problem seems to be that some pixels are just widely off, while others
% are actually almost fine, the BER with this h is 3 times higher than with
% a channel of 1
% The channel heavily surpresses anything above 2000 Hz which is 1/4
% of the 8000 = pi so we should only code in the first 4th of the 
% function, not beyond that.

% QAM modulation
trainblock = qam_mod(trainblock, M);
qamStream = qam_mod(bitStream, M);
% same thing as OFDM MOD and DataFrameSize== N/2-1
dimLength = floor(length(qamStream)/(dataFrameSize*Ld));
remainder = mod(length(qamStream), (dataFrameSize*Ld));
bitSequence = reshape(qamStream(1:((dataFrameSize*Ld)*dimLength)), (dataFrameSize*Ld) , dimLength);
% and add the remainder plus trailing zeros
bitSequence = [bitSequence, [qamStream(end - remainder + 1:end);zeros(dataFrameSize*Ld-remainder,1)]];
% now we add however many Lt*trainblock frames we need to the bottom
dataBlock = [bitSequence; repmat(trainblock, Lt, dimLength+1)];
ofdmSignal = dataBlock(:);


% OFDM modulation
[ofdmStream, remainder] = ofdm_mod(ofdmSignal, Nframe, Lprefix);
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


figure('name','Acoustic impulse and frequency response')

subplot(2,1,1)
plot(t, hChannel);
title('Acoustic impulse response h')
xlabel('t');
ylabel('Acoustic impulse response h');

subplot(2,1,2)
plot(f, mag2db(abs(HChannel)));
title('Acoustic impulse frequency response H')
xlabel('f');
ylabel('Acoustic impulse frequency response H');



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

%Construct image from bitstream
%imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);
% 
% % Plot images
% subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
% subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;

