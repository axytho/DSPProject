function resultMatrix = LSE(inputMatrix)
resultMatrix = zeros(size(inputMatrix,1), size(inputMatrix, 3));
A = ones(size(inputMatrix,2),1);
for i=1:size(inputMatrix, 3)
resultMatrix(:, i) = (A\inputMatrix(:,:,i).');
end
end