M = 4;
channelChangeRate = 0.0001;
iterations = 76;
Hk = [ones(12, 1) * (0.5+0.6j); ones(65, 1) * (0.5+0.9j)];%; ones(300, 1) * (0.52+0.59j); ones(400, 1) * (0.51+0.55j)];
t = 1:(iterations+1);
%Hk = [0.3+0.03*t + 0.4*j+0.02*t*j].';
bits = randi([0, 1], (iterations+1)*log2(M), 1);
Xk = qam_mod(bits, M);
Nk = 0.3;
Yknoiseless = Hk .* Xk;
SNR = 30050;
Yk = awgn(Yknoiseless, SNR);
% 7.1.2
delta = 0.01;
Wk = 1/conj(Hk(1)) + delta; %initial value

% Implementing normalized LMS
WkMatrix = [Wk; zeros(iterations,1)];
%mu = 0.9;
mu = linspace(0.5,1.5,11);
figure('Name','Error signals over the number of iterations')
for i = 1:length(mu)
    for j = 1:iterations
        XkEstimated = qam_mod(qam_demod(conj(WkMatrix(j)) * Yk(j+1), M), M);
        WkMatrix(j+1) = WkMatrix(j) + mu(i) * Yk(j+1) / abs(Yk(j+1))^2 *conj((XkEstimated - conj(WkMatrix(j)) * Yk(j+1)));
    end
    error = abs(conj(WkMatrix) - 1./( Hk(1:(iterations+1))));
    plot(1:length(WkMatrix), error,'displayname',num2str(mu(i)));
    hold on;
end
title("Error signal over the number of iterations");
xlabel('Number of iterations')
ylabel('Error')
xlim([0 iterations])
[hleg] = legend('show');
title(hleg,'Stepsize (mu)');