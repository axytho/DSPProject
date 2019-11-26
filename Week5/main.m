% Exercise session 4: DMT-OFDM transmission scheme

% Convert BMP image to bitstream
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
size(trainrect)

%The problem seems to be that some pixels are just widely off, while others
% are actually almost fine, the BER with this h is 3 times higher than with
% a channel of 1
% The channel heavily surpresses anything above 2000 Hz which is 1/4
% of the 8000 = pi so we should only code in the first 4th of the 
% function, not beyond that.

% QAM modulation
qamStream = qam_mod(trainrect, M);
% OFDM modulation
[ofdmStream, remainder] = ofdm_mod(qamStream, Nframe, Lprefix);
%[ofdmStream, badbits] = ofdm_qam(bitStream, b, Lprefix);

% Channel

noisyOfdmStream = awgn(ofdmStream,SNR);
%h = rand(1, Lfilter);
%h = [0.5, 0.6, 0.7, 0.3, 0.4, 0.7];
Rx = filter(h, 1, noisyOfdmStream);

%rxOfdmStream = noisyOfdmStream;
% OFDM demodulation
rxQamStream = ofdm_demod(Rx, Nframe, remainder, Lprefix, h);
%rxQamStream = ofdm_deqam(rxOfdmStream, b, badbits, Lprefix, h);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, M);
%rxBitStream = rxQamStream;

% Compute BER
berTransmission = biterr(trainrect,rxBitStream) % Gray is best for constellation

