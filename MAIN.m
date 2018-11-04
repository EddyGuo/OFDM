clear;
clc;
%% ��������
Nfft = 64;
carries = 52;
Nps = 14; % ��Ƶ���
Cpilot = 4; % ��Ƶ���ز�����
Cdata = carries - Cpilot; % �������ز�����
Ipilot = [-21 -7 7 21] + Nfft/2; % ��Ƶ���ز�λ��
Idata = [-26:-22 -20:-8 -6:-1 1:6 8:20 22:26] + Nfft/2; % �������ز�λ�� 0Ϊֱ�����ز�
Ncp = Nfft / 4; % �����������
Nsym_cp = Nfft + Ncp; % 80
Nframe = 7; % ÿ֡������
Nts = 2; % ÿ֡ѵ�����ŷ�����
Nsym = Nframe - Nts; % ÿ֡���ݷ�����
Nbpsc2 = 2; % QPSK ÿ�����ز�������� ��Ƶ
Nbpsc4 = 4; % 16QAM ÿ�����ز�������� ����
SNR = 15; % �����
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
PARAdata = reshape(MODdata, Cdata, Nsym);

%% ���ز�ӳ��
MAPcarries = zeros(Nfft, Nsym);
% ��Ƶ���ز�ӳ��
for m = 1:Cpilot
    for n = 1:Nsym
        MAPcarries(Ipilot(m), n) = pilot(m);
    end
end
% �������ز�ӳ��
for n = 1:Cdata
    MAPcarries(Idata(n), :) = PARAdata(n, :);
end

%% IFFT
IFFTcarries= IFFT_MOD(MAPcarries, Nfft);
% plot(0:Nfft-1,abs(IFFTcarries));

%% ���ѭ��ǰ׺
cp = IFFTcarries(Nfft-Ncp+1:Nfft, :);
CPcarries = [cp;IFFTcarries];
% plot(0:Nsym_cp-1,abs(CPcarries));

%% ����ת��
SERIdata = reshape(CPcarries, 1, Nsym*Nsym_cp);

%% ���ɳ�ѵ������
Lts = [1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 0 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1]; % [1x53] ��������
TScarrier = zeros(1, Nfft); % [1x64]
TScarrier(6:58) = Lts; % [1x64] % һ��Ƶ��ѵ������
IFFT_TScarrier = IFFT_MOD(TScarrier, Nfft); % [1x64] һ��ʱ��ѵ������
ts = [IFFT_TScarrier(Nfft-Nts*Ncp+1:Nfft) IFFT_TScarrier IFFT_TScarrier]; % [1x160] ʱ��ѵ������ 2CP 2TS
plot(0:Nts*Nsym_cp-1,abs(ts));

%% ���ѵ������
stream = [ts SERIdata];
Lstream = length(stream);
plot(0:Lstream-1,abs(stream));

%% �ŵ�
% K_dB = 15;
% channel = RicModel(K_dB,Lstream);
% TXstream = stream + channel;
channel = [(randn+1j*randn) (randn+1j*randn)/2]; % 2��ͷ�ŵ�
FFTchannel = fft(channel, Nfft); % Ƶ��
Lchannel = length(FFTchannel); % �ŵ�����
PdBchannel = 10*log10(abs(FFTchannel.*conj(FFTchannel))); % �ŵ�����
RXstream = conv(stream, channel, 'same'); % �����ź�
RX_AWGNstream = awgn(RXstream, SNR, 'measured'); % ��Ӹ�˹����

%% ͬ��
STOstream = RX_AWGNstream;

%% ����ת��
RX_PARAdata = reshape(STOstream, Nsym_cp, Nframe);

%% ȥCP��ѵ������
RXdata = RX_PARAdata(Ncp+1:Nsym_cp, Nts+1:Nframe);

%% FFT
RX_FFTdata = FFT_MOD(RXdata, Nfft);

%% LS�ŵ�����
SYM_LS = [];
for k = 1:Nsym
    % �������ŵ��ŵ�����
H_LS = LS_CE(RX_FFTdata(:, k), pilot', Ipilot, Nfft, Cpilot); % ʹ������������ֵ
    % ��������ŵ�����
    SYM_LS = [SYM_LS; H_LS];
end
%% ����
RX_LSdata = RX_FFTdata./SYM_LS';

%% ���ز���ӳ��
DEMAPcarries = zeros(Cdata, Nsym);
for b = 1:Cdata
    DEMAPcarries(b, :) = RX_LSdata(Idata(b), :);
end

%% ����ת��
RX_SERIdata = reshape(DEMAPcarries, Cdata*Nsym, 1);
plot(DEMAPcarries, 'r*');
axis([-5 5 -5 5]);
%% QAM���
DEMODdata = DEMOD_QAM(RX_SERIdata);
x = DEMODdata + data;
m = length(find(x == 1));
z = m/960;













