function [spd, omega,ang,theta] = env(spd,edprime,eqprime,ang,vex,psikd,psikq)
% machine spd
d_spd = (pmech-Te-d_0.*(spd-sync_spd)-d_1.*(spd-sync_spd))./(2.*H);
spd= spd + stepsize*d_spd;
% transient voltage in the dq axix
d_edprime = (-edprime - mac_pot(:,11).*(edprime-psikq) - mac_pot(:,12).*curqg)./Tqoprime;
edprime = edprime + stepsize*d_edprime;
d_eqprime = (vex-fldcur)./Tdoprime;
eqprime = eqprime + stepsize*d_eqprime;
%rotor angle state
d_ang = basrad*(spd-sync_spd);
ang = ang + stepsize*d_ang;
%Field voltage
d_vex = (-vex+KA.*(V_ref-V_TR+  pss_out))./T_A;
vex = vex + stepsize*d_vex;
if  vex<exc_con(:,9)
    vex=exc_con(:,9);
end
if vex>exc_con(:,8)
    vex=exc_con(:,8);
end
%Flux linkage d-axis damper winding
d_psikd = (-psikd+eqprime-mac_pot(:,8).*curdg)./Tdopprime;
psikd = psikd + stepsize*d_psikd;
% Flux linkage q-axix damper winding
d_psikq = (edprime-psikq-mac_pot(:,13).*curqg)./Tqopprime;
psikq = psikq + stepsize*d_psikq;
% generator terminal voltage
eq =(psidpp-xdpprime.*curdg);
ed = -(psiqpp-xqpprime.*curqg);
E_ter = sqrt(ed.^2+eq.^2);
end