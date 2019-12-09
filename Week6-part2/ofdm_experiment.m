numberOfValues = 12000;
M = 16;
Nframe = 24;
binary = randi([0, 1], numberOfValues, 1);
y = qam_mod(binary, M);
size(y)
avgPower = mean(abs(y).^2);
OFDM = ofdm_mod(y, Nframe, 3);
SNR = 50;
OFDMNoise = awgn(OFDM,SNR);
QAM = ofdm_demod(OFDMNoise, Nframe, 3);
rxSig = QAM;
cd = comm.ConstellationDiagram('ShowReferenceConstellation',false);
step(cd,rxSig);
newBinary = qam_demod(rxSig, M);
[number,ratio] = biterr(binary,newBinary(1:numberOfValues));