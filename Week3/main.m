% Exercise session 4: DMT-OFDM transmission scheme

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
M=16;
Nframe = 402;
SNR = 80;
Lfilter = 400;
Lprefix = 400;
impulseresponseStruct = load('h.mat');
h = impulseresponseStruct.h;
H = fft(h);
noiseStruct = load('noisePower.mat');
noisePower = noiseStruct.noiseOut;
noisePower = noisePower(1:end-1)';
gamma = 10;
%b = floor(log2( 1 + (abs(H).^2)./( gamma * noisePower)));
%b = floor(log2( 1 + (abs(H(1:length(h)/2)).^2)./( gamma * 1)));
threshold = 0
b = log2(M) * (abs(H(1:length(h)/2))>threshold)

%The problem seems to be that some pixels are just widely off, while others
% are actually almost fine, the BER with this h is 3 times higher than with
% a channel of 1
% The channel heavily surpresses anything above 2000 Hz which is 1/4
% of the 8000 = pi so we should only code in the first 4th of the 
% function, not beyond that.

% QAM modulation
qamStream = qam_mod(bitStream, M);
% OFDM modulation
[ofdmStream, remainder] = ofdm_mod(qamStream, Nframe, Lprefix);
%[ofdmStream, badbits] = ofdm_qam(bitStream, b, Lprefix);

% Channel

noisyOfdmStream = awgn(ofdmStream,SNR);
%h = rand(1, Lfilter);
%h = [0.5, 0.6, 0.7, 0.3, 0.4, 0.7];
rxOfdmStream = filter(h, 1, noisyOfdmStream);

%rxOfdmStream = noisyOfdmStream;
% OFDM demodulation
rxQamStream = ofdm_demod(rxOfdmStream, Nframe, remainder, Lprefix, h);
%rxQamStream = ofdm_deqam(rxOfdmStream, b, badbits, Lprefix, h);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, M);
%rxBitStream = rxQamStream;

% Compute BER
berTransmission = biterr(bitStream,rxBitStream) % Gray is best for constellation

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;
