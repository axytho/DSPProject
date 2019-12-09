
M = 4;
channelChangeRate = 0.0001;
Hk = [ones(12, 1) * (0.5+0.6j); ones(65, 1) * (0.5+0.9j)];%; ones(300, 1) * (0.52+0.59j); ones(400, 1) * (0.51+0.55j)];
bits = randi([0, 1], 77*log2(M), 1);
Xk = qam_mod(bits, M);
Nk = 0.3;
Yknoiseless = Hk .* Xk;
SNR = 30050;
Yk = awgn(Yknoiseless, SNR);
% 7.1.2
delta = 0.01;
Wk = 1/conj(Hk(1)) + delta; %initial value
iterations = 76;
% Implementing normalized LMS
WkMatrix = [Wk; zeros(iterations, 1)];
mu = 1;
alpha = 0;
for j =1:iterations
    XkEstimated = qam_mod(qam_demod(conj(WkMatrix(j)) * Yk(j+1), M), M);
    WkMatrix(j+1) = WkMatrix(j) + mu * Yk(j+1) / ( alpha + abs(Yk(j+1))^2) *conj(XkEstimated - conj(WkMatrix(j)) * Yk(j+1));
end
error = abs(conj(WkMatrix) - 1./( Hk(1:(iterations+1))));
Hk
plot(1:length(WkMatrix), error);


