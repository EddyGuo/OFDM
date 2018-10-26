clear;
clc;
%% 参数设置
Nfft = 64;
carries = 52;
Nps = 14; % 导频间隔
Cpilot = 4; % 导频子载波个数
Cdata = carries - Cpilot; % 数据子载波个数
Ipilot = [-21 -7 7 21]; % 导频子载波位置
Idata = [-26:-22 -20:-8 -6:-1 1:6 8:20 22:26]; % 数据子载波位置 0为直流子载波
Ncp = Nfft / 4; % 保护间隔长度
Nframe = 7; % 每帧符号数
Nts = 2; % 每帧训练符号符号数
Nsym = Nframe - Nts; % 每帧数据符号数
Nbpsc2 = 2; % QPSK 每个子载波编码比特 导频
Nbpsc4 = 4; % 16QAM 每个子载波编码比特 数据
SNR = 5; % 信噪比
%% 生成信号
Ndata = Cdata * Nsym * Nbpsc4; % 随机信号总比特数
data=randi([0,1],1,Ndata);
% plot(data);
%% 信号使用16QAM调制
MODdata = MOD_QAM(data);
plot(MODdata, '*');
axis([-5 5 -5 5]);
MODdata_REAL = real(MODdata);
MODdata_IMAG = imag(MODdata);
%% 生成导频
Npilot = Cpilot * Nsym * Nbpsc2;
pilot=randi([0,1],1,Npilot);
%% 导频使用QPSK调制
MODpilot = MOD_QPSK(pilot);
plot(MODpilot, '*');
axis([-1.5 1.5 -1.5 1.5]);
MODpilot_REAL = real(MODpilot);
MODpilot_IMAG = imag(MODpilot);
%% 串并转换
PARAdata = reshape(MODdata, Cdata, Nsym);
PARApilot = reshape(MODpilot, Cpilot, Nsym);
%% 子载波映射
MAPcarries = zeros(Nfft, Nsym);
% 导频子载波映射
for m = 1:Cpilot
    MAPcarries(Ipilot(m)+Nfft/2, :) = PARApilot(m, :);
end
% 数据子载波映射
for n = 1:Cdata
    MAPcarries(Idata(n)+Nfft/2, :) = PARAdata(n, :);
end
%% IFFT
IFFTstream = IFFT_MOD(MAPcarries, Nfft)';
plot(0:Nfft-1,abs(IFFTstream));



