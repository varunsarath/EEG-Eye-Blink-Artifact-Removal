function D = Matrice(Ytrue,Yhat,Fs)
%Compute Daa or Dsd for input segment, input is one segment with multi channels

N = length(Ytrue(:,1));
D = zeros(N,1);
for i = 1:N
    [Pyy_hat,fs] = pwelch(Yhat(i,:),[],[],[],Fs,'centered');
    [Pyy_true,~] = pwelch(Ytrue(i,:),[],[],[],Fs,'centered');
    fs = 2*pi*fs/Fs;
    D(i) = sqrt(trapz(fs,(10*log10(Pyy_true./Pyy_hat).^2))/(2*pi));
end
end

