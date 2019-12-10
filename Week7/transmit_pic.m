clear all;
%close all;

[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

Lt = 5; %controls size of our data block
fs= 16000;
M=4;
Nframe = 2002;
SNR = 300;
Lfilter = 400;
Lprefix = 400;
dataFrameSize = (Nframe/2-1);
trainblockbits = randi([0, 1], dataFrameSize*M/2, 1); % M because bits not qam
impulseresponseStruct = load('h.mat');
h = impulseresponseStruct.h;
H = fft(h);
Ld =  floor(length(bitStream)/(dataFrameSize*log2(M))) + 1;
t = (1:32000)*1/16000;
sinewave = sin(440*2*pi*t)';
pulse = [ones(10,1); zeros(240,1); ones(10,1); zeros(230,1); ones(10,1); zeros(20,1); ones(10,1)];

% QAM modulation
trainblock = qam_mod(trainblockbits, M);
qamStream = qam_mod(bitStream, M);
% same thing as OFDM MOD and DataFrameSize== N/2-1
dimLength = floor(length(qamStream)/(dataFrameSize*Ld));
dataRemainder = mod(length(qamStream), (dataFrameSize*Ld));
bitSequence = reshape(qamStream(1:((dataFrameSize*Ld)*dimLength)), (dataFrameSize*Ld) , dimLength);
% and add the remainder plus trailing zeros
bitSequence = [bitSequence, [qamStream(end - dataRemainder + 1:end);zeros(dataFrameSize*Ld-dataRemainder,1)]];
% now we add however many Lt*trainblock frames we need to the bottom
dataBlock = [bitSequence; repmat(trainblock, Lt, dimLength+1)];
ofdmSignal = dataBlock(:);

% OFDM modulation
[ofdmStream, remainder] = ofdm_mod(ofdmSignal, Nframe, Lprefix);

sizeTrain = length(ofdmStream);

% Channel
[simin,nbsecs,fs] = initparams(ofdmStream,pulse, Lfilter ,fs);
sim('recplay');
out = simout.signals.values;
load chirp.mat;
Rx = alignIO(out, pulse, Lfilter);

Rx = Rx(1:sizeTrain);%Will fail if align IO did not find the correct end result

[rxQamStream, HEstimated, HMatrix] = ofdm_demod(Rx, Nframe, remainder, Lprefix, trainblock, Ld, Lt, dataRemainder, M);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, M);

% Compute BER
[berTransmission, berRatio] = biterr(bitStream,rxBitStream) % Gray is best for constellation

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% Plot images
figure('name','Transmit picture (no bitloading)')
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;
%text_ber = subplot(4,1,2); 
%text(0.5,0.5,'test');
%set(text_ber,'visible','off');