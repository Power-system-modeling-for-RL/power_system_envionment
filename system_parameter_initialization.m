%% parameter initialization
total_steps=80000;
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
global  Gpss Tw Td1 Td2
withpass=1; 
Gpss=pss_con(:,3);
Tw=pss_con(:,4);
Td1 = pss_con(:,6);
Td2 = pss_con(:,8);
%########## exc######%
global V_ref  T_R T_A
V_ref=exc_pot(:,3);
V_TR = V_TR(:,1);
T_R=exc_con(:,3);
KA = exc_con(:,4);
T_A = exc_con(:,5);