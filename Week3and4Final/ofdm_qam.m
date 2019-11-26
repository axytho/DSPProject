function [OFDM, badBits] = ofdm_qam(bitstream, b, varargin)
switch nargin
    case 2
        preLength = 0;
    case 3
        preLength = varargin{1};
end
bitsPerFrame = sum(b);
dimLength = floor(length(bitstream)/(bitsPerFrame));
%edit freqbin until it creates an int with what we're trying to send

remainder = mod(length(bitstream), (bitsPerFrame));
badBits = bitsPerFrame - remainder;
bitSequence = reshape(bitstream(1:((bitsPerFrame)*dimLength)), (bitsPerFrame) , dimLength);
% and add the remainder plus trailing zeros
bitSequence = [bitSequence, [bitstream(end - remainder + 1:end);zeros(bitsPerFrame-remainder,1)]];
%and now we QAM this
row = 1;
newBitSequence = [];
%sendStuff = bitSequence(40:43, 30:40)
for i = 1:length(b)
    if (b(i)>0)
    qamThis = bitSequence(row:(row+b(i)-1), :);    
    qamInput = qamThis(:);
    newBitSequence = [newBitSequence; qam_mod(qamInput, 2^b(i)).'];
    row = row + b(i);
    else
       newBitSequence = [newBitSequence; zeros(1, dimLength + 1)]; 
    end    
end
%size(newBitSequence)

%Send = newBitSequence(35, 30:50)



%Sent = bitSequence(200:300,26)
% if (remainder >0)
%     %Don't do this, you should throw an error
% %    ME = MException('MyComponent:chooseadifferentN', ...
% %         'This is a bad value for N for the ofdm that you use');
% %     throw(ME)
% end
%continue...
total = [zeros(1, dimLength+(1)); newBitSequence; zeros(1, dimLength+(1)); flip(conj(newBitSequence), 1)];
OFDMRECT = ifft(total, [], 1);
OFDMPREFIXED = [OFDMRECT(end-preLength+1:end, :); OFDMRECT];% Should be 400 twice
%size(OFDMPREFIXED)
OFDM = OFDMPREFIXED(:);
end

