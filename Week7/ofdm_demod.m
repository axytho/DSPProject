function [QAMResult, Hblock, HMatrix] = ofdm_demod(OFDM,N, remainder, preLength, trainblock, Ld, Lt, dataRemainder, M, OOBIndices)

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
trainMatrix = block(1:Lt*(N/2-1), :);
HMatrix = getHMatrix(trainMatrix, trainblock, Lt, N);
assert(size(HMatrix,2) == 1); %This is unique to 7.1, because we're only sending one


data = block((Lt*(N/2-1)+ 1):end, :);
Yk = reshape(data, N/2-1, Ld); %This only works if we're certain that we've only got one block
%Hblock = repmat(HMatrix, Ld, 1);


WkMatrix = DDequalization(HMatrix, Yk, M);

%WkMatrix = repmat((WkMatrix(:,1)), 1, Ld); If you want to simulate week 6
% with only one data packet and one training packet


QAMResult = data(:) .* conj(WkMatrix(:));
Hblock = 1./conj(WkMatrix);

QAMReshapeForOOB = reshape(QAMResult, N/2 -1, Ld);
QAMResultOOB = QAMReshapeForOOB(OOBIndices, :);
QAMResult = QAMResultOOB(:);

QAMResult = QAMResult(1:end-Ld*length(OOBIndices)+dataRemainder);
end

