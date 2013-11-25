clear all, clc, clf;

path_gnss = '../../gnss/' ;
path_model = '../tsim/model/' ;
addpath(path_gnss);
addpath(path_model);

data_model = 0 ;
ms = 3 ;
N = 16368 ;
rays = 3 ;

ifsmp.sats = [3, 2, 4] ;
ifsmp.delays = [5687, 300, 100] ;
ifsmp.fd = 16.368e6 ;


% get the data
if data_model == 1
    ifsmp.vars = [1, 1, 1] ;
    ifsmp.fs = [4.0923e6, 4.095e6, 4.090e6] ;
    ifsmp.fd = 16.368e6 ;
    ifsmp.snr_db = -20 ;
    
    [x, sig, sats, delays, signoise] = get_if_signal(ifsmp, ms, rays) ;
    fprintf('Model\n');
else    
    %sig_from_file = readdump_txt('./data/flush.txt', ms*N);	% create data vector
    %save('./data/flush.txt.mat', 'sig_from_file') ;
    load('./data/flush.txt.mat') ;
    sig = sig_from_file(1:ms*N) ;
	fprintf('Real\n');
end ; % if model

% Main satellite
x_ca16 = ca_get(ifsmp.sats(1), 0) ;
x_ca16 = repmat(x_ca16, ms + 1, 1);

tau = 64;
iteration = 1 ;
sig_dma = zeros(N,1);
for k=1:iteration
    sig_dma = sig_dma + ... 
           sig((k-1)*N + 1: k*N) .* sig((k-1)*N + 1 + tau: k*N + tau);
end

sig_dma = sig_dma ./ iteration;

Fnyq = ifsmp.fd/2 ;       % Nyquist freq
Fc=Fnyq/2 ;             % cut-off freq [Hz]
[b,a]=butter(2, Fc/Fnyq);

sig_filt_dma = filter(b, a, sig_dma) ;

%plot([sig_dma(1:100), sig_filt_dma(1:100)])

SIG_FILT_DMA = fft(sig_filt_dma);

% generate local replica of the new code
ca_new_tmp = x_ca16(1:N) .* x_ca16(1+tau : N+tau);
CA_NEW_TMP = fft(ca_new_tmp);

% correlate
acx = ifft(CA_NEW_TMP .* conj(SIG_FILT_DMA));
acx = sqrt(acx .* conj(acx));

% [acx, ca_phase]
[peak, pos] = max(acx) ;
fprintf('sat: %02d\tE = %.2f\t pos=%d\n', ifsmp.sats(1), peak, pos) ;

%fprintf('var=%.2f std %.2f\n', var(acx), std(acx)) ;
%plot(acx); return ;

ca_dma = circshift(x_ca16, ifsmp.delays(1)) ;
%ca_dma = circshift(x_ca16, pos) ;
sig_cos = real(sig .* ca_dma(1:length(sig))) ;
%sig_cos = real(sig) ;
%plot(sig_after_dma(1:100))
sig_after_dma = sig_cos(1:3*N) ;

ca16 = get_ca_code16(N/16,3) ;
y = sig(1:N).*circshift(ca16(:), 5687-1 ) ;
Y = fftshift(fft(y)) ;
Y2 = Y.*conj(Y) ;
plot((-16368/2:16368/2-1)*1e3,Y2,'y-','LineWidth',2) ;
set(gca,'Color',[0 0 0]) ;
set(gca,'XColor',[0.7 0 0]) ;
set(gca,'YColor',[0.7 0 0]) ;
grid on ;
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filter incomig signal
%doppler_delta = 25e3 ;
%left_side = (4.092e6 - doppler_delta) / (ifsmp.fd/2) ;
%right_side = (4.092e6 + doppler_delta) / (ifsmp.fd/2) ;
%[b,a]=butter(2, [left_side, right_side]);
%sig_after_dma = filter(b, a, sig_after_dma) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make me quadruple
acf_iteration = 10 ;
X = fft(sig_after_dma) ;
XX(1, :) = X.*conj(X) ;
rxx = ifft(XX .^ acf_iteration) ;
rxx = rxx ./ max(rxx) ;

%X = fft(rxx) ;
%XX(1, :) = X.*conj(X) ;
%rxx = ifft(XX .^ acf_iteration) ;
%rxx = rxx ./ max(rxx) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AR model
b = ar_model([rxx(1); rxx(2); rxx(3)]) ;
[poles, omega0, Hjw0] = get_ar_pole(b) ;
freq = omega0*ifsmp.fd/2/pi 

pwelch(rxx, 3*N), phd_figure_style(gcf) ;

%semilogy(abs(fft(rxx(1:N))))
%    title(sprintf('ms: %d, ACF iteration: %d estimated freq: %.0f \n', ...
%        length(sig_after_dma) / N, acf_iteration, freq)) ;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END
rmpath(path_gnss);
rmpath(path_model);