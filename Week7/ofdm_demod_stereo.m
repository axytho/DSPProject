function [QAMResult, Hblock] = ofdm_demod_stereo(Received, N, remainder, preLength, trainblock, Ld, Lt, dataRemainder)
[QAMResult, Hblock] = ofdm_demod_beamformer(Received,N, remainder, preLength, trainblock, Ld, Lt, dataRemainder);
end

