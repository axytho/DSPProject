fs = 16000;
t = linspace(0,2,fs*2);
sinewave = sin(1500*2*pi*t)';
[simin,nbsecs,fs] = initparams(sinewave,fs);
sim('recplay');
out = simout.signals.values;
load chirp.mat;
sound(out,fs);