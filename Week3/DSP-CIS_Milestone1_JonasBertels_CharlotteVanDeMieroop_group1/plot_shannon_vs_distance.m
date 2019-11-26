% distances of the experiment (in cm)
distances = [5,10,15,20,25,30];

% values of the capacities are calculated with compute_shannon.m
capacities = [1.1513e+04,1.1066e+04,1.0023e+04,9.6560e+03,9.4823e+03,9.3635e+03];

plot(distances, capacities, '-o')
xlim([0 35]);
xlabel('Distance between recorder and loudspeaker (cm)');
ylabel('Channel capacity (bits/s)');