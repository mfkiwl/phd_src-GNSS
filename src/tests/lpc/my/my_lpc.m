clc, clear all, clf ;

f = 30 ;
fd = 100 ;
N = 1000 ;

sigma = 0.05 ;
noise = sqrt(sigma) * randn(1,N) ;
sig = sin(2*pi*f / fd * [0:N-1]) ;

x = sig + noise ;  

rxx0 = x * x' / (length(x) - 1) ;
rxx1 = x * [x(2:end), x(1)]' / (length(x) - 1) ;
rxx2 = x * [x(3:end), x(1:2)]' / (length(x) - 1) ;

rxx = [rxx0, rxx1, rxx2];

Rxx = [rxx(1) , rxx(2); rxx(2), rxx(1)] ;

% calculate coef
a = pinv(Rxx) * rxx(2:3)'  ;
a = [1;-a] ;
poles = roots(a) ;
freq = angle(poles(1)) ;

fprintf('Bk=%.02f\t = %.02f\n', ...
        2 / (pi*(2+1)^2 * 0.5/sigma), ...
        -log(abs(poles(1)))*fd/pi) ;

% 1.03 / (p*SNR*(p+1)^0.31)
fprintf('Error estimation %.02f\n', 1.03/(2*(0.5/sigma)*(2+1)^0.31) ) ;
fprintf('resolution: %.02f\t delta:%.02f\t true freq: %d\n', ...
        freq*fd/2/pi, f-freq*fd/2/pi, f) ;
    
Hjw = freqz(1,a) ;
[X,omega] = pwelch(x, 1000) ;

hold off, semilogy(omega,X.*conj(X), 'LineWidth',2);
hold on,semilogy(omega(1:numel(Hjw)),Hjw.*conj(Hjw),'r-','LineWidth',2), grid on
legend('Welch spectrum estimation', '2rd order AR model')