function QAM = ofdm_demod(OFDM,N, remainder, varargin)
if nargin == 3
   preLength = 0;
elseif nargin > 3
   preLength = varargin{1};
end


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

QAMValues = QAMRECT(2:(N/2), 1:end-1);
QAM = [QAMValues(:); QAMRECT(2:remainder+1, end)];
end

