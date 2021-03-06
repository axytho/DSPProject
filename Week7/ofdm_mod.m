function [OFDM, remainder] = ofdm_mod(QAM,N, varargin)
switch nargin
    case 2
        preLength = 0;
    case 3
        preLength = varargin{1};
    case 4
        preLength = varargin{1};
end
%code to make sure we can get an int dimelength
dimLength = floor(length(QAM)/(N/2 - 1));
%edit freqbin until it creates an int with what we're trying to send

remainder = mod(length(QAM), (N/2 - 1));
bitSequence = reshape(QAM(1:((N/2-1)*dimLength)), (N/2 - 1) , dimLength);
% and add the remainder plus trailing zeros
bitSequence = [bitSequence, [QAM(end - remainder + 1:end);zeros(N/2-1-remainder,1)]];

total = [zeros(1, dimLength+(1)); bitSequence; zeros(1, dimLength+(1)); flip(conj(bitSequence), 1)];
OFDMRECT = ifft(total, [], 1);
OFDMPREFIXED = [OFDMRECT(end-preLength+1:end, :); OFDMRECT];
OFDM = OFDMPREFIXED(:);
end

