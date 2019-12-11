function [QAMResult, Hblock] = ofdm_demod_beamformer(OFDM,N, remainder, preLength, trainblock, Ld, Lt, dataRemainder)



%Deprefix
dimLength = length(OFDM)/(N + preLength);
bitSequence = reshape(OFDM, N + preLength , dimLength);
bitSequence = bitSequence((preLength+1):end, :);
%bit = bitSequence(:, 12800);
QAMRECT = fft(bitSequence, [], 1);
%Not corrected with H
QAMValues = QAMRECT(2:(N/2), 1:end-1);
QAMRaw = [QAMValues(:); QAMRECT(2:remainder+1, end)];
% Now we correct for the remainder
size(QAMRaw);

block= reshape(QAMRaw ,(Ld+Lt)*(N/2-1), length(QAMRaw)/ ((Ld+Lt)*(N/2-1)));
trainMatrix = block(1:(Lt*(N/2-1)), :);
HMatrix = getHMatrix(trainMatrix, trainblock, Lt, N);
Hblock = repmat(HMatrix, Ld, 1);
%correctedDataBlock = block(1:(Ld*(N/2-1)), :)./ repmat(H12, Ld, size(block, 2));

%correctedDataBlock = block((Lt*(N/2-1)+1):end, :)./ repmat(H12(2:N/2), Ld, size(block, 2));
correctedDataBlock = block((Lt*(N/2-1)+1):end, :)./ Hblock;
QAMResult = correctedDataBlock(:);
QAMResult = QAMResult(1:end-Ld*(N/2-1)+dataRemainder);
end

