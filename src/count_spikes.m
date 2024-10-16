% File: count_spikes.m
% Author: Mario Roca - mario.roca@etu-upsaclay.fr

function [number_spikes, on_duration] = count_spikes(E, threshold)
% Iterate through the signal, count the number of "spikes", and compute how
% long the signal stays "on" 
    
    % Initialize variables
    number_spikes = 0;
    on_duration = 0;
    i = 1;
    len = length(E);
    
    % Skip initial values below threshold
    while i <= len && E(i) >= threshold
        i = i + 1;
    end

    % Main loop through the signal
    while i <= len
        % Wait for the rising phase
        while i <= len && E(i) < threshold
            i = i + 1;
        end
        
        % Count time above threshold (on duration)
        start_on = i;
        while i <= len && E(i) >= threshold
            i = i + 1;
        end
        if i <= len && E(i) < threshold  % Only count if there was a full rise and fall
            on_duration = on_duration + (i - start_on);
            number_spikes = number_spikes + 1;
        end
    end
end
