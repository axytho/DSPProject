function QAM = qam_mod(sequence, M)
N = round(log2(M));
%bitSequence = reshape(sequence, N , length(sequence)/N);
bitSequence = sequence;
%QAM = qammod(bitSequence, M, 'InputType', 'bit', 'PlotConstellation',true);
%QAM = qammod(bitSequence, M, 'InputType', 'bit');
QAM = qammod(bitSequence, M, 'Gray', 'InputType','bit','UnitAveragePower',true);
end