close all

plot_snr_comparison();


%% Figure 5: Enhanced SNR comparison with multiple metrics
function plot_snr_comparison()
    % Range of noise ratios
    noise_ratios = logspace(-2, 2, 100); % From 0.1 to 100

    % Preallocate arrays for all metrics
    snr_improvements = zeros(size(noise_ratios));
    effect_size_improvements = zeros(size(noise_ratios));
    separability_improvements = zeros(size(noise_ratios));
    info_content_improvements = zeros(size(noise_ratios));
    
    % Assume a base effect size for absolute metrics (to calculate improvements)
    base_effect_size = 1.0; % Moderate effect size

    for i = 1:length(noise_ratios)
        ratio = noise_ratios(i);

        % Assume sigma_A = sigma_B = 1 for simplicity
        sigma_indiv = 1;
        sigma_eta = ratio * sigma_indiv;

        % CORRECTED: Calculate SNR improvement using proper formula
        % SNR_improvement = 1 + 2σ²_η/(σ²_A + σ²_B) = 1 + σ²_η/σ²_indiv when σ_A = σ_B
        snr_improvements(i) = 1 + (sigma_eta^2 / sigma_indiv^2);
        
        % Calculate effect size improvement
        effect_size_improvements(i) = sqrt(snr_improvements(i));
        
        % Calculate absolute and relative separability
        d_abs = base_effect_size;
        d_rel = d_abs * effect_size_improvements(i);
        S_abs = normcdf(d_abs/2);
        S_rel = normcdf(d_rel/2);
        separability_improvements(i) = (S_rel - 0.5) / (S_abs - 0.5); % Normalized improvement


                % Calculate absolute and relative information content
        I_abs = 1 - binary_entropy(S_abs);
        I_rel = 1 - binary_entropy(S_rel);
        % Handle case where I_abs is very small
        if I_abs < 1e-10
            if I_rel > 0
                info_content_improvements(i) = 10; % Cap at 10x improvement
            else
                info_content_improvements(i) = 1;
            end
        else
            info_content_improvements(i) = I_rel / I_abs;
        end
        
       
    end

    %% Create figure
    figure('Position', [100 100 1200 600]);

    % Plot all metrics on log-log scale
    subplot(1,2,1)
    loglog(noise_ratios, snr_improvements, '-', 'LineWidth', 3,'Color',"#0072BD", 'DisplayName', 'SNR Improvement');

    % Add grid
    grid on;

    % Label specific points
    hold on;

    % Mark the high-noise experiment point (sigma_eta/sigma_indiv = 10)
    high_noise_point = find(noise_ratios >= 10, 1);
    loglog(noise_ratios(high_noise_point), snr_improvements(high_noise_point), 'o', 'MarkerSize', 10,'Color',"#0072BD",'MarkerFaceColor',"#0072BD");
    text(0.1, snr_improvements(high_noise_point), 'High-Noise Experiment', 'FontSize', 18,'Interpreter','latex');

    % Mark the boundary experiment point (sigma_eta/sigma_indiv = 0.033)
    % Since it's outside our range, add it manually
    boundary_ratio = 0.033;
    boundary_improvement = 1 + boundary_ratio^2; % CORRECTED: Use proper formula
    loglog(boundary_ratio, boundary_improvement, 'o', 'MarkerSize', 10,'Color',"#0072BD",'MarkerFaceColor',"#0072BD");
    text(boundary_ratio*0.4, boundary_improvement*1.8, 'Boundary Experiment', 'FontSize',18,'Interpreter','latex');

    % Special cases
    text(2, 0.8, 'Relative worse', 'FontSize', 18, 'Color', "#A2142F",'Interpreter','latex');
    text(0.1, 3, 'Relative better', 'FontSize', 18, 'Color', "#77AC30",'Interpreter','latex');
    text(0.02, 5000, '(a)', 'FontSize', 20);

    % Labels and title
    xlabel('Environmental to Individual Noise Ratio ($\sigma_{\eta}/\sigma_{indiv}$)', 'FontSize', 20,'Interpreter','latex','Position',[100,0.04]);
    ylabel('SNR Improvement Factor', 'FontSize', 20,'Interpreter','latex');
    %title('Theoretical SNR Improvement from Relativization', 'FontSize', 16);
    %title('Theoretical SNR Improvement from Relativization', 'FontSize', 16);

    % Annotate theoretical relationship
    annotation('textbox', [0.14, 0.6, 0.3, 0.2], 'String', ...
        '$\textbf{SNR Improvement:} = 1 + (\sigma_{\eta}/\sigma_{indiv})^2$', ...
         'FontSize', 18, 'EdgeColor', 'none','Interpreter','latex');

    % Annotate theoretical relationship
    annotation('textbox', [0.14, 0.5, 0.3, 0.2], 'String', ...
        '$\textbf{For high noise:} \approx (\sigma_{\eta}/\sigma_{indiv})^2$', ...
         'FontSize', 18, 'EdgeColor', 'none','Interpreter','latex');

    % Improve appearance
    set(gcf, 'Color', 'white');
    %set(gca, 'FontSize', 18);



