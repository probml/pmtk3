function simpsonsParadoxGraph
    figure(1); clf; hold on;
    
    plot([0,10], [0,10], '-b', 'LineWidth', 3);
    plot([4,5,6],[5.7,4.7,3.7], 'ro', 'LineWidth', 3, 'MarkerSize', 10);
    plot([3,4,5],[4.4,3.4,2.4], 'kx', 'LineWidth', 3, 'MarkerSize', 15);
    axis equal;
    xlim([0,10]);
    ylim([0,10]);
    set(gca, 'XTick', [], 'YTick', []);
    xlabel('x', 'FontSize', 24, 'FontWeight', 'bold');
    ylabel('y', 'FontSize', 24, 'FontWeight', 'bold');
    hold off;
end