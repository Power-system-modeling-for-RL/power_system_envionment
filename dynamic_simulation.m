total_steps=800;
stepsize=0.00001;
z=zeros(4,total_steps);
%############ generator########%
Tdoprime = mac_con(:,9);
Tdopprime = mac_con(:,10);
Tqoprime = mac_con(:,14);

ang=mac_ang;
sync_spd = 1;
spd=mac_spd;
xdpprime=mac_con(1,8);
xqpprime = mac_con(1,13);
Tqopprime=mac_con(:,15);
d_0 = mac_con(:,17);
d_1 = mac_con(:,18);
H = mac_con(:,16);
%########## pss######%
withpass=1;
Gpss=pss_con(:,3);
Tw=pss_con(:,4);
Td1 = pss_con(:,6);
Td2 = pss_con(:,8);
%########## exc######%
V_ref=exc_pot(:,3);
V_TR = V_TR(:,1);
T_R=exc_con(:,3);
KA = exc_con(:,4);
T_A = exc_con(:,5);
for i=1:total_steps
    %########### generator###############%
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
    d_ang(:,i) = basrad*(spd-sync_spd);
    ang = ang + stepsize*d_ang(:,i);
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
    d_spd(:,i) = (pmech(:,1)-Te-d_0.*(spd-sync_spd)-d_1.*(spd-sync_spd))./(2.*H);
    spd= spd + stepsize*d_spd(:,i);
    E_ter = sqrt(ed.^2+eq.^2);
    %############# inverter################%
    E_voltage = omega*Mf*i_f/sqrt(2);
    voltage = E_voltage*cos(theta)+jay*E_voltage*sin(theta);
    current = Y_gpf2(1)*voltage + Y_gpf2(2)*int_volt(2) + Y_gpf2(3)*int_volt(3) + Y_gpf2(4)*int_volt(4);
   [omega,theta,i_f] = inverter(current,voltage,mac_pot(1,1),omega,basrad,omega_g,omega_n,stepsize,i_f,theta,Qset,Tm,Dp,Dq,K,Vn,E_voltage,J);
   omega_r(i) =  omega;
   theta_r(i) = theta;
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
    spd_r(:,i)=spd;
    ang_r(:,i)=ang;
end