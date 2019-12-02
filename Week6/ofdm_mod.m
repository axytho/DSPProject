function [OFDM, remainder] = ofdm_mod(QAM, trainblock, N, varargin)
switch nargin
    case 2
        preLength = 0;
    case 3
        preLength = varargin{1};
    case 4
        preLength = varargin{1};
end

Ld = 100; % data frames
Lt = 100; % training frames
k = 0; bits = [];

while (k < max(Lt,Ld))
    bits = [bits; QAM; trainblock];
    k = k+1;
end
if (Lt > Ld)
    bits = [bits; repmat(trainblock,Lt-Ld,1)];
else
    bits = [bits; repmat(QAM,Ld-Lt,1)];
end
    
% code to make sure we can get an int dimlength
dimLength = floor(length(bits)/(N/2 - 1));
% edit freqbin until it creates an int with what we're trying to send

remainder = mod(length(bits), (N/2 - 1));
bitSequence = reshape(bits(1:((N/2-1)*dimLength)), (N/2 - 1) , dimLength);
% and add the remainder plus trailing zeros
bitSequence = [bitSequence, [bits(end - remainder + 1:end); zeros(N/2-1-remainder,1)]];

total = [zeros(1, dimLength+(1)); bitSequence; zeros(1, dimLength+(1)); flip(conj(bitSequence), 1)];
OFDMRECT = ifft(total, [], 1);
OFDMPREFIXED = [OFDMRECT(end-preLength+1:end, :); OFDMRECT];
OFDM = OFDMPREFIXED(:);
end