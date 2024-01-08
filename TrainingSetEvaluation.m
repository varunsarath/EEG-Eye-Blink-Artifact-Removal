function [x_reconstructed,Daa_train,Dsd_train] = TrainingSetEvaluation(train_eeg_ref,L,D,N,Fs,blinks,Hh)

P = length(train_eeg_ref(1,:));  % Number of sample points in each channel
p = 0:P-1;
t =p/Fs;
length_blinks = length(blinks);

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


blinks_indices = zeros(8,2);

c = 1;
for i = 2:length(blinks_plot)
    if (blinks_plot(i) == 1) && (blinks_plot(i-1) == 0)
        blinks_indices(c,1) = i;
    end
    if (blinks_plot(i) == 0) && (blinks_plot(i-1) == 1)
        blinks_indices(c,2) = i-1;
        c = c+1;
    end
end

blinks_indices = [blinks_indices,blinks_indices(:,2)-blinks_indices(:,1)];

segs_indices = zeros(8,4);
for i = 1:8
    segs_indices(i,:) = [blinks_indices(i,1)-blinks_indices(i,3)/2,blinks_indices(i,1),blinks_indices(i,2),blinks_indices(i,2)+blinks_indices(i,3)/2];
    if i ~= 1
        if (segs_indices(i,1) >= segs_indices(i-1,2)) && (segs_indices(i,1) <= segs_indices(i-1,3))
            segs_indices(i,1) = segs_indices(i-1,3)+1;
        end
    end
end

%% Filter training set
% Apply H to eye blinks and neighbors
x_est(8).train = [];
v_est(8).train = [];
x_reconstructed = zeros(size(train_eeg_ref));
v_reconstructed = zeros(size(train_eeg_ref));
for i = 1:8
    [SegY,~] = ComputeSegYV(segs_indices,train_eeg_ref,i); % i decides different segments
    [Y_stack,~] = CovMatrix_Stack(SegY,L,D);
    %[V_stack,~] = CovMatrix_Stack(SegV,L,D);
    SegV_onesided = train_eeg_ref(:,segs_indices(i,3)+1:segs_indices(i,4));
    [V_stack_onesided,~] = CovMatrix_Stack(SegV_onesided,L,D);
    X_stack = Hh*Y_stack;
    V_stack_filtered = Hh*V_stack_onesided;
    x_est(i).train = Unstack(X_stack,L,D,N);
    v_est(i).train = Unstack(V_stack_filtered,L,D,N);
    x_reconstructed(:,segs_indices(i,2):segs_indices(i,3)) = Unstack(X_stack,L,D,N);
    v_reconstructed(:,segs_indices(i,3)+1:segs_indices(i,4)) = Unstack(V_stack_filtered,L,D,N);
end

%% Metrics for training set
Daa_train = zeros(N,1);
Dsd_train = zeros(N,1);

for i = 1:8
    [SegY,SegV] = ComputeSegYV(segs_indices,train_eeg_ref,i);
    SegV_onesided = train_eeg_ref(:,segs_indices(i,3)+1:segs_indices(i,4));
    Daa_train = Daa_train + Matrice(SegV,SegY - x_est(i).train,Fs)/8;
    Dsd_train = Dsd_train + Matrice(SegV,SegV_onesided - v_est(i).train,Fs)/8;
end

%% Vivualization
%DataPlot(train_eeg_ref,x_reconstructed,train_eeg_ref - x_reconstructed,p);
end

