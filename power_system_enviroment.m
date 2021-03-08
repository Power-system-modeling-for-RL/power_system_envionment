function [spd,edprime,eqprime,ang,vex,psikd,psikq,E_ter,pss1,pss2,pss3,pss_out,omega,i_f,theta,V_TR,reward,done] = power_system_enviroment(spd,edprime,eqprime, ang,vex,psikd,psikq,pss1,pss2,pss3,pss_out,omega,i_f,theta,V_TR,action)
    %########### generator###############%
    global mac_pot jay Y_gpf2 Tqoprime Tdoprime  xdpprime xqpprime d_0 H d_1 basrad sync_spd stepsize Tdopprime Tqopprime pmech Mf omega_g omega_n Qset Tm  Dp Dq K Vn KA Gpss Tw Td1 Td2 V_ref  T_R T_A pss_pot pss_con exc_con;
    psidpp = mac_pot(:,9).*eqprime + mac_pot(:,10).*psikd;
    E_Isat = mac_pot(:,3).*eqprime.^2 + mac_pot(:,4).*eqprime + mac_pot(:,5);
    if eqprime<0.8
        E_Isat=eqprime;
    end
    psiqpp= mac_pot(:,14).*edprime + mac_pot(:,15).*psikq;
    psidpp = mac_pot(:,9).*eqprime + mac_pot(:,10).*psikd;
    psi_re = sin(ang).*(-psiqpp) + cos(ang).*psidpp; % real part of psi
    psi_im = -cos(ang).*(-psiqpp) + sin(ang).*psidpp; % imag part of psi
    int_volt = psi_re+jay*psi_im;
    cur = Y_gpf2*( psi_re + jay*psi_im);
    cur_re = real(cur);
    cur_im = imag(cur);
    curd = sin(ang).*cur_re - cos(ang).*cur_im; % d-axis current
    curq = cos(ang).*cur_re + sin(ang).*cur_im; % q-axis current
    curdg = curd.*mac_pot(:,1);
    fldcur = E_Isat + mac_pot(:,6).*(eqprime-psikd) + mac_pot(:,7).*curdg;
    curqg =curq.*mac_pot(:,1);
    d_edprime = (-edprime - mac_pot(:,11).*(edprime-psikq) - mac_pot(:,12).*curqg)./Tqoprime;
    d_eqprime = (vex-fldcur)./Tdoprime;
    d_ang= basrad*(spd-sync_spd);
    ang = ang + stepsize*d_ang;
    d_psikd = (-psikd+eqprime-mac_pot(:,8).*curdg)./Tdopprime;
    d_psikq = (edprime-psikq-mac_pot(:,13).*curqg)./Tqopprime;
    edprime= edprime + stepsize*d_edprime;
    eqprime = eqprime + stepsize*d_eqprime;
    psikd = psikd + stepsize*d_psikd;
    psikq = psikq + stepsize*d_psikq;
    eq =(psidpp-xdpprime.*curdg);
    ed = -(psiqpp-xqpprime.*curqg);
    real_p = eq.*curq + ed.*curd;
    Te= real_p.*mac_pot(:,1);
    d_spd =(pmech-Te-d_0.*(spd-sync_spd)-d_1.*(spd-sync_spd))./(2.*H);
    spd= spd + stepsize*d_spd;
    E_ter = sqrt(ed.^2+eq.^2);
    %############# inverter################%
    E_voltage = omega*Mf*i_f/sqrt(2);
    voltage = E_voltage*cos(theta)+jay*E_voltage*sin(theta);
    current = Y_gpf2(1)*voltage + Y_gpf2(2)*int_volt(2) + Y_gpf2(3)*int_volt(3) + Y_gpf2(4)*int_volt(4);
   [omega,theta,i_f,d_omega] = inverter(current,voltage,mac_pot(1,1),omega,basrad,omega_g,omega_n,stepsize,i_f,theta,Qset,Tm,Dp,Dq,K,Vn,E_voltage,action);
   %######### PSS ######################%
    d_vex = (-vex+KA.*(V_ref-V_TR+  pss_out))./T_A;
    var1 = (spd-pss1)./Tw;
    var2 = pss_pot(:,1).*Gpss.*var1+pss2;
    var3 = pss_pot(:,2).*var2+pss3;
    dpss1 = var1;
    pss1= pss1+ stepsize*dpss1;
    dpss2 = ( (sync_spd-pss_pot(:,1)).*Gpss.*var1-pss2)./Td1;
    pss2 = pss2 + stepsize*dpss2;
    dpss3 = ( (sync_spd-pss_pot(:,2)).*var2-pss3)./Td2;
    pss3 = pss3 + stepsize*dpss3;
    pss_out= var3;
    for j=1:length(pss_out)
        if pss_out(j) < pss_con(j,10)
            pss_out(j)=pss_con(j,10);
        end
        if pss_out(j) > pss_con(j,9)
            pss_out(j)=pss_con(j,9);
        end
    end
    %############## EXCITATION ##############%
    d_V_TR=(E_ter-V_TR)./T_R;
    V_TR = V_TR + stepsize*d_V_TR;
    vex = vex + stepsize*d_vex;
    if  vex<exc_con(:,9)
        vex=exc_con(:,9);
    end
    if vex>exc_con(:,8)
        vex=exc_con(:,8);
    end
    %%% reward
    omega_dev = omega-omega_n;
    reward =  -abs(omega_dev);
    max_spd = max( abs([ spd(2)-1 spd(3)-1 spd(4)-1 omega]) );
    %%% terminate condition
    if abs( max(max(ang(2:3)),theta) - min(min(ang(2:3)),theta)  ) < 2*pi && max_spd<0.1 && d_spd(2:3) < 0.01 
        done = true;
    else
        done = false;
    end
end

