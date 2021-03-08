 time_x = 1:total_steps;
figure
plot(time_x,spd_r(1,:), time_x,spd_r(2,:), time_x,spd_r(3,:), time_x,spd_r(4,:),time_x,omega_r, 'LineWidth',1.5);
ylabel('speed')
xlabel('steps')
grid on
legend('machine1','machine2','machine3','machine4','inverter')
figure
plot(time_x,ang_r(1,:), time_x,ang_r(2,:), time_x,ang_r(3,:), time_x,ang_r(4,:),time_x,theta_r, 'LineWidth',1.5);
ylabel('rotor angle')
xlabel('steps')
grid on
legend('machine1','machine2','machine3','machine4','inverter')