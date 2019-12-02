clear all;
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

% Create trainblock
trainblock = randi([0, 1], (Nframe/2-1)*M, 1);
trainrect = repmat(trainblock, 3, 1);
qamStream = qam_mod(bitStream, M);

A = [1;2;3];
lenA = size(A);
lenA = lenA(1);
%A = repmat(A,3,1);
B = [4;5;6];
lenB = size(B);
lenB = lenB(1);
%B = repmat(B,3,1);
%C = reshape([A B]', [], 1)
str = [];
b = 10;
a = 2;
k = 0;
while (k < min(b,a))
    str = [str; A; B];
    k = k + 1;
end
if (a > b)
    str = [str; repmat(A,a-b,1)];
else
    str = [str; repmat(B,b-a,1)];
end
str