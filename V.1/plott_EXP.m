% close all
figure(1)

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
%% Figure
figure(2)
hold on;
colors = lines(NoI);  % Generate a set of distinct colors for each state
for kk=1:NoI
 
  t = linspace(0, n * DeltaT, length(u_app(kk, :)));
    plot(t, u_app(kk, :), 'Color', colors(kk, :), 'LineWidth', 3);
end

legend_labels = arrayfun(@(kk) sprintf('u_%d', kk), 1:NoS-NoI, 'UniformOutput', false);
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




xlabel('Time [s]','Interpreter', 'latex');
title('Control Inputs ','Interpreter','latex')
set(gcf, 'Color', 'w');
set(gca, 'FontSize', 20);  
grid on;
box on
set(gca, 'TickLabelInterpreter', 'latex');

