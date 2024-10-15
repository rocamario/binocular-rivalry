% File: main.m

% Parameter values
tau = 15e-3;      % Time constant
tau_H = 1;        % Time constant
m = 1;            % Excitability
a = 3.4;          % Inhibitory synaptic weight
g = 3;            % Excitatory synaptic weight 
epsilon = 0;      % Excitatory synaptic weight
L = 1;       % Constant input to the left eye
R = 0.95;    % Constant input to the right eye

% Initial state [E_L(0), H_L(0), E_R(0), H_R(0)]
x0 = [0, 0, 0, 0];

% Sampling time and simulation duration
Ts = 1e-3;        % Sampling time (1ms time steps)
StopTime = 20;    % Simulation time in seconds

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            QUESTION 4                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out = sim('binocularRivalry.slx', 'StopTime', '20', 'FixedStep', '1e-3');

time = out.outputData.time;          % Time vector
stateData = out.outputData.data;     % State data matrix

% Plotting the state variables
figure;

subplot(2, 1, 1);
plot(time, stateData(:, 1), 'r');
xlabel('Time (s)');
ylabel('EL');
title('Neuronal activity driven by L(t)');
grid on;

subplot(2, 1, 2);
plot(time, stateData(:, 3), 'g');
xlabel('Time (s)');
ylabel('ER');
title('Neuronal activity driven by R(t)');
grid on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            QUESTION 5                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define the bifurcation parameter range
a_values = linspace(0, 3.5, 100);  

% Preallocate arrays to store max and min values of EL and ER
max_EL = zeros(1, length(a_values));
min_EL = zeros(1, length(a_values));
max_ER = zeros(1, length(a_values)); 
min_ER = zeros(1, length(a_values));  

% Loop over different values of 'a'
for i = 1:length(a_values)
    % Set the current value of 'a'
    a = a_values(i);
    
    % Run the simulation for the current value of 'a'
    out = sim('binocularRivalry.slx', 'StopTime', '20', 'FixedStep', '1e-3');
    
    % Extract the data
    stateData = out.outputData.data;
    time = out.outputData.time;
    EL_data = stateData(:, 1);
    ER_data = stateData(:, 3);
    
    % Discard the transient part (first 5 seconds)
    steady_state_indices = find(time > 5);
    EL_steady = EL_data(steady_state_indices);
    ER_steady = ER_data(steady_state_indices);
    
    % Find the max and min values in the steady state
    max_EL(i) = max(EL_steady);
    min_EL(i) = min(EL_steady);
    max_ER(i) = max(ER_steady);
    min_ER(i) = min(ER_steady);
end

% Plot the bifurcation diagram
figure;
plot(a_values, max_EL, 'r-', 'LineWidth', 2); hold on;
plot(a_values, min_EL, 'r--', 'LineWidth', 2);
plot(a_values, max_ER, 'b-', 'LineWidth', 2);
plot(a_values, min_ER, 'b--', 'LineWidth', 2);
xlabel('Synaptic weight a');
ylabel('EL and ER (Max/Min values)');
title('Bifurcation Diagram');
legend('Max EL', 'Min EL', 'Max ER', 'Min ER');
grid on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            QUESTION 6                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a = 3.4;
% Right stimulus intensity range [0.86, 0.99]
R_values = linspace(0.86, 0.99, 50);  % 50 steps between 0.86 and 0.99

EL_dominance = zeros(1, length(R_values));
ER_dominance = zeros(1, length(R_values));

% Loop over different values of R
for i = 1:length(R_values)
    R = R_values(i);
    
    % Simulate the system for the given R
    out = sim('binocularRivalry.slx', 'StopTime', '20', 'FixedStep', '1e-3');
    
    % Extract the data
    stateData = out.outputData.data;
    time = out.outputData.time;
    EL_data = stateData(:, 1);
    ER_data = stateData(:, 3);
    
    % Discard the transient part (first 5 seconds)
    steady_state_indices = find(time > 5);
    EL_steady = EL_data(steady_state_indices);
    ER_steady = ER_data(steady_state_indices);

    threshold = 0.1;
    
    [n_spikes_EL, EL_ON_duration] = count_spikes(EL_steady, threshold);
    [n_spikes_ER, ER_ON_duration] = count_spikes(ER_steady, threshold);

    EL_dominance(i) = (EL_ON_duration / n_spikes_EL) * Ts;
    ER_dominance(i) = (ER_ON_duration / n_spikes_ER) * Ts;
end

% Plot the results
figure;
plot(R_values, EL_dominance, '-r', 'DisplayName', 'EL Duration');
hold on;
plot(R_values, ER_dominance, '-b', 'DisplayName', 'ER Duration');
xlabel('Right Eye Stimulus Intensity (R)');
ylabel('Dominance duration in seconds');
legend('Location', 'best');
title('Dominance duration of left and right eye');
grid on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            QUESTION 7                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute the alternation period (sum of left and right eye ON durations)
alternation_period = EL_dominance + ER_dominance;

% Compute the alternation rate (inverse of alternation period)
alternation_rate = 1 ./ alternation_period;

% Plot alternation rate vs right eye intensity
figure;
plot(R_values, alternation_rate, '-r', 'DisplayName', 'Alternation Rate');
xlabel('Right Eye Stimulus Intensity (R)');
ylabel('Alternation Rate (Hz)');
title('Alternation Rate vs Right Stimulus Intensity');
legend show;