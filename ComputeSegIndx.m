function segs_indices = ComputeSegIndx(train_eeg_ref,num_blinks,blinks)
P = length(train_eeg_ref(1,:));  % Number of sample points in each channel
p = 0:P-1;
length_blinks = length(blinks);

blinks_plot = zeros(1,P);
for i = 1:length_blinks
    blinks_plot(blinks(i)) = 1;
end

blinks_indices = zeros(num_blinks,2);

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

segs_indices = zeros(num_blinks,4);
for i = 1:num_blinks
    segs_indices(i,:) = [blinks_indices(i,1)-blinks_indices(i,3)/2,blinks_indices(i,1),blinks_indices(i,2),blinks_indices(i,2)+blinks_indices(i,3)/2];
    if i ~= 1
        if (segs_indices(i,1) >= segs_indices(i-1,2)) && (segs_indices(i,1) <= segs_indices(i-1,3))
            segs_indices(i,1) = segs_indices(i-1,3)+1;
        end
    end
end
end

