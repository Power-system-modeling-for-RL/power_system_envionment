global Tqoprime Tdoprime ang xdpprime xqpprime d_0 H d_1 sync_spd stepsize Tdopprime Tqopprime Mf omega_g omega_n Qset Tm Dp Dq K Vn J KA

inv_volt = psi(1); %machine one internal voltage in complex
cur_inv = cur(1);
inverter_complex_power = inv_volt*conj(cur_inv);
% base and scalable parameters
improved=1;
S_original = 1000;
V_original = 110;
Srating = 100e6*9*real(inverter_complex_power) * mac_pot(1,1);    % 100e6
Vrating = 24e3/sqrt(3);     % 24e3/sqrt(3); 24e3 is usually a line line voltage value. Line phase is divided by sqrt(3)
Kp = Srating/S_original;
Kv = Vrating/V_original;
omega_base = 2*pi*sys_freq;
S_base = 100e6*9;
V_base = Vrating;
I_base = S_base/(3*V_base);
Z_base = V_base/I_base;
Y_base = 1/Z_base;
% References and Initial States
Pset = real(inverter_complex_power) * mac_pot(1,1);    % VSM real power generation
Qset = imag(inverter_complex_power) * mac_pot(1,1);    % VSM reactive power generation
Vn =abs(inv_volt);
omega_n = 2*pi*sys_freq/omega_base;
Tm = Pset/omega_n;
Vg = Vn; %  Assume at steady state
E = Vn;
omega = omega_n;
Mfif = E/omega*sqrt(2);
theta_g = angle(inv_volt);  % terminial angle
theta= theta_g;  % Initial guess ( or 0.01)
omega_g = omega_n;  % grid omega = omega_n
% LCL filter
Ls = 2.2e-3 * (Kv^2)/Kp;
Rs = 0.5 * (Kv^2)/Kp;
C = 22e-6 * Kp/(Kv^2);
R = 1000 * (Kv^2)/Kp;
Lg = 2.2e-3 * (Kv^2)/Kp;
Rg = 0.5 * (Kv^2)/Kp;
% LCL
Zs = Rs + jay * 2 * pi * sys_freq * Ls;
Zg = Rg + jay * 2 * pi * sys_freq * Lg;
Zc = (1/(-jay * 2 * pi * sys_freq * C) * R)/(1/(-jay * 2 * pi * sys_freq * C) + R);
% Wye to delta transfermation
y10 = Zg/(Zs*Zg + Zs*Zc + Zg*Zc)/Y_base;
y20 = Zs/(Zs*Zg + Zs*Zc + Zg*Zc)/Y_base;
y12 = Zc/(Zs*Zg + Zs*Zc + Zg*Zc)/Y_base;
Gs = real(y10);
Bs = imag(y10);
G = real(y12);
B = imag(y12);
Gg = real(y20);
Bg = imag(y20);
alpha = B^2 + G^2;
gamma = Gs + G;
eta = Bs + B;
beta = gamma^2 + eta^2;

Vi = inv_volt;
k = 1000;           % 1000
Dp = 2.0264;             %2.0264
Dq = 222.68;             %222.68
tau_f = 0.002;        % 0.002
tau_v = 0.02;        % 0.02

J = Dp*tau_f  *1000;    % Equation (4) in Ref.1
K = omega_n*Dq*tau_v;    % Equation (6) in Ref.1

omega_q = 1;
delta_omega_max = omega_n * 0.05;
Mf = 1;      % Mf can be any value. It is a virtual parameter. It's value actually only effect K provided by Equation (6). In other words, K and Mf can be considered as one control parameter.               % Mf also used in i_fn and delta_i_f_max
i_f = Mfif/Mf;     % Mfif is based on per unit value.
pc = 0.02;    % 0.02
i_fq = 1;
i_fn = i_f;   % if using the Equation (16) to calculate the i_fn, then the i_f will not equal to i_fn. i_f is given by Equation (7). Equation (7) can be an approximate of Equation (16) accoridng to the paper. In simulation, this let i_f(1) equal to i_fn can get rid of the initial ripple of the ellipse.
delta_i_f_max = (Vn * sqrt(2) * (pc * omega_n + delta_omega_max))/(Mf * (omega_n + delta_omega_max) * (omega_n - delta_omega_max));  % Equation (17) in Ref.1       based on per unit value

