clear;
global jay Y_gpf2;

jay = sqrt(-1);
pst_var % set up global variables
sys_freq = 60;
basrad = 2*pi*sys_freq; % default system frequency is 60 Hz
basmva = 100;
syn_ref = 0 ;     % synchronous reference frame
d2asbegp1;  % load system profile
tol = 1e-8;   % tolerance for convergence
iter_max = 100; % maximum number of iterations
acc = 1.0;   % acceleration factor
flag = 2; %           flag      - 1, form new Jacobian every iteration -2, form new Jacobian every other iteration
display = 'y'; %           display   - 'y', generate load-flow study report else, no load-flow study report
[bus_sol,line_sol,line_flow] =  loadflow(bus,line,tol,iter_max,acc,display,flag);
 mac_indx;
 exc_indx;
 pss_indx;
flag_mac_sub = 0; % flag - 0 - initialization  1 - network interface computation 2 - generator dynamics computation  3 - state matrix building         
flag_pss = 0;
flag_smpexc=0;
mac_sub(0,1,bus_sol,flag_mac_sub);
pss(0,1,bus,flag_pss);
smpexc(0,1,bus,flag_smpexc);
 y_switch;
 
 %##########################all generators' voltage and current in complex
 psi = psi_re + jay*psi_im;
cur = Y_gpf2*psi; %post fault generator admittance matrix

 inverter_initialization;%%% calls inverter_initialization.m file
system_parameter_initialization;
% Joonyoung, you don't have to care about the above code
%###################dynamic simulation 
for i=1:total_steps
    [spd,edprime,eqprime,ang,vex,psikd,psikq,E_ter,pss1,pss2,pss3,pss_out,omega,i_f,theta,V_TR,reward] = power_system_enviroment(spd,edprime,eqprime, ang,vex,psikd,psikq,pss1,pss2,pss3,pss_out,omega,i_f,theta,V_TR,J);
spd_r(:,i) = spd;
omega_r(:,i) = omega;
reward_r(:,i) = reward;
ang_r(:,i) = ang;
theta_r(:,i) = theta;
end
%################ plot result
result_plot;