clear;
clc;
%% ��������
Nfft = 64;
carries = 52;
Nps = 14; % ��Ƶ���
Cpilot = 4; % ��Ƶ���ز�����
Cdata = carries - Cpilot; % �������ز�����
Ipilot = [-21 -7 7 21]; % ��Ƶ���ز�λ��
Idata = [-26:-22 -20:-8 -6:-1 1:6 8:20 22:26]; % �������ز�λ�� 0Ϊֱ�����ز�
Ncp = Nfft / 4; % �����������
Nframe = 7; % ÿ֡������
Nts = 2; % ÿ֡ѵ�����ŷ�����
Nsym = Nframe - Nts; % ÿ֡���ݷ�����
Nbpsc2 = 2; % QPSK ÿ�����ز�������� ��Ƶ
Nbpsc4 = 4; % 16QAM ÿ�����ز�������� ����
SNR = 5; % �����
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
%% ���ɵ�Ƶ
Npilot = Cpilot * Nsym * Nbpsc2;
pilot=randi([0,1],1,Npilot);
%% ��Ƶʹ��QPSK����
MODpilot = MOD_QPSK(pilot);
plot(MODpilot, '*');
axis([-1.5 1.5 -1.5 1.5]);
MODpilot_REAL = real(MODpilot);
MODpilot_IMAG = imag(MODpilot);
%% ����ת��
PARAdata = reshape(MODdata, Cdata, Nsym);
PARApilot = reshape(MODpilot, Cpilot, Nsym);
%% ���ز�ӳ��
MAPcarries = zeros(Nfft, Nsym);
% ��Ƶ���ز�ӳ��
for m = 1:Cpilot
    MAPcarries(Ipilot(m)+Nfft/2, :) = PARApilot(m, :);
end
% �������ز�ӳ��
for n = 1:Cdata
    MAPcarries(Idata(n)+Nfft/2, :) = PARAdata(n, :);
end
%% IFFT
IFFTstream = IFFT_MOD(MAPcarries, Nfft)';
plot(0:Nfft-1,abs(IFFTstream));



