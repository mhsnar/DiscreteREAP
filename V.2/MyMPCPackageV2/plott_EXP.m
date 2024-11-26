% close all


if plotFlags(1)

figure;

hold on;
colors = lines(NoS-NoI);  % Generate a set of distinct colors for each state
    
for kk = 1:NoS-NoI
    t = linspace(0, n * DeltaT, length(x(kk, :)));
    plot(t, x(kk, :), 'Color', colors(kk, :), 'LineWidth', 3);
end

legend_labels = arrayfun(@(kk) sprintf('x_%d', kk), 1:NoS-NoI, 'UniformOutput', false);
legend(legend_labels);


ylabel('Value','Interpreter', 'latex');

box on;
hold off;



xlabel('Time [s]','Interpreter', 'latex');
title(' States','Interpreter', 'latex')
set(gcf, 'Color', 'w');
set(gca, 'FontSize', 20);  
grid on;
set(gca, 'TickLabelInterpreter', 'latex');
end
%% Figure
if plotFlags(2)
figure;
hold on;
colors = lines(NoI);  % Generate a set of distinct colors for each state
for kk=1:NoI
 
  t = linspace(0, n * DeltaT, length(u_app(kk, :)));
    stairs(t, u_app(kk, :), 'Color', colors(kk, :), 'LineWidth', 3);
end

legend_labels = arrayfun(@(kk) sprintf('u_%d', kk), 1:NoI, 'UniformOutput', false);
legend(legend_labels);


ylabel('Value','Interpreter', 'latex');

box on;
hold off;

xlabel('Time [s]','Interpreter', 'latex');
title('Control Inputs ','Interpreter','latex')
set(gcf, 'Color', 'w');
set(gca, 'FontSize', 20);  
grid on;
box on
set(gca, 'TickLabelInterpreter', 'latex');
end
%% Figure
if plotFlags(3)
figure;

hold on;
colors = lines(NoO);  % Generate a set of distinct colors for each state
 y=Cd*x ;  
for kk = 1:NoO
    t = linspace(0, n * DeltaT, length(x(kk, :)));
    plot(t, y(kk, :), 'Color', colors(kk, :), 'LineWidth', 3);
end
% plot(t, r*ones(length(x(kk, :)),1), 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 3);

legend_labels = arrayfun(@(kk) sprintf('y_%d', kk), 1:NoO, 'UniformOutput', false);
legend(legend_labels);


ylabel('Value','Interpreter', 'latex');

box on;
hold off;



xlabel('Time [s]','Interpreter', 'latex');
title(' Output','Interpreter', 'latex')
set(gcf, 'Color', 'w');
set(gca, 'FontSize', 20);  
grid on;
set(gca, 'TickLabelInterpreter', 'latex');

end
%% Figure
if plotFlags(4)
figure
hold on;



Sigma=[];
for iii=1:100
Sigma=[Sigma;Sigmas{iii}];
end
plot(Sigma,LineWidth=2)
xlabel('Step $\tau$','Interpreter','latex');
ylabel('$\sigma(\tau | t)$','Interpreter','latex');
set(gcf, 'Color', 'w');
set(gca, 'FontSize', 20);
grid on;
box on
grid on
set(gca, 'TickLabelInterpreter', 'latex');
end
