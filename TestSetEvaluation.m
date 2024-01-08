function [x_reconstructed,Daa_train,Dsd_train] = TestSetEvaluation(test_eeg_ref,L,D,N,Fs,blinks,Hh)

P = length(test_eeg_ref(1,:));  % Number of sample points in each channel
p = 0:P-1;
t =p/Fs;
length_blinks = length(blinks);

% %% Outliers remove
% max_val = max(abs(test_eeg_ref), [], 2);
% sorted = sort(max_val, 'descend');
% normal = sorted(3);

for i = 1:N
    for j = 1:P
        if j ~= 1
            if (abs(test_eeg_ref(i,j))>100)
                test_eeg_ref(i,j) = test_eeg_ref(i,j-1);
            end
        end
    end
end

%% Vivualize eye blinks indices
figure(1)

blinks_plot = zeros(1,P);
for i = 1:length_blinks
    blinks_plot(blinks(i)) = 1;
end

subplot(2,1,1)
plot(p,blinks_plot);
ylim([0,1.2]);
title('Eye blinks indices n')
xlabel('n')

subplot(2,1,2)
plot(t,blinks_plot);
ylim([0,1.2]);
title('Eye blinks indices t')
xlabel('t/s')


blinks_indices = zeros(99,2);


for i = 1:99
    blinks_indices(i,:) = [blinks((i-1)*321+1),blinks(i*321)];%the number 321 need to be changed to window length +1
end

blinks_indices = [blinks_indices,blinks_indices(:,2)-blinks_indices(:,1)];

segs_indices = zeros(99,4);
for i = 1:99
    segs_indices(i,:) = [blinks_indices(i,1)-round(blinks_indices(i,3)/2),blinks_indices(i,1),blinks_indices(i,2),blinks_indices(i,2)+round(blinks_indices(i,3)/2)];
    if i ~= 1
        if (segs_indices(i,1) >= segs_indices(i-1,2)) && (segs_indices(i,1) <= segs_indices(i-1,3))
            segs_indices(i,1) = segs_indices(i-1,3)+1;
        end
    end
    if i ~= 99
        if (segs_indices(i,4) >= segs_indices(i+1,2)) && (segs_indices(i,4) <= segs_indices(i+1,3))
            segs_indices(i,4) = segs_indices(i+1,2)-1;
        end
    end
end
segs_indices(99,4) = P;

%% Filter test set
% Apply H to eye blinks and neighbors
x_est(99).train = [];
v_est(99).train = [];
x_reconstructed = zeros(size(test_eeg_ref));
v_reconstructed = zeros(size(test_eeg_ref));
for i = 1:99
    [SegY,~] = ComputeSegYV(segs_indices,test_eeg_ref,i); % i decides different segments
    [Y_stack,~] = CovMatrix_Stack(SegY,L,D);
    %[V_stack,~] = CovMatrix_Stack(SegV,L,D);
    SegV_onesided = test_eeg_ref(:,segs_indices(i,3)+1:segs_indices(i,4));
    [V_stack_onesided,~] = CovMatrix_Stack(SegV_onesided,L,D);
    X_stack = Hh*Y_stack;
    V_stack_filtered = Hh*V_stack_onesided;
    x_est(i).train = Unstack(X_stack,L,D,N);
    v_est(i).train = Unstack(V_stack_filtered,L,D,N);
    x_reconstructed(:,segs_indices(i,2):segs_indices(i,3)) = Unstack(X_stack,L,D,N);
    v_reconstructed(:,segs_indices(i,3)+1:segs_indices(i,4)) = Unstack(V_stack_filtered,L,D,N);
end

for i = 1:N
    for j = 1:P
        if j ~= 1
            if (abs(x_reconstructed(i,j))>100)
                x_reconstructed(i,j) = x_reconstructed(i,j-1);
            end
        end
    end
end

%% Metrics for test set
Daa_train = zeros(N,1);
Dsd_train = zeros(N,1);

for i = 1:99
    [SegY,SegV] = ComputeSegYV(segs_indices,test_eeg_ref,i);
    SegV_onesided = test_eeg_ref(:,segs_indices(i,3)+1:segs_indices(i,4));
    Daa_train = Daa_train + Matrice(SegV,SegY - x_est(i).train,Fs)/99;
    Dsd_train = Dsd_train + Matrice(SegV,SegV_onesided - v_est(i).train,Fs)/99;
end



%% Vivualization
DataPlot(test_eeg_ref,x_reconstructed,test_eeg_ref - x_reconstructed,p);
end

