
close all;

fs= 16000;
M=4;
Nframe = 402;
Lfilter = 400;
Lprefix = 400;
trainblock = randi([0, 1], (Nframe/2-1)*M, 1);
trainrect = repmat(trainblock, 10, 1);

pulse = [ones(10,1); zeros(240,1); ones(10,1); zeros(230,1); ones(10,1)];

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

[~, hEstimated] = ofdm_demod(Rx, Nframe, remainder, Lprefix, qamTrain(1:(Nframe/2 - 1), :), true);

% Exercise session 4: DMT-OFDM transmission scheme

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

h = hEstimated(1:Lfilter).';
%h = [1, zeros(1,Lfilter-1)];
H = fft(h);
noiseStruct = load('noisePower.mat');
noisePower = noiseStruct.noiseOut;
noisePower = noisePower(1:end-1).';
gamma = 1;
%b = floor(log2( 1 + (abs(H).^2)./( gamma * noisePower)));
b = floor(log2( 1 + (abs(H(1:length(h)/2)).^2)./( gamma * 1)));

%If we want to be able to take a certain amount of stuff, order h, then
%take the first 30% values and set your threshold so that those get taken
%out, easy.

% threshold = 0;
% b = log2(M) * (abs(H(1:length(h)/2))>threshold);



% OFDM modulation
%[ofdmStream, remainder] = ofdm_mod(qamStream, Nframe, Lprefix);
[ofdmStream, badbits] = ofdm_qam(bitStream, b, Lprefix);

% Channel
sizeTrainData = length(ofdmStream);
% Channel
[simin,nbsecs,fs] = initparams(ofdmStream,pulse, Lfilter ,fs);
sim('recplay');
out = simout.signals.values;
load chirp.mat;
Rx = alignIO(out, pulse, Lfilter);

Rx = Rx(1:sizeTrainData);


%rxOfdmStream = noisyOfdmStream;
% OFDM demodulation
%rxQamStream = ofdm_demod(rxOfdmStream, Nframe, remainder, Lprefix, h);
rxBitStream = ofdm_deqam(Rx, b, badbits, Lprefix, h);

% QAM demodulation
%rxBitStream = qam_demod(rxQamStream, M);
%rxBitStream = rxQamStream;

% Compute BER
berTransmission = biterr(bitStream,rxBitStream) % Gray is best for constellation

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;
