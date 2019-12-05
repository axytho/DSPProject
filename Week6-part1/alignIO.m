function out_aligned = alignIO(out, pulse, filterLength)
[correlation, lags] = xcorr(out, pulse);
[~, index] = max(correlation);
lag = lags(index)+length(pulse)-20+5*filterLength;
out_aligned = out(lag:end);
end