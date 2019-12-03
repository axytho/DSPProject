function [QAMResult, trainingResult, h] = ofdm_demod(OFDM, N, remainder, preLength, trainBlockOrH, train)

Ld = 100; % data frames
Lt = 100; % training frames

%Deprefix
dimLength = length(OFDM)/(N + preLength)
bitSequence = reshape(OFDM, N + preLength , dimLength);
bitSequence = bitSequence((preLength+1):end, :);
%bit = bitSequence(:, 12800);
RECT = fft(bitSequence, [], 1);

%QAMRECT(:, 12800) % Debug
if train
    divisor = [0, trainBlockOrH.', 0, flip(conj(trainBlockOrH.'))].';
    size(divisor)
    H = (RECT(:, 1)./divisor);
    H(1) = 0;
    H(N/2 +1) = 0;
    h = ifft(H);
    
else
    h = trainBlockOrH;
    h = [h, zeros(1, N - length(h))];
    H = (fft(h));
    %H(N/2+1) = 1; % is equal to 0, but should really be 1, or something
    %Original = RECT(:,12800)
    RECT = RECT./H.';
    %Result = RECT(240:260,26)
end

Values = RECT(2:(N/2), 1:end-1);
Result = [Values(:); RECT(2:remainder+1, end)];
QAMResult = ;
trainingResult = ;
end
