close all

plot_snr_comparison();


%% Figure 4: SNR comparison and visualization SNR improvement as a function of environmental noise
function plot_snr_comparison();
%function plot_snr_improvement_curve_1()
    % Range of noise ratios
    noise_ratios = logspace(-2, 2, 100); % From 0.1 to 100

    % Calculate SNR improvement for each ratio
    snr_improvements = zeros(size(noise_ratios));

    for i = 1:length(noise_ratios)
        ratio = noise_ratios(i);

        % Assume sigma_A = sigma_B = 1 for simplicity
        sigma_indiv = 1;
        sigma_eta = ratio * sigma_indiv;

        % CORRECTED: Calculate SNR improvement using proper formula
        % SNR_improvement = 1 + 2σ²_η/(σ²_A + σ²_B) = 1 + σ²_η/σ²_indiv when σ_A = σ_B
        snr_improvements(i) = 1 + (sigma_eta^2 / sigma_indiv^2);
    end

    % Create figure
    figure('Position', [100 100 800 600]);

    % Log-log plot of SNR improvement vs noise ratio
    loglog(noise_ratios, snr_improvements, '-', 'LineWidth', 3,'Color',"#0072BD");

    % Add grid
    grid on;

    % Label specific points
    hold on;

    % Mark the high-noise experiment point (sigma_eta/sigma_indiv = 10)
    high_noise_point = find(noise_ratios >= 10, 1);
    loglog(noise_ratios(high_noise_point), snr_improvements(high_noise_point), 'o', 'MarkerSize', 10, 'MarkerFaceColor',"#77AC30",'Color',"#77AC30");
    text(0.5, snr_improvements(high_noise_point), 'High-Noise Experiment', 'FontSize', 18,'Interpreter','latex');

    % Mark the boundary experiment point (sigma_eta/sigma_indiv = 0.033)
    % Since it's outside our range, add it manually
    boundary_ratio = 0.033;
    boundary_improvement = 1 + boundary_ratio^2; % CORRECTED: Use proper formula
    loglog(boundary_ratio, boundary_improvement, 'o', 'MarkerSize', 10, 'MarkerFaceColor',  "#A2142F","Color","#A2142F");
    text(boundary_ratio*0.4, boundary_improvement*1.5, 'Boundary Experiment', 'FontSize',18,'Interpreter','latex');

    % Special cases
    text(2, 0.8, 'Relative worse', 'FontSize', 18, 'Color', "#A2142F",'Interpreter','latex');
    text(0.15, 4, 'Relative better', 'FontSize', 18, 'Color', "#77AC30",'Interpreter','latex');

    % Labels and title
    xlabel('Environmental to Individual Noise Ratio ($\sigma_{\eta}/\sigma_{indiv}$)', 'FontSize', 18,'Interpreter','latex');
    ylabel('SNR Improvement Factor', 'FontSize', 18,'Interpreter','latex');
    %title('Theoretical SNR Improvement from Relativization', 'FontSize', 16);
    title('Theoretical SNR Improvement from Relativization', 'FontSize', 16);

    % Annotate theoretical relationship
    annotation('textbox', [0.15, 0.65, 0.3, 0.2], 'String', ...
        '$\textbf{SNR Improvement:} = 1 + (\sigma_{\eta}/\sigma_{indiv})^2$', ...
         'FontSize', 18, 'EdgeColor', 'none','Interpreter','latex');

    % Annotate theoretical relationship
    annotation('textbox', [0.15, 0.6, 0.3, 0.2], 'String', ...
        '$\textbf{For high noise:} \approx (\sigma_{\eta}/\sigma_{indiv})^2$', ...
         'FontSize', 18, 'EdgeColor', 'none','Interpreter','latex');

    % Improve appearance
    set(gcf, 'Color', 'white');
    set(gca, 'FontSize', 18);

    % Save the figure
    saveas(gcf, 'snr_improvement_curve.png');
end

