figure();
x = linspace(0,2*pi,100);
y = sin(x);

subplot(2,2,1);
plot(x,y);
title('Channel in time domain');

subplot(2,2,2); colormap(colorMap); image(imageData); axis image; title('Transmitted image'); drawnow;

subplot(2,2,3);
plot(x,y);
title('Channel in frequency domain (no DC)');

subplot(2,2,4);
plot(x,y);
seconds = 5;
title(['Received image after ', num2str(seconds) ,' seconds']);
