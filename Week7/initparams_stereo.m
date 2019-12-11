function [simin,nbsecs,fs] = initparams_stereo(toplayL, toplayR, pulse, irlength, fs)

simin = [   zeros(2*fs,2);
            pulse/max(pulse), pulse/max(pulse);
            zeros(irlength*5, 2);
            toplayL/max(toplayL), toplayR/max(toplayR);
            zeros(1*fs,2)];
nbsecs = size(simin, 1) / fs + 1;
end