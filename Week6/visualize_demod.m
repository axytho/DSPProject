figure();

subplot(2,2,1);
title('Channel in time domain');
plot();


subplot(2,2,2);
title('Transmitted image');

subplot(2,2,3);
title('Channel in frequency domain (no DC)');

subplot(2,2,4);
seconds = 5;
title(['Received image after', num2str(seconds) ,'seconds']);