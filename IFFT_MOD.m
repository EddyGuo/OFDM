% This function performs iift on the mapped data
function output_ifft=IFFT_MOD(mapped_data, nfft)
    mapped_data=fftshift(mapped_data);
    output_ifft=ifft(mapped_data,nfft);    
end