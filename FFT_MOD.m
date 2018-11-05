% This function performs fft of the symbol after the cyclic prefix has been
% removed
function output_fft=FFT_MOD(data_without_cp, nfft)
    output_fft=fft(data_without_cp,nfft);
    output_fft=ifftshift(output_fft);
    
end