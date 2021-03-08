function [omega,theta,i_f,d_omega] = inverter(current,voltage,base,omega,basrad,omega_g,omega_n,stepsize,i_f,theta,Qset,Tm,Dp,Dq,K,Vn,E_voltage,J)
%inverter model
%this is a VSM
Ss = voltage*conj(current);  % VSM complex power generation
Ps = real(Ss) * base;    % VSM real power generation
Qs = imag(Ss) * base;    % VSM reactive power generation
Te = Ps/omega;
d_omega = 1/J*(Tm - Te) - Dp/J*(omega - omega_n);
d_i_f = 1/(K)*(Qset - Qs) + Dq/(K)*(Vn - E_voltage);
d_theta= basrad*(omega - omega_g);
omega = omega+ d_omega*stepsize;
i_f = i_f + d_i_f * stepsize;
theta= theta+ d_theta*stepsize; 
end