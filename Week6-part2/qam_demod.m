function binary = qam_demod(QAM, M)
binary = qamdemod(QAM,M,'Gray','OutputType','bit','UnitAveragePower',true);
end