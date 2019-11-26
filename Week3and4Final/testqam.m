numberOfValues = 1200;
M = 32;
binary = randi([0, 1], numberOfValues, 1);
y = qam_mod(binary, M);
avgPower = mean(abs(y).^2);
SNR = 25;
rxSig = awgn(y,SNR);
%rxSig = y;
cd = comm.ConstellationDiagram('ShowReferenceConstellation',false);
step(cd,rxSig);
newBinary = qam_demod(rxSig, M);
[number,ratio] = biterr(binary,newBinary)