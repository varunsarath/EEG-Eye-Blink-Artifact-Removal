% Function to find continuous segments in indices
function segments = find_continuous_segments(indices, signal)
    diffIndices = diff(indices);
    segmentStarts = [indices(1), indices(find(diffIndices > 1) + 1)];
    segmentEnds = [indices(find(diffIndices > 1)), indices(end)];
    
    % Find the index with the maximum value in each segment
    segments = arrayfun(@(start, stop) start:stop, segmentStarts, segmentEnds, 'UniformOutput', false);
end