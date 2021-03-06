function [simin,nbsecs,fs] = initparams(toplay,fs)
simin = [   zeros(2*fs,2);
            toplay/max(toplay), toplay/max(toplay);
            zeros(1*fs,2)];
nbsecs = size(toplay, 2) / fs + 4;
end