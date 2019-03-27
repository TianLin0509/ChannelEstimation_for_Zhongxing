Noise = 1;  %是否加入噪声
noise_power = 1;
N = 250;  %例子而已
K = 6;   %稀疏度
%构造傅里叶变换矩阵
for i = 0 : N-1
    for j = 0 : N-1
        DFT_matrix(i+1, j +1) = exp(-1j * 2 * pi * i * j / N);
    end
end

index = randi([1,25], K, 1);  % 非零元素索引的索引
td_channel = zeros(N,1);
td_channel(index) = complex(randn(K,1),randn(K,1));  %构造稀疏的时域信道
fd_channel = DFT_matrix *td_channel;
pilot_step = 8;   %每隔4个点设置一个pilot
pilot_index = 1 : pilot_step : N;
y = fd_channel(pilot_index);  %对应于压缩感知中的y
if Noise
    y = y + complex(randn(length(y),1),randn(length(y),1)) * sqrt(noise_power);
end
x = td_channel(1:25);  %对应于压缩感知中的x
phi_matrix = DFT_matrix(pilot_index, 1:25);  %对应于x,y的phi
%验证：
sum(y - phi_matrix * x)  
%进行压缩感知重构：
rebuild_x = CS_OMP( y,phi_matrix,K);
rebuild_y = phi_matrix * rebuild_x;
diff1 = (rebuild_y - y);
norm(diff1, 'fro')^2
rebuild_fd_channel = DFT_matrix(:, 1:25) * rebuild_x;
diff = (rebuild_fd_channel - fd_channel);
C = norm(diff, 'fro')^2   %估计的误差模的平方和
Ea = C / norm(fd_channel, 'fro')^2
Eb = length(pilot_index)/2500
E = Ea + Eb
