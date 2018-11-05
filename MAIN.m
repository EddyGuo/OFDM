clear;
clc;
%% ��������
Nfft = 64;
carries = 52;
% Nps = 14; % ��Ƶ���
Cpilot = 4; % ��Ƶ���ز�����
Cdata = carries - Cpilot; % �������ز�����
Ipilot = [-21 -7 7 21] + Nfft/2; % ��Ƶ���ز�λ��
Idata = [-26:-22 -20:-8 -6:-1 1:6 8:20 22:26] + Nfft/2; % �������ز�λ�� 0Ϊֱ�����ز�
Ncp = Nfft / 4; % �����������
Nsym_cp = Nfft + Ncp; % 80
Nframe = 100; % ÿ֡������
Nts = 2; % ÿ֡ѵ�����ŷ�����
Nsym = Nframe - Nts; % ÿ֡���ݷ�����
Nbpsc2 = 2; % QPSK ÿ�����ز�������� ��Ƶ
Nbpsc4 = 4; % 16QAM ÿ�����ز�������� ����
SNR = 30; % �����
%% ��Ƶ
pilot = [1 1 1 -1];

%% �����ź�
Ndata = Cdata * Nsym * Nbpsc4; % ����ź��ܱ�����
data=randi([0,1],1,Ndata);
% plot(data);

%% �ź�ʹ��16QAM����
MODdata = MOD_QAM(data);
plot(MODdata, '*');
axis([-5 5 -5 5]);
MODdata_REAL = real(MODdata);
MODdata_IMAG = imag(MODdata);

%% ����ת��
PARAdata = reshape(MODdata, Nsym, Cdata);

%% ���ز�ӳ��
MAPcarries = zeros(Nsym,Nfft);
% ��Ƶ���ز�ӳ��
for m = 1:Cpilot
    for n = 1:Nsym
        MAPcarries(n, Ipilot(m)) = pilot(m);
    end
end
% �������ز�ӳ��
for n = 1:Cdata
    MAPcarries(:, Idata(n)) = PARAdata(:, n);
end


%% ��ÿ�����Ž��д���
RX_PARAdata = [];
for sym = 1:Nsym
    %% IFFT
    IFFTcarries= IFFT_MOD(MAPcarries(sym, :), Nfft);
    % plot(0:Nfft-1,abs(IFFTcarries));

    %% ���ѭ��ǰ׺
    cp = IFFTcarries(Nfft-Ncp+1:Nfft);
    CPcarries = [cp, IFFTcarries];
    % plot(0:Nsym_cp-1,abs(CPcarries));

    % %% ����ת��
    % SERIdata = reshape(CPcarries, 1, Nsym*Nsym_cp);
    % 
    % %% ���ɳ�ѵ������
    % Lts = [1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 0 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1]; % [1x53] ��������
    % TScarrier = zeros(1, Nfft); % [1x64]
    % TScarrier(6:58) = Lts; % [1x64] % һ��Ƶ��ѵ������
    % IFFT_TScarrier = ifft(TScarrier, Nfft); % [1x64] һ��ʱ��ѵ������
    % ts = [IFFT_TScarrier(Nfft-Nts*Ncp+1:Nfft) IFFT_TScarrier IFFT_TScarrier]; % [1x160] ʱ��ѵ������ 2CP 2TS
    % plot(0:Nts*Nsym_cp-1,abs(ts));
    % 
    % %% ���ѵ������
    % stream = [ts SERIdata];
    % Lstream = length(stream);
    % plot(0:Lstream-1,abs(stream));

    %% �ŵ�
    OFDMsym = CPcarries;
    
    channel = [(randn+1j*randn) (randn+1j*randn)/2]; % 2��ͷ�ŵ�
    FFTchannel = FFT_MOD(channel, Nfft); % Ƶ��
    Lchannel = length(FFTchannel); % �ŵ�����
    PdBchannel = 10*log10(abs(FFTchannel.*conj(FFTchannel))); % �ŵ�����
    RXstream = conv(OFDMsym, channel); % �����ź�
    
    RX_AWGNstream = awgn(RXstream, SNR, 'measured'); % ��Ӹ�˹����
    
    %% ȥCP
    RXdata = RX_AWGNstream(Ncp+1:Nsym_cp);
    
    %% FFT
    RX_FFTdata = FFT_MOD(RXdata, Nfft);
    
    %% LS�ŵ�����
    H_LS = LS_CE(RX_FFTdata, pilot, Ipilot, Nfft, Cpilot); % ʹ������������ֵ
    
    %% �ŵ�����
    RX_LSdata = RX_FFTdata./H_LS;
    
    %% ����ת��
    RX_PARAdata = [RX_PARAdata; RX_LSdata];
    
end


%% ���ز���ӳ��
DEMAPcarries = zeros(Nsym, Cdata);
for b = 1:Cdata
    DEMAPcarries(:, b) = RX_PARAdata(:, Idata(b));
end

%% ����ת��
RX_SERIdata = reshape(DEMAPcarries, 1, Cdata*Nsym);

%% QAM���
DEMODdata = DEMOD_QAM(RX_SERIdata);
x = DEMODdata + data;
m = length(find(x == 1));
z = m/960;


%% ��ͼ����
plot(DEMAPcarries, 'r*');
axis(2*[-1 1 -1 1]);











