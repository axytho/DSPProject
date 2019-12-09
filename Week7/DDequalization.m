% 7.1.1
M = 4;
channelChangeRate = 0.01;
Hk = ones(1000, 1) * (0.5+0.6j) + awgn(((1:1000)*channelChangeRate),20).';
bits = randi([0, 1], 1000*log2(M), 1);
Xk = qam_mod(bits, M);
Nk = 0.3;
Yknoiseless = Hk .* Xk;
SNR = 30050;
Yk = awgn(Yknoiseless, SNR);
% 7.1.2
delta = 1;
Wk = 1/conj(Hk(1)) + delta; %initial value
iterations = 700;
% Implementing normalized LMS
WkMatrix = [Wk; zeros(iterations, 1)];
mu = 0.5;
for j =1:iterations
    WkMatrix(j+1) = WkMatrix(j) + mu * Yk(j+1) / abs(Yk(j+1))^2 *(Xk(j+1) - conj(WkMatrix(j)) * Yk(j+1));
end
error = abs(conj(WkMatrix) - 1./( Hk(1:(iterations+1))));
plot(1:length(WkMatrix), error);

