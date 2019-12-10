function [a, b, H12] = fixed_transmitter_side_beamformer(impulseA, impulseB)
H1 = fft(impulseA);
H2 = fft(impulseB);
H12 = sqrt(H1.*conj(H1)+H2.*conj(H2));
a = conj(H1)./H12;
b = conj(H2)./H12;
%f = 1:length(H1);
% plot(f, abs(H1), f, abs(H2), f, abs(H12));
% legend({'H1', 'H2', 'H12'});
end