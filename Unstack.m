function x = Unstack(X,L,D,N)

%N: Number of channels

x = reshape(X(:,1),L,[])';
    rows = L*D+1:L;
    c = length(rows);
    for n = 1:N-1
        rows = [rows,rows(c*(n-1)+1:end)+L];
    end
    for j = 2:length(X(1,:))
        x = [x,reshape(X(rows,j),round(L*(1-D)),[])'];
    end
end