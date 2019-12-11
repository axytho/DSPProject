function [ofdmStream1, ofdmStream2, remainder] = ofdm_mod_stereo(QAM,N, preLength, a, b)
%code to make sure we can get an int dimelength
dimLength = floor(length(QAM)/(N/2 - 1));
%edit freqbin until it creates an int with what we're trying to send

remainder = mod(length(QAM), (N/2 - 1));
bitSequence = reshape(QAM(1:((N/2-1)*dimLength)), (N/2 - 1) , dimLength);
% and add the remainder plus trailing zeros
bitSequence = [bitSequence, [QAM(end - remainder + 1:end);zeros(N/2-1-remainder,1)]];

% multiply into 2 pieces, then send both
bitSequence1 = bitSequence .* repmat(a(2:N/2), 1, dimLength+1);
total1 = [zeros(1, dimLength+(1)); bitSequence1; zeros(1, dimLength+(1)); flip(conj(bitSequence1), 1)];
OFDMRECT1 = ifft(total1, [], 1);
OFDMPREFIXED1 = [OFDMRECT1(end-preLength+1:end, :); OFDMRECT1];
ofdmStream1 = OFDMPREFIXED1(:);

bitSequence = bitSequence .* repmat(b(2:N/2), 1, dimLength+1);
total = [zeros(1, dimLength+(1)); bitSequence; zeros(1, dimLength+(1)); flip(conj(bitSequence), 1)];
OFDMRECT = ifft(total, [], 1);
OFDMPREFIXED = [OFDMRECT(end-preLength+1:end, :); OFDMRECT];
ofdmStream2 = OFDMPREFIXED(:);
end

