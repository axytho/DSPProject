function out_aligned = alignIO(out, pulse)
[correlation, lags] = xcorr(out, pulse);
[~, index] = max(correlation);
lag = lags(index)
out_aligned = 1;
end