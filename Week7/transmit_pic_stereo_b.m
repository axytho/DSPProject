


close all;
% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%set by user
Lt = 3; %controls size of our data block
Ld = 7;
fs= 16000;
M=64;
Nframe = 2002;
Lfilter = 400;
Lprefix = 400;
dataFrameSize = (Nframe/2-1);

t = (1:5000)*1/16000;
pulse = sin(2*pi*t*2000).';
getHLeftAndRight = true;

if getHLeftAndRight
    trainblock = randi([0, 1], (Nframe/2-1)*log2(M), 1);
    trainrect = repmat(trainblock, Lt, 1);
    qamTrain = qam_mod(trainrect, M);
    [ofdmStream, remainder] = ofdm_mod(qamTrain, Nframe, Lprefix);
    ofdmStreamLeft = [ofdmStream; zeros(length(ofdmStream), 1)];
    ofdmStreamRight = [zeros(length(ofdmStream), 1); ofdmStream];
    sizeTrain = length(ofdmStream);
    [simin,nbsecs,fs] = initparams_stereo(ofdmStreamLeft, ofdmStreamRight,pulse, Lfilter ,fs);
    sim('recplay');
    out = simout.signals.values;
    load chirp.mat;
    Rx = alignIO(out, pulse, Lfilter);
    RxLeft = Rx(1:sizeTrain);
    RxRight = Rx(sizeTrain+1:2*sizeTrain);
    [~, randomImpulseResponse1] = ofdm_demodTraining(RxLeft, Nframe, remainder, Lprefix, qamTrain(1:(Nframe/2 - 1), :), true); % There is noise because h doesn't go perfectly to 0
    [~, randomImpulseResponse2] = ofdm_demodTraining(RxRight, Nframe, remainder, Lprefix, qamTrain(1:(Nframe/2 - 1), :), true);% There is noise because h doesn't perfectly go to 0.

else
    randomImpulseResponse1 = [-1 + 2* rand(Lfilter, 1); zeros(Nframe-Lfilter, 1)]; % Not a good model obviously

    randomImpulseResponse2 = [-1 + 2* rand(Lfilter, 1); zeros(Nframe-Lfilter, 1)];
    
end

[a, b, H12] = fixed_transmitter_side_beamformer(randomImpulseResponse1, randomImpulseResponse2); %1333 errors

    %Basically no difference between H1 and H2
    %a = ones(Nframe, 1);
    %b = zeros(Nframe, 1); %7583 errors
    %H12 = fft(randomImpulseResponse1);

    % a = zeros(Nframe, 1);
    % b = ones(Nframe, 1);
    % H12 = fft(randomImpulseResponse2);



trainblockbits = randi([0, 1], dataFrameSize*log2(M), 1); % M because bits not qam
%H12 is obviously larger than H1 and H2 for all
%(a.*conj(a) + b.*conj(b))





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

% SNR = 600;
% % Channel
% Received1 = filter(randomImpulseResponse1, 1, ofdmStream1);
% Received2 = filter(randomImpulseResponse2, 1, ofdmStream2);
% Received1 = awgn(Received1, SNR);
% Received2 = awgn(Received2, SNR);
% Rx = Received1 + Received2;

sizeTrain = length(ofdmStream1);

% Channel
[simin,nbsecs,fs] = initparams_stereo(ofdmStream1, ofdmStream2,pulse, Lfilter ,fs);
sim('recplay');
out = simout.signals.values;
load chirp.mat;
Rx = alignIO(out, pulse, Lfilter);

Rx = Rx(1:sizeTrain);%Will fail if align IO did not find the correct end result


[rxQamStream, HEstimated] = ofdm_demod_stereo(Rx, Nframe, remainder, Lprefix, trainblock, Ld, Lt, dataRemainder);

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
