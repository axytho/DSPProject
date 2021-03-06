%close all;
% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%set by user
Lt = 5; %controls size of our data block
fs= 16000;
M=8;
Nframe = 2002;

SNR = 300;
Lfilter = 400;
Lprefix = 400;
dataFrameSize = (Nframe/2-1);
trainblockbits = randi([0, 1], dataFrameSize*log2(M), 1); % M because bits not qam

t = (1:5000)*1/16000;

pulse = sin(2*pi*t*2000).';

OOK = true;
% Find initial channel estimate if doing OOK
if OOK
    trainblock = randi([0, 1], (Nframe/2-1)*log2(M), 1);
    trainrect = repmat(trainblock, 10, 1);
    qamTrain = qam_mod(trainrect, M);
    [ofdmStream, remainder] = ofdm_mod(qamTrain, Nframe, Lprefix);
    sizeTrain = length(ofdmStream);
    [simin,nbsecs,fs] = initparams(ofdmStream,pulse, Lfilter ,fs);
    sim('recplay');
    out = simout.signals.values;
    load chirp.mat;
    Rx = alignIO(out, pulse, Lfilter);
    Rx = Rx(1:sizeTrain);
    [~, impulseResponseEstimated] = ofdm_demodTraining(Rx, Nframe, remainder, Lprefix, qamTrain(1:(Nframe/2 - 1), :), true);
end
% figure();
% subplot(3,1,1);

% QAM modulation
trainblock = qam_mod(trainblockbits, M);

BWUsage = 100;
numberLargest= floor(BWUsage/100 * (Nframe/2 -1));

Ld =  floor(length(bitStream)/(numberLargest*log2(M))) + 1;
frequencyResponseEstimated = fft(impulseResponseEstimated);

[~, OOBIndices] = maxk(frequencyResponseEstimated(1:Nframe/2-1), numberLargest);
OOBIndices = sort(OOBIndices);
% do this: https://www.mathworks.com/matlabcentral/answers/300929-add-zero-rows-to-a-matrix

qamStream = qam_mod(bitStream, M);
% same thing as OFDM MOD and DataFrameSize== N/2-1
dimLength = floor(length(qamStream)/(Ld*numberLargest));
assert(dimLength == 0);
dataRemainder = mod(length(qamStream), (Ld*numberLargest));

bitSequence = reshape(qamStream(1:((Ld*numberLargest)*dimLength)), (Ld*numberLargest) , dimLength);
% and add the remainder plus trailing zeros
bitSequence = [bitSequence, [qamStream(end - dataRemainder + 1:end);zeros(Ld*numberLargest-dataRemainder,1)]];
% Now we must expand the bitsequence
OOBBlock = zeros(Nframe/2 - 1 ,(dimLength+1) * Ld);
OOBBlock(OOBIndices, :) = reshape(bitSequence, numberLargest ,(dimLength+1) * Ld);
bitSequence = reshape(OOBBlock, (Nframe/2 - 1)*Ld,  dimLength+1);
% now we add however many Lt*trainblock frames we need to the bottom
dataBlock = [repmat(trainblock, Lt, dimLength+1); bitSequence];
ofdmSignal = dataBlock(:);

% OFDM modulation
[ofdmStream, remainder] = ofdm_mod(ofdmSignal, Nframe, Lprefix);
%[ofdmStream, badbits] = ofdm_qam(bitStream, b, Lprefix);

sizeTrain = length(ofdmStream);

% Channel
tic
[simin,nbsecs,fs] = initparams(ofdmStream,pulse, Lfilter ,fs);
sim('recplay');
out = simout.signals.values;
load chirp.mat;
Rx = alignIO(out, pulse, Lfilter);

Rx = Rx(1:sizeTrain);%Will fail if align IO did not find the correct end result

[rxQamStream, HEstimated, HMatrix] = ofdm_demod(Rx, Nframe, remainder, Lprefix, trainblock, Ld, Lt, dataRemainder, M, OOBIndices);

%rxQamStream = ofdm_deqam(rxOfdmStream, b, badbits, Lprefix, h);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, M);
%rxBitStream = rxQamStream;

% Compute BER
[berTransmission, berRatio] = biterr(bitStream,rxBitStream) % Gray is best for constellation

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

hEstimated = ifft(HEstimated);
HEstimated = 20*log10(abs(HEstimated));

% PLOTS

time = toc;
refreshRate = 1/time;

max_h = max(abs(hEstimated(:)));
max_H = max(abs(HEstimated(:)));
min_H = min(abs(HEstimated(:)));

figure('Name','Visualisation of the demodulation');

subplot(2,2,2); colormap(colorMap); image(imageData); axis image; title('Transmitted image'); drawnow;

for i=1:size(hEstimated,2)
    
    subplot(2,2,1)
    plot(abs(hEstimated(:,i)))
    title('Channel in time domain')
    axis([0 200 0 max_h])
    
    subplot(2,2,3)
    plot(abs(HEstimated(:,i)))
    title('Channel in frequency domain (no DC)');
    axis([-inf inf min_H max_H])
   
    %if floor(i*M*(Ld)/refreshRate)<length(rxBitStream)
    if floor(i*length(rxBitStream)/size(hEstimated,2))<length(rxBitStream)    
        imageRx = bitstreamtoimage(rxBitStream(1:floor(i*length(rxBitStream)/size(hEstimated,2))), imageSize, bitsPerPixel);
    else
        imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);
    end
    subplot(2,2,4); colormap(colorMap); image(imageRx); axis image;
    title("Received image after " + num2str(round(refreshRate*i,2)) + " seconds"); 
    drawnow;
    
    pause(refreshRate)
end