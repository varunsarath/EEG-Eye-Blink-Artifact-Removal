function DataPlot(train_eeg_ref,x_reconstructed,v_reconstructed,p)
figure('Name','Signals')
for i = 1:length(train_eeg_ref(:,1))
    subplot(length(train_eeg_ref(:,1)),1,i)
    plot(p(1:10000), train_eeg_ref(i,1:10000)+200, 'b', p(1:10000), x_reconstructed(i,1:10000)+100, 'r', p(1:10000), v_reconstructed(i,1:10000), 'g');
    legend('Original Signal','Estimated eye links','Clean EEG'); 
    % plot(p, train_eeg_ref(i,:));
end
end