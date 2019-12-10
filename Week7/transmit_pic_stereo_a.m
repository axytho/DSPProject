close all;
% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%set by user
Lt = 5; %controls size of our data block
Ld = 7;
fs= 16000;
M=64;
Nframe = 2002;



Lfilter = 400;
Lprefix = 400;
dataFrameSize = (Nframe/2-1);
trainblockbits = randi([0, 1], dataFrameSize*log2(M), 1); % M because bits not qam


randomImpulseResponse1 = [-1 + 2* rand(Lfilter, 1); zeros(Nframe/2-1-Lfilter, 1)]; % Not a good model obviously
randomImpulseResponse2 = [-1 + 2* rand(Lfilter, 1); zeros(Nframe/2-1-Lfilter, 1)];
[a, b, H12] = fixed_transmitter_side_beamformer(randomImpulseResponse1, randomImpulseResponse2);
%H12 is obviously larger than H1 and H2 for all
%(a.*conj(a) + b.*conj(b))

t = (1:5000)*1/16000;


pulse = sin(2*pi*t*2000).';

% figure();
% subplot(3,1,1);

% QAM modulation
trainblock = qam_mod(trainblockbits, M);


numberLargest=  (Nframe/2 -1);


% do this: https://www.mathworks.com/matlabcentral/answers/300929-add-zero-rows-to-a-matrix

qamStream = qam_mod(bitStream, M);
% same thing as OFDM MOD and DataFrameSize== N/2-1
dimLength = floor(length(qamStream)/(Ld*numberLargest));
dataRemainder = mod(length(qamStream), (Ld*numberLargest));


bitSequence = reshape(qamStream(1:((Ld*numberLargest)*dimLength)), (Ld*numberLargest) , dimLength);
% and add the remainder plus trailing zeros
bitSequence = [bitSequence, [qamStream(end - dataRemainder + 1:end);zeros(Ld*numberLargest-dataRemainder,1)]];
% now we add however many Lt*trainblock frames we need to the bottom
dataBlock = [repmat(trainblock, Lt, dimLength+1); bitSequence];
ofdmSignal = dataBlock(:);



% OFDM modulation
[ofdmStream1, ofdmStream2, remainder] = ofdm_mod_stereo(ofdmSignal, Nframe, Lprefix, a, b);


% Channel
Received1 = filter(randomImpulseResponse1, 1, ofdmStream1);
Received2 = filter(randomImpulseResponse2, 1, ofdmStream2);


[rxQamStream, HEstimated] = ofdm_demod_stereo(Received1, Received2, Nframe, remainder, Lprefix, trainblock, Ld, Lt, dataRemainder,  H12);

%rxQamStream = ofdm_deqam(rxOfdmStream, b, badbits, Lprefix, h);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, M);
%rxBitStream = rxQamStream;

% Compute BER
[berTransmission, ratio] = biterr(bitStream,rxBitStream) % Gray is best for constellation

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;
