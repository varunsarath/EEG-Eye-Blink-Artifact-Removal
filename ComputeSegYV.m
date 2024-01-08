function [Y_seg,V_seg] = ComputeSegYV(segs_indices,train_eeg_ref,i_seg)

% i_seg: The ith segments
V_seg = [train_eeg_ref(:,segs_indices(i_seg,1):segs_indices(i_seg,2)-1),train_eeg_ref(:,segs_indices(i_seg,3)+1:segs_indices(i_seg,4))];
Y_seg = train_eeg_ref(:,segs_indices(i_seg,2):segs_indices(i_seg,3));

end