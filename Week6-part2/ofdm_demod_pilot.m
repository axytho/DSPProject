function [QAMResult, h] = ofdm_demod_pilot(OFDM,N, remainder, preLength, trainBlockOrH, train)

% assert train is true!!! don't use this pilot function if you're not using
% training blocks


%Deprefix
dimLength = length(OFDM)/(N + preLength);
bitSequence = reshape(OFDM, N + preLength , dimLength);
bitSequence = bitSequence((preLength+1):end, :);
%bit = bitSequence(:, 12800);
QAMRECT = fft(bitSequence, [], 1);



%QAMRECT(:, 12800) % Debug
if train
    divisor = [0, trainBlockOrH.', 0, flip(conj(trainBlockOrH.'))].';
    % Some of these should actually be 0, but it turns out the channel
    % interpolates for us, so let's just run with it
    % and then 
    HnotInterpolated = (QAMRECT(:, 1)./divisor);
    Hdownandup = upsample(downsample(HnotInterpolated(2:N/2-1),2),2); 
    hMirrored = ifft(Hdownandup);
    hSliced = hMirrored(2:(N/2-1)/2);
    hLowPassed = [hSliced; zeros(length(hMirrored) - length(hSliced), 1)];
    HFrame = fft(hLowPassed);
    H = [0; HFrame; 0; flip(conj(HFrame))];
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

