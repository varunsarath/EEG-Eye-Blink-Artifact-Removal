
clc
clear
close all;

test=readtable ('test_mean_removed');
test_eeg_ref = table2array(test(:,2:end));
test_normalized= zscore(test_eeg_ref, 0,2);
signal= test_normalized(1,:);


signalLength = length(signal);

%ground truth for training set
rise_fall=[871,1076,1575,1900,2662,3025,3281,3708,4720,5071,5238,5685,6724,7217,7538,7823];


threshold = 2;

aboveThresholdIndices = find(signal > threshold);

%groundTruthIndices = rise_fall;

% Find continuous segments in aboveThresholdIndices
continuousSegments = find_continuous_segments(aboveThresholdIndices, signal);

maxValueIndicesArray = [];

% Plotting things-
figure;
plot(signal, 'DisplayName', 'Signal');
hold on;

% threshold line
thresholdLine = threshold * ones(1, signalLength);
plot(thresholdLine, 'r--', 'DisplayName', 'Threshold');

% points above the threshold
scatter(aboveThresholdIndices, signal(aboveThresholdIndices), 'filled', 'g', 'DisplayName', 'Above Threshold');

% vertical lines at ground truth indices(use only for training set)
%for i = 1:length(groundTruthIndices)
 %  plot([groundTruthIndices(i), groundTruthIndices(i)], ylim, 'k--');
%end

for i = 1:length(continuousSegments)
    [~, maxIndex] = max(signal(continuousSegments{i}));
    maxValueIndicesArray = [maxValueIndicesArray, continuousSegments{i}(maxIndex)];
end

%clean up the multiple indices stored within maxDistance in
%maxValueIndicesArray-
i=1;
reduced_max_indices=[];
while i<=length(maxValueIndicesArray)


current = maxValueIndicesArray(i);
current_within=[current];
for j = i+1:length(maxValueIndicesArray)

if maxValueIndicesArray(j)-current <=150
  current_within= horzcat(current_within,maxValueIndicesArray(j));
end
end

signal_values=signal(current_within);
[ignore,maxind]= max(signal_values);
reduced_max_indices= horzcat(reduced_max_indices,current_within(maxind));
i=i+length(current_within);

end

scatter(reduced_max_indices, signal(reduced_max_indices), 'r', 'filled');
% Set labels and legend
xlabel('Sample Index');
ylabel('Signal Value');
legend('Location', 'best');
title('Signal with Threshold Detection, Ground Truth, and Continuous Segments with Max Values');
hold off;

% Display the array of indices with maximum values
%disp('Indices with Maximum Values in Each Segment:');
%disp(reduced_max_indices);





% detected_edges=[];
% for i=1:length(reduced_max_indices)
% detected_edges=horzcat(detected_edges,[reduced_max_indices(i)-100,reduced_max_indices(i)+200]);
% 
% end

detected_edges_300=[];
detected_edges_280=[];
detected_edges_320=[];
for i=1:length(reduced_max_indices)
detected_edges_300=horzcat(detected_edges_300,[reduced_max_indices(i)-75,reduced_max_indices(i)+225]);
detected_edges_280=horzcat(detected_edges_280,[reduced_max_indices(i)-70,reduced_max_indices(i)+210]);
detected_edges_320=horzcat(detected_edges_320,[reduced_max_indices(i)-80,reduced_max_indices(i)+240]);
end



%% Load data
load("Training_EEG.mat");
load("Test_EEG.mat");

% detected_edges = load("blinks_detected_280.mat");
% detected_edges = detected_edges.detected_edges_280;
detected_edges = detected_edges_320;
%%%%%%%%

L = 5;
Fs = 400;
D = 0.8; %Overlap rate for y in Ry = YY'

chan_subsets(1).subsets=[1,2,6,9];
chan_subsets(2).subsets=[5,12,13,19];
chan_subsets(3).subsets=[8,10,11,16];
chan_subsets(4).subsets=[4,15,17,18];
chan_subsets(5).subsets=[3,7,14];

table_chan = [1,2,6,9,5,12,13,19,8,10,11,16,4,15,17,18,3,7,14];

train=readtable ('train_mean_removed');
train_eeg_ref = table2array(train(:,2:end));

test=readtable ('test_mean_removed');
test_eeg_ref = table2array(test(:,2:end));
test_normalized= zscore(test_eeg_ref, 0,2);

%% Compute H
H(5).h = [];
segs_indices = ComputeSegIndx(train_eeg_ref(chan_subsets(1).subsets,:),8,blinks);
for i = 1:5
    H(i).h = Hcompute(segs_indices,train_eeg_ref(chan_subsets(i).subsets,:),8,L,D);
end

%% Evaluate training data set
Metrics_aa_train = [];
Metrics_sd_train = [];
for i = 1:5
    N = length(chan_subsets(i).subsets);
    subset_training = train_eeg_ref(chan_subsets(i).subsets,:);
    [x_reconstructed,Daa,Dsd] = TrainingSetEvaluation(subset_training,L,D,N,Fs,blinks,H(i).h);
    Metrics_aa_train = [Metrics_aa_train;Daa];
    Metrics_sd_train = [Metrics_sd_train;Dsd];
end
Daa_train(table_chan) = Metrics_aa_train;
Dsd_train(table_chan) = Metrics_sd_train;
Daa_train = round(Daa_train,3)';
Dsd_train = round(Dsd_train,3)';
MetricPlot(Daa_train,Dsd_train);

%% Evaluate test data set
num_detected = 99;
SegLength = 300;
P = length(test_normalized(1,:));  % Number of sample points in each channel
p = 0:P-1;
t =p/Fs;

blinks_test = [];
for i = 1:num_detected
    blinks_test = [blinks_test,detected_edges((i-1)*2+1):detected_edges(i*2)];
end

Metrics_aa_test = [];
Metrics_sd_test = [];
for i = 1:5
    N = length(chan_subsets(i).subsets);
    %subset_test = test_normalized(chan_subsets(i).subsets,:);
    subset_test = test_eeg_ref(chan_subsets(i).subsets,:);

    [x_reconstructed,Daa,Dsd] = TestSetEvaluation(subset_test,L,D,N,Fs,blinks_test,H(i).h);
    Metrics_aa_test = [Metrics_aa_test;Daa];
    Metrics_sd_test = [Metrics_sd_test;Dsd];
end
Daa_test(table_chan) = Metrics_aa_test;
Dsd_test(table_chan) = Metrics_sd_test;
Daa_test = round(Daa_test,3)';
Dsd_test = round(Dsd_test,3)';









