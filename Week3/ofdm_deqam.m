function result = ofdm_deqam(OFDM,b, badbits, varargin)
if nargin == 3
   preLength = 0;
elseif nargin > 3
   preLength = varargin{1};
end
length(b)
N = length(b) * 2 + 2;
%Deprefix
dimLength = length(OFDM)/(N + preLength);
bitSequence = reshape(OFDM, N + preLength , dimLength);
bitSequence = bitSequence((preLength+1):end, :);
%bit = bitSequence(:, 12800);
QAMRECT = fft(bitSequence, [], 1);
%QAMRECT(:, 12800) % Debug
if nargin==5
    h = varargin{2};
    h = [h, zeros(1, N - length(h))];
    H = (fft(h));
    %H(N/2+1) = 1; % is equal to 0, but should really be 1, or something
    %Original = QAMRECT(:,12800)
    QAMRECT = QAMRECT./H.';
    %Result = QAMRECT(240:260,26)
end

QAMValues = QAMRECT(2:(N/2), 1:end);
resultMatrix = [];
for i = 1:length(b)
     if (b(i) > 0) % If 0 we can ignore the 0 matrix on this bin
     qamOutput = qam_demod(QAMValues(i, :), 2^b(i));
     %size(qamOutput)
     qamRect = reshape(qamOutput, b(i), dimLength);
     resultMatrix = [resultMatrix; qamRect];
     end    
end
%receivedStuff = resultMatrix(40:43, 30:40)
%size(resultMatrix)
result = resultMatrix(:);
result = result(1:end-badbits);
end

