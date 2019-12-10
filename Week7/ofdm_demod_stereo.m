function [QAMResult, Hblock, HMatrix] = ofdm_demod_stereo(OFDM,N, remainder, preLength, trainblock, Ld, Lt, dataRemainder, M)

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

block= reshape(QAMRaw ,(Ld+Lt)*(N/2-1), length(QAMRaw)/ ((Ld+Lt)*(N/2-1)));
trainMatrix = block((Ld*(N/2-1)+ 1):end, :);
HMatrix = getHMatrix(trainMatrix, trainblock, Lt, N);
assert(size(HMatrix,2) == 1); %This is unique to 7.1, because we're only sending one



data = block(1:Ld*(N/2-1), :);
Yk = reshape(data, N/2-1, Ld);
%Hblock = repmat(HMatrix, Ld, 1);
WkMatrix = zeros(N/2-1, Ld);
for i=1:(N/2-1)
    WkMatrix(i, :) = DDequalization(HMatrix(i), Yk(i, :), M);
end
%WkMatrix = repmat((WkMatrix(:,1)), 1, Ld); If you want to simulate week 6
% with only one data packet and one training packet


QAMResult = data(:) .* conj(WkMatrix(:));
Hblock = 1./conj(WkMatrix);


QAMResult = QAMResult(1:end-Ld*(N/2-1)+dataRemainder);
end

