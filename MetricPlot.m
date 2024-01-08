function MetricPlot(Daa,Dsd)
x = 1:19;
figure('Name','Metrics')
scatter(x,Daa,'o','b','DisplayName','Daa');
hold on;
scatter(x,Dsd,'x','r','DisplayName','Dsd');
title('Plot of Daa and Dsd for 19 channels');
xlabel('Channel');
ylabel('Metrics');
legend('show');
hold off;
end