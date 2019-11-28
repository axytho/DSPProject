close all;

% Variables
fs= 16000;
M=4;
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

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

trainblock = randi([0, 1], (Nframe/2-1)*M, 1);
trainrect = repmat(trainblock, 3, 1);
qamStream = qam_mod(bitStream, M);