subplot(1,2,2)
% loglog(noise_ratios, effect_size_improvements, '-', 'LineWidth', 3, 'Color', "#77AC30", 'DisplayName', 'Effect Size $(d)$');    
% hold on;
% loglog(noise_ratios, separability_improvements, '--', 'LineWidth', 3, 'Color', "#D95319", 'DisplayName', 'Separability $(S)$');
% loglog(noise_ratios, info_content_improvements, '-', 'LineWidth', 3, 'Color', "#7E2F8E", 'DisplayName', 'Information Content $(I)$');
loglog(noise_ratios, effect_size_improvements, '-', 'LineWidth', 3, 'Color', "#77AC30", 'DisplayName','$d$');    
hold on;
loglog(noise_ratios, separability_improvements, '--', 'LineWidth', 3, 'Color', "#D95319", 'DisplayName','$S$');
loglog(noise_ratios, info_content_improvements, '-', 'LineWidth', 3, 'Color', "#7E2F8E", 'DisplayName', '$I$');

% Add grid
grid on;
text(0.02, 5000, '(b)', 'FontSize', 20);

% Instead of the floating high noise point, mark the high-noise experiment point on each curve
high_noise_point = find(noise_ratios >= 10, 1);
loglog(noise_ratios(high_noise_point), effect_size_improvements(high_noise_point), 'o', 'MarkerSize', 8, 'MarkerFaceColor', "#77AC30", 'Color', "#77AC30");
loglog(noise_ratios(high_noise_point), separability_improvements(high_noise_point), 'o', 'MarkerSize', 8, 'MarkerFaceColor', "#D95319", 'Color', "#D95319");
loglog(noise_ratios(high_noise_point), info_content_improvements(high_noise_point), 'o', 'MarkerSize', 8, 'MarkerFaceColor', "#7E2F8E", 'Color', "#7E2F8E");


% Mark the boundary experiment point on each curve
boundary_ratio = 0.033;
effect_size_boundary = sqrt(1 + boundary_ratio^2); % CORRECTED: Use proper formula
d_abs = base_effect_size;
d_rel = d_abs * effect_size_boundary;
S_abs = normcdf(d_abs/2);
S_rel = normcdf(d_rel/2);
S_boundary = (S_rel - 0.5) / (S_abs - 0.5);
I_abs = 1 - binary_entropy(S_abs);
I_rel = 1 - binary_entropy(S_rel);
I_boundary = I_rel / I_abs;

loglog(boundary_ratio, effect_size_boundary, 'o', 'MarkerSize', 8, 'MarkerFaceColor', "#77AC30", 'Color', "#77AC30");
loglog(boundary_ratio, S_boundary, 'o', 'MarkerSize', 8, 'MarkerFaceColor', "#D95319", 'Color', "#D95319");
loglog(boundary_ratio, I_boundary, 'o', 'MarkerSize', 8, 'MarkerFaceColor', "#7E2F8E", 'Color', "#7E2F8E");

