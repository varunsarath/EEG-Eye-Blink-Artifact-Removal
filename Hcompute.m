function Hh = Hcompute(segs_indices,train_eeg_ref,num_blinks,L,D)

%Compute the filter
%Input: 
%       segs_indices: Segments indices, each row contains start point of
%                     a segment, start point of the eye blink, end point of 
%                     the eye blink and end point of a segment.
%       train_eeg_ref: Data from 4 channels used to design H.
%       num_blinks: Number of segments.
%       L: Length of stacked frame.
%       D: Overlap rate for y in Ry = YY'

seg(num_blinks).segs = [];
V(num_blinks).v = [];
Y(num_blinks).y = [];
R(num_blinks).v = [];
R(num_blinks).y = [];
H(num_blinks).h = [];
V(8).stack = [];
Y(8).stack = [];
for i = 1:num_blinks
    seg(i).segs = train_eeg_ref(:,segs_indices(i,1):segs_indices(i,4));
    V(i).v = [train_eeg_ref(:,segs_indices(i,1):segs_indices(i,2)-1),train_eeg_ref(:,segs_indices(i,3)+1:segs_indices(i,4))];
    Y(i).y = train_eeg_ref(:,segs_indices(i,2):segs_indices(i,3));
    for j = 1:(length(V(i).v(1,:))-L)/(L*(1-D))+1
        V(i).stack = [V(i).stack,reshape(V(i).v(:,(j-1)*round(L*(1-D))+1:(j-1)*round(L*(1-D))+L)',[],1)];
        R(i).v = V(i).stack*V(i).stack'/(length(V(i).v(1,:))-L+1);
    end
    for j = 1:(length(Y(i).y(1,:))-L)/(L*(1-D))+1
        Y(i).stack = [Y(i).stack,reshape(Y(i).y(:,(j-1)*round(L*(1-D))+1:(j-1)*round(L*(1-D))+L)',[],1)];
        R(i).y = Y(i).stack*Y(i).stack'/(length(Y(i).y(1,:))-L+1);
    end
    R(i).x = R(i).y-R(i).v;
    R(i).y_inv = pinv(R(i).y);
    H(i).h = R(i).x*R(i).y_inv;
end

Hh = zeros(size(H(i)));
for i = 1:num_blinks
    Hh = Hh + H(i).h/num_blinks;
end

end