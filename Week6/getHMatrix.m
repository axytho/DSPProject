function H = getHMatrix(trainMatrix, trainblock, Lt, N)
rawBlock = reshape(trainMatrix, N/2-1, Lt, size(trainMatrix, 2)); % GO 3D with reshape, see notes
hblock = repmat(trainblock, 1, Lt, size(trainMatrix, 2));
Hblock = rawBlock./hblock;
Haverage = mean(Hblock, 2);
H = reshape(Haverage, N/2-1, size(trainMatrix,2));
end