function [QAMResult, h] = ofdm_demod(OFDM,N, remainder, preLength, trainBlockOrH, train)



%Deprefix
dimLength = length(OFDM)/(N + preLength)
bitSequence = reshape(OFDM, N + preLength , dimLength);
bitSequence = bitSequence((preLength+1):end, :);
%bit = bitSequence(:, 12800);
QAMRECT = fft(bitSequence, [], 1);



%QAMRECT(:, 12800) % Debug
if train
    divisor = [0, trainBlockOrH.', 0, flip(conj(trainBlockOrH.'))].';
    size(divisor)
    H = (QAMRECT(:, 1)./divisor);
    H(1) = 0;
    H(N/2 +1) = 0;
    h = ifft(H);
    
else
    h = trainBlockOrH;
    h = [h, zeros(1, N - length(h))];
    H = (fft(h));
    %H(N/2+1) = 1; % is equal to 0, but should really be 1, or something
    %Original = QAMRECT(:,12800)
    QAMRECT = QAMRECT./H.';
    %Result = QAMRECT(240:260,26)
end

QAMValues = QAMRECT(2:(N/2), 1:end-1);
QAMResult = [QAMValues(:); QAMRECT(2:remainder+1, end)];
end

