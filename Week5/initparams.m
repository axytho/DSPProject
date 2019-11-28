function [simin,nbsecs,fs] = initparams(toplay, pulse, irlength, fs)

simin = [   zeros(2*fs,2);
            pulse/max(pulse), pulse/max(pulse);
            zeros(irlength*5, 2);
            toplay/max(toplay), toplay/max(toplay);
            zeros(1*fs,2)];
nbsecs = size(toplay, 2) / fs + 4;
end