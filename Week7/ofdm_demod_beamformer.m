function [QAMResult, Hblock] = ofdm_demod_beamformer(OFDM,N, remainder, preLength, trainblock, Ld, Lt, dataRemainder, H12)



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
trainMatrix = block((Ld*(N/2-1)+ 1):end, :);
HMatrix = getHMatrix(trainMatrix, trainblock, Lt, N);
Hblock = repmat(HMatrix, Ld, 1);
%correctedDataBlock = block(1:(Ld*(N/2-1)), :)./ repmat(H12, Ld, size(block, 2));

correctedDataBlock = block(1:(Ld*(N/2-1)), :)./ repmat(H12, Ld, size(block, 2));

QAMResult = correctedDataBlock(:);
QAMResult = QAMResult(1:end-Ld*(N/2-1)+dataRemainder);
end

