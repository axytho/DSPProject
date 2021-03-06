function Wk = DDequalization(Hk, Yk, M)
%Hk = ones(1000, 1) * (0.5+0.6j) + awgn(((1:1000)*channelChangeRate),20).';
iterations = size(Yk, 2) - 1;
% 7.1.2
Wkinitial = 1./conj(Hk);
% Implementing normalized LMS
WkMatrix = [Wkinitial, zeros(size(Wkinitial, 1), iterations)];
mu = 1;
for j =1:iterations
    XkEstimated = qam_mod(qam_demod(conj(WkMatrix(:, j)) .* Yk(:,j+1), M), M);
    WkMatrix(:, j+1) = WkMatrix(:, j) + mu * Yk(:, j+1) ./ abs(Yk(:, j+1)).^2 .*conj(XkEstimated - conj(WkMatrix(:,j)) .* Yk(: ,j+1));
end
Wk = WkMatrix;
end


