function dx_dt = binocularRivalryModel(x)
    % Extract the state variables from x
    EL = x(1);  % Neuronal activity driven by L(t)
    HL = x(2);  % Hyperpolarizing current of the left eye
    ER = x(3);  % Neuronal activity driven by R(t)
    HR = x(4);  % Hyperpolarizing current of the right eye
    
    L = x(5);
    R = x(6);

    a = x(7);
    m = x(8);
    epsilon = x(9);
    g = x(10);
    tau = x(11);
    tau_H = x(12);

    % Define the activation function S(x) = max(0, x)
    S = @(y) max(0, y);
    
    % The four equations of the binocular rivalry model
    dEL_dt = (-EL + m * S(L - a * ER + epsilon * EL - g * HL)) / tau;
    dHL_dt = (EL - HL) / tau_H;
    dER_dt = (-ER + m * S(R - a * EL + epsilon * ER - g * HR)) / tau;
    dHR_dt = (ER - HR) / tau_H;

    % Return derivatives as a vector
    dx_dt = [dEL_dt, dHL_dt, dER_dt, dHR_dt];
end