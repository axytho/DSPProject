function [OFDM, remainder] = ofdm_mod(QAM,N, varargin)
switch nargin
    case 2
        preLength = 0;
        freqbin = 1;
    case 3
        preLength = varargin{1};
        freqbin = 1;
    case 4
        preLength = varargin{1};
        %freqbin = varargin{2};
end
%code to make sure we can get an int dimelength
dimLength = floor(length(QAM)/(N/2 - 1));
%edit freqbin until it creates an int with what we're trying to send

remainder = mod(length(QAM), (N/2 - 1));
bitSequence = reshape(QAM(1:((N/2-1)*dimLength)), (N/2 - 1) , dimLength);
% and add the remainder plus trailing zeros
bitSequence = [bitSequence, [QAM(end - remainder + 1:end);zeros(N/2-1-remainder,1)]];
%Sent = bitSequence(200:300,26)
% if (remainder >0)
%     %Don't do this, you should throw an error
% %    ME = MException('MyComponent:chooseadifferentN', ...
% %         'This is a bad value for N for the ofdm that you use');
% %     throw(ME)
% end
%continue...
total = [zeros(1, dimLength+(1)); bitSequence; zeros(1, dimLength+(1)); flip(conj(bitSequence), 1)];
OFDMRECT = ifft(total, [], 1);
OFDMPREFIXED = [OFDMRECT(end-preLength+1:end, :); OFDMRECT];
OFDM = OFDMPREFIXED(:);
end

