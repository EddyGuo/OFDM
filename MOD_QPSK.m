%This function maps every two pilot bits to a QPSK symbol
function ip=MOD_QPSK(pilot)
    length_pilot=length(pilot); % length of the data stream
    ip=zeros(1,floor(length_pilot/2));  % Intializing a matrix with zeros
    % Gray coded Mapping
    % 00 -1-j   01 -1+j   10 1-j     11-1+j
    for ii=1:length_pilot/2
        ip(ii) = 1/sqrt(2)*1i*(1-2*pilot(2*ii)) + 1/sqrt(2)*(1-2*pilot(2*ii-1));
    end
end