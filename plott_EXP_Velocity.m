% close all
figure(1)
for kk=1:NoS-NoI
hold on
t=linspace(0,n*DeltaT,length(x(kk,:)));
plot(t,x(kk,:) ,Color=[.999/kk kk/10 1-kk/10],LineStyle="-",LineWidth=3)
bound=.5;
box on
upperlimit=bound*ones(1,length(x(kk,:)));
e=.3*bound;
legend 
xlabel('Time [s]','Interpreter', 'latex');
title(' States','Interpreter', 'latex')
set(gcf, 'Color', 'w');
set(gca, 'FontSize', 20);  
grid on;
set(gca, 'TickLabelInterpreter', 'latex');

end


%% Figure
figure(2)
for kk=1:NoI
bound=10;
hold on
upperlimit=bound*ones(1,length(x(1,:)));

legend
plot(linspace(0,n*DeltaT,length(u_app(kk,:))),u_app(kk,:) ,Color=[1-kk/10 .999/kk kk/10],LineStyle="-",LineWidth=3)
hold off
xlabel('Time [s]','Interpreter', 'latex');
title('Control Inputs ','Interpreter','latex')
set(gcf, 'Color', 'w');
set(gca, 'FontSize', 20);  
grid on;
box on
set(gca, 'TickLabelInterpreter', 'latex');
end