% Add a single annotation for the boundary experiment
text(boundary_ratio*0.4, 0.3, 'Boundary Experiment', 'FontSize', 18, 'Interpreter', 'latex');
% Add a single annotation for the high-noise scenario
text(0.1, 12, 'High-Noise Experiment', 'FontSize', 18, 'Interpreter', 'latex');

% Add some insightful annotations
annotation('textbox', [0.6, 0.6, 0.3, 0.2], 'String', ...
    '$\textbf{\textit{d}} \propto \sqrt{\textbf{SNR}}$', ...
     'FontSize', 18, 'EdgeColor', 'none','Interpreter','latex','Color',"#77AC30");

annotation('textbox', [0.6, 0.55, 0.3, 0.2], 'String', ...
    '$\textbf{\textit{S}} \textrm{ saturates with large } c$', ...
     'FontSize', 18, 'EdgeColor', 'none','Interpreter','latex', 'Color', "#D95319");
     

annotation('textbox', [0.6, 0.5, 0.3, 0.2], 'String', ...
    '$\textbf{\textit{I}} \textrm{ increases faster than $\textbf{\textit{S}}$, but also saturates}$', ...
     'FontSize', 18, 'EdgeColor', 'none','Interpreter','latex', 'Color', "#7E2F8E");

    % subplot(1,2,2)
    % loglog(noise_ratios, effect_size_improvements, '-', 'LineWidth', 3, 'Color', "#77AC30", 'DisplayName', 'Effect Size Improvement');    hold on;
    % loglog(noise_ratios, separability_improvements, '--', 'LineWidth', 3, 'Color', "#D95319", 'DisplayName', 'Separability Improvement');
    % loglog(noise_ratios, info_content_improvements, '-', 'LineWidth', 3, 'Color', "#7E2F8E", 'DisplayName', 'Information Content Improvement');
    % 
    % % Add grid
    % grid on;
    % text(0.02, 5000, '(b)', 'FontSize', 18);
    % 
    % % Mark the high-noise experiment point (sigma_eta/sigma_indiv = 10)
    % high_noise_point = find(noise_ratios >= 10, 1);
    % loglog(noise_ratios(high_noise_point), snr_improvements(high_noise_point), 'o', 'MarkerSize', 10, 'MarkerFaceColor', "#0072BD", 'Color', "#0072BD");
    % 
    % % Mark the boundary experiment point (sigma_eta/sigma_indiv = 0.033)
    % boundary_ratio = 0.033;
    % boundary_improvement = (1^2 + boundary_ratio^2) / (2 * 1^2);
    % loglog(boundary_ratio, boundary_improvement, 'o', 'MarkerSize', 10, 'MarkerFaceColor', "#A2142F", "Color", "#A2142F");
    % text(boundary_ratio*0.4, 0.3, 'Boundary Experiment', 'FontSize', 18, 'Interpreter', 'latex');
    % 
    % % % Labels and title
    % xlabel('Environmental to Individual Noise Ratio ($\sigma_{\eta}/\sigma_{indiv}$)', 'FontSize', 18, 'Interpreter', 'latex');
    ylabel('Parameter Improvement Factor', 'FontSize', 20, 'Interpreter', 'latex');
    % % title('Performance Metric Improvements from Relativization', 'FontSize', 16);
    % % 
    % % Add legend
    legend('$d$','$S$','$I$','Location', 'northeast', 'FontSize', 18,'Interpreter','latex');legend box off

    % Improve appearance
    set(gcf, 'Color', 'white');
    %set(gca, 'FontSize', 18);
    % 
   % Adjust y-axis limits for better visualization
   ylim([0.1 10000]);

    % Save the figure
    saveas(gcf, 'performance_metric_improvements.png');
end

% Binary entropy function
function h = binary_entropy(p)
    % Handle edge cases to avoid log(0)
    p = max(min(p, 1-1e-10), 1e-10);
    q = 1 - p;
    h = -p.*log2(p) - q.*log2(q);
end