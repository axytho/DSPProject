fs = 16000;
t = linspace(0,2,fs*2);

sig = zeros(1, fs*2)';
sig(1) = 0.01;
[simin,nbsecs,fs] = initparams(sig,fs);
sim('recplay');
out = simout.signals.values;
noiseOut = pwelch(out,dftsize*2,0,dftsize,fs);



% Whatever signal you'd like
frequencies= [100, 200, 500, 1000, 1500, 2000, 4000, 6000];
sig = zeros(1, fs*2);
for frequency = frequencies
    sig = sig + sin(frequency * 2 * pi*t);
end
sig = sig';

%now: 


[simin,nbsecs,fs] = initparams(sig,fs);
sim('recplay');
out = simout.signals.values;
signalOut = pwelch(out,dftsize*2,0,dftsize,fs) - noiseOut;
%signalOut./noiseOut
channelCapacity = fs/(2*size(signalOut, 1)) * sum(log2(1+ signalOut./noiseOut));
