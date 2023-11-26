function [ f, A ] = fourier( x,y )
% [ f, P ] = fourier( x,y )
%computes the fourier transform


x_ = linspace(0,x(end)-x(1),2*floor(length(x)/2));

y_ = interp1(x,y,x_+x(1));

fs = 1/(x_(2)-x_(1));
L = length(x_);

Afft = fft(y_);

A2 = abs(Afft/L);
A = A2(1:L/2+1);
A(2:end-1) = 2*A(2:end-1);
f = fs*(0:(L/2))/L;



end

