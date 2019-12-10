function [QAMResult, Hblock] = ofdm_demod_stereo(Received1, Received2,N, remainder, preLength, trainblock, Ld, Lt, dataRemainder, H12)
[QAMResultA, Hblock] = ofdm_demod_beamformer(Received1,N, remainder, preLength, trainblock, Ld, Lt, dataRemainder, H12);
[QAMResultB, ~] = ofdm_demod_beamformer(Received2,N, remainder, preLength, trainblock, Ld, Lt, dataRemainder, H12);
QAMResult = QAMResultA + QAMResultB;
end

