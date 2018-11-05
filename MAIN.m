clear;
clc;
%% 参数设置
Nfft = 64;
carries = 52;
% Nps = 14; % 导频间隔
Cpilot = 4; % 导频子载波个数
Cdata = carries - Cpilot; % 数据子载波个数
Ipilot = [-21 -7 7 21] + Nfft/2; % 导频子载波位置
Idata = [-26:-22 -20:-8 -6:-1 1:6 8:20 22:26] + Nfft/2; % 数据子载波位置 0为直流子载波
Ncp = Nfft / 4; % 保护间隔长度
Nsym_cp = Nfft + Ncp; % 80
Nframe = 100; % 每帧符号数
Nts = 2; % 每帧训练符号符号数
Nsym = Nframe - Nts; % 每帧数据符号数
Nbpsc2 = 2; % QPSK 每个子载波编码比特 导频
Nbpsc4 = 4; % 16QAM 每个子载波编码比特 数据
SNR = 30; % 信噪比
%% 导频
pilot = [1 1 1 -1];

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

%% 串并转换
PARAdata = reshape(MODdata, Nsym, Cdata);

%% 子载波映射
MAPcarries = zeros(Nsym,Nfft);
% 导频子载波映射
for m = 1:Cpilot
    for n = 1:Nsym
        MAPcarries(n, Ipilot(m)) = pilot(m);
    end
end
% 数据子载波映射
for n = 1:Cdata
    MAPcarries(:, Idata(n)) = PARAdata(:, n);
end


%% 对每个符号进行传输
RX_PARAdata = [];
for sym = 1:Nsym
    %% IFFT
    IFFTcarries= IFFT_MOD(MAPcarries(sym, :), Nfft);
    % plot(0:Nfft-1,abs(IFFTcarries));

    %% 添加循环前缀
    cp = IFFTcarries(Nfft-Ncp+1:Nfft);
    CPcarries = [cp, IFFTcarries];
    % plot(0:Nsym_cp-1,abs(CPcarries));

    % %% 并串转换
    % SERIdata = reshape(CPcarries, 1, Nsym*Nsym_cp);
    % 
    % %% 生成长训练符号
    % Lts = [1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 0 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1]; % [1x53] 调制因子
    % TScarrier = zeros(1, Nfft); % [1x64]
    % TScarrier(6:58) = Lts; % [1x64] % 一个频域训练符号
    % IFFT_TScarrier = ifft(TScarrier, Nfft); % [1x64] 一个时域训练符号
    % ts = [IFFT_TScarrier(Nfft-Nts*Ncp+1:Nfft) IFFT_TScarrier IFFT_TScarrier]; % [1x160] 时域训练符号 2CP 2TS
    % plot(0:Nts*Nsym_cp-1,abs(ts));
    % 
    % %% 添加训练符号
    % stream = [ts SERIdata];
    % Lstream = length(stream);
    % plot(0:Lstream-1,abs(stream));

    %% 信道
    OFDMsym = CPcarries;
    
    channel = [(randn+1j*randn) (randn+1j*randn)/2]; % 2抽头信道
    FFTchannel = FFT_MOD(channel, Nfft); % 频域
    Lchannel = length(FFTchannel); % 信道长度
    PdBchannel = 10*log10(abs(FFTchannel.*conj(FFTchannel))); % 信道功率
    RXstream = conv(OFDMsym, channel); % 接收信号
    
    RX_AWGNstream = awgn(RXstream, SNR, 'measured'); % 添加高斯噪声
    
    %% 去CP
    RXdata = RX_AWGNstream(Ncp+1:Nsym_cp);
    
    %% FFT
    RX_FFTdata = FFT_MOD(RXdata, Nfft);
    
    %% LS信道估计
    H_LS = LS_CE(RX_FFTdata, pilot, Ipilot, Nfft, Cpilot); % 使用三次样条插值
    
    %% 信道补偿
    RX_LSdata = RX_FFTdata./H_LS;
    
    %% 串并转换
    RX_PARAdata = [RX_PARAdata; RX_LSdata];
    
end


%% 子载波解映射
DEMAPcarries = zeros(Nsym, Cdata);
for b = 1:Cdata
    DEMAPcarries(:, b) = RX_PARAdata(:, Idata(b));
end

%% 并串转换
RX_SERIdata = reshape(DEMAPcarries, 1, Cdata*Nsym);

%% QAM解调
DEMODdata = DEMOD_QAM(RX_SERIdata);
x = DEMODdata + data;
m = length(find(x == 1));
z = m/960;


%% 绘图分析
plot(DEMAPcarries, 'r*');
axis(2*[-1 1 -1 1]);











