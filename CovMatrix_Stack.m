function [X_stack,CovX] = CovMatrix_Stack(X,L,D)

X_stack = [];

for j = 1:(length(X(1,:))-L)/(L*(1-D))+1
    X_stack = [X_stack,reshape(X(:,(j-1)*round(L*(1-D))+1:(j-1)*round(L*(1-D))+L)',[],1)];
    CovX = X_stack*X_stack'/(length(X(1,:))-L+1);
end
end