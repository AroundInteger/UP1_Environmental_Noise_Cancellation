#!/usr/bin/env python3
"""
Optimization Landscapes for Paper 2 Design Guidelines
Creates visualizations showing D_M maximization across parameter space
"""

import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.optimize import minimize
from scipy.stats import norm
import pandas as pd
from matplotlib.patches import Rectangle
import matplotlib.patches as mpatches

# Set style
plt.style.use('seaborn-v0_8')
sns.set_palette("husl")

def create_optimization_landscapes():
    """
    Create comprehensive optimization landscape visualizations
    """
    print("Creating optimization landscape visualizations...")
    
    # Create figure with subplots
    fig = plt.figure(figsize=(20, 16))
    
    # 1. D_M Maximization Landscape
    ax1 = plt.subplot(2, 3, 1)
    create_dm_maximization_landscape(ax1)
    
    # 2. Effect Size Targeting
    ax2 = plt.subplot(2, 3, 2)
    create_effect_size_targeting(ax2)
    
    # 3. Separability Optimization
    ax3 = plt.subplot(2, 3, 3)
    create_separability_optimization(ax3)
    
    # 4. Quadrant-Specific Optimization
    ax4 = plt.subplot(2, 3, 4)
    create_quadrant_optimization(ax4)
    
    # 5. Resource Allocation Trade-offs
    ax5 = plt.subplot(2, 3, 5)
    create_resource_tradeoffs(ax5)
    
    # 6. Implementation Roadmap
    ax6 = plt.subplot(2, 3, 6)
    create_implementation_roadmap(ax6)
    
    plt.tight_layout()
    plt.savefig('../visualizations/optimization_landscapes.png', dpi=300, bbox_inches='tight')
    plt.show()
    
    print("Optimization landscapes saved to ../visualizations/optimization_landscapes.png")

def create_dm_maximization_landscape(ax):
    """D_M maximization across δ-κ space"""
    
    # Create parameter grid
    delta_range = np.linspace(0.1, 5.0, 100)
    kappa_range = np.linspace(0.1, 5.0, 100)
    Delta, Kappa = np.meshgrid(delta_range, kappa_range)
    
    # Calculate D_M
    D_M = np.abs(Delta) / np.sqrt(1 + Kappa**2)
    
    # Create contour plot
    levels = np.linspace(0, 2.5, 20)
    contour = ax.contourf(Delta, Kappa, D_M, levels=levels, cmap='viridis')
    
    # Add contour lines
    ax.contour(Delta, Kappa, D_M, levels=levels[::3], colors='white', alpha=0.5, linewidths=0.5)
    
    # Add quadrant boundaries
    ax.axhline(y=1, color='red', linestyle='--', alpha=0.7, linewidth=2, label='κ = 1')
    ax.axvline(x=0, color='red', linestyle='--', alpha=0.7, linewidth=2, label='δ = 0')
    
    # Add quadrant labels
    ax.text(2.5, 0.5, 'Q1\nOptimal', ha='center', va='center', 
            bbox=dict(boxstyle="round,pad=0.3", facecolor='lightgreen', alpha=0.7))
    ax.text(2.5, 3.0, 'Q2\nSuboptimal', ha='center', va='center',
            bbox=dict(boxstyle="round,pad=0.3", facecolor='lightyellow', alpha=0.7))
    ax.text(-2.5, 3.0, 'Q3\nInverse', ha='center', va='center',
            bbox=dict(boxstyle="round,pad=0.3", facecolor='lightblue', alpha=0.7))
    ax.text(-2.5, 0.5, 'Q4\nCatastrophic', ha='center', va='center',
            bbox=dict(boxstyle="round,pad=0.3", facecolor='lightcoral', alpha=0.7))
    
    # Add colorbar
    cbar = plt.colorbar(contour, ax=ax)
    cbar.set_label('Mahalanobis Distance (D_M)', fontsize=12)
    
    ax.set_xlabel('Performance Difference (δ)', fontsize=12)
    ax.set_ylabel('Variance Ratio (κ)', fontsize=12)
    ax.set_title('D_M Maximization Landscape', fontsize=14, fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.3)

def create_effect_size_targeting(ax):
    """Effect size targeting optimization"""
    
    # Target effect sizes
    target_effects = [0.2, 0.5, 0.8, 1.2, 2.0]
    colors = plt.cm.viridis(np.linspace(0, 1, len(target_effects)))
    
    kappa_range = np.linspace(0.1, 3.0, 100)
    
    for i, target_d in enumerate(target_effects):
        # Calculate required delta for target effect size
        # d = 2D_M = 2|δ|/√(1+κ²) → |δ| = d√(1+κ²)/2
        required_delta = target_d * np.sqrt(1 + kappa_range**2) / 2
        
        ax.plot(kappa_range, required_delta, color=colors[i], 
                linewidth=2, label=f'd = {target_d}')
    
    # Add quadrant boundaries
    ax.axhline(y=0, color='red', linestyle='--', alpha=0.7, linewidth=2)
    ax.axvline(x=1, color='red', linestyle='--', alpha=0.7, linewidth=2)
    
    ax.set_xlabel('Variance Ratio (κ)', fontsize=12)
    ax.set_ylabel('Required Performance Difference (|δ|)', fontsize=12)
    ax.set_title('Effect Size Targeting', fontsize=14, fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 3)

def create_separability_optimization(ax):
    """Separability optimization landscape"""
    
    # Create parameter grid
    delta_range = np.linspace(0.1, 3.0, 100)
    kappa_range = np.linspace(0.1, 3.0, 100)
    Delta, Kappa = np.meshgrid(delta_range, kappa_range)
    
    # Calculate separability S = Φ(D_M)
    D_M = np.abs(Delta) / np.sqrt(1 + Kappa**2)
    S = norm.cdf(D_M)
    
    # Create contour plot
    levels = np.linspace(0.5, 1.0, 20)
    contour = ax.contourf(Delta, Kappa, S, levels=levels, cmap='plasma')
    
    # Add contour lines
    ax.contour(Delta, Kappa, S, levels=[0.6, 0.7, 0.8, 0.9], 
               colors='white', alpha=0.7, linewidths=1)
    
    # Add quadrant boundaries
    ax.axhline(y=1, color='red', linestyle='--', alpha=0.7, linewidth=2)
    ax.axvline(x=0, color='red', linestyle='--', alpha=0.7, linewidth=2)
    
    # Add colorbar
    cbar = plt.colorbar(contour, ax=ax)
    cbar.set_label('Theoretical Separability (S)', fontsize=12)
    
    ax.set_xlabel('Performance Difference (δ)', fontsize=12)
    ax.set_ylabel('Variance Ratio (κ)', fontsize=12)
    ax.set_title('Separability Optimization', fontsize=14, fontweight='bold')
    ax.grid(True, alpha=0.3)

def create_quadrant_optimization(ax):
    """Quadrant-specific optimization strategies"""
    
    # Define quadrant strategies
    strategies = {
        'Q1': {'delta': [1.0, 3.0], 'kappa': [0.2, 0.8], 'color': 'green', 'label': 'Q1: Maximize D_M'},
        'Q2': {'delta': [2.0, 4.0], 'kappa': [1.1, 3.0], 'color': 'orange', 'label': 'Q2: Balance δ vs κ'},
        'Q3': {'delta': [-0.5, 0.5], 'kappa': [0.8, 1.2], 'color': 'blue', 'label': 'Q3: Minimize |δ|'},
        'Q4': {'delta': [-3.0, -1.0], 'kappa': [0.2, 0.8], 'color': 'red', 'label': 'Q4: Avoid entirely'}
    }
    
    for quadrant, strategy in strategies.items():
        # Create rectangle for strategy region
        rect = Rectangle((strategy['delta'][0], strategy['kappa'][0]), 
                        strategy['delta'][1] - strategy['delta'][0],
                        strategy['kappa'][1] - strategy['kappa'][0],
                        facecolor=strategy['color'], alpha=0.3, 
                        edgecolor=strategy['color'], linewidth=2)
        ax.add_patch(rect)
        
        # Add label
        center_x = (strategy['delta'][0] + strategy['delta'][1]) / 2
        center_y = (strategy['kappa'][0] + strategy['kappa'][1]) / 2
        ax.text(center_x, center_y, quadrant, ha='center', va='center', 
                fontweight='bold', fontsize=10)
    
    # Add quadrant boundaries
    ax.axhline(y=1, color='black', linestyle='-', alpha=0.7, linewidth=2)
    ax.axvline(x=0, color='black', linestyle='-', alpha=0.7, linewidth=2)
    
    ax.set_xlabel('Performance Difference (δ)', fontsize=12)
    ax.set_ylabel('Variance Ratio (κ)', fontsize=12)
    ax.set_title('Quadrant-Specific Strategies', fontsize=14, fontweight='bold')
    ax.set_xlim(-4, 4)
    ax.set_ylim(0, 3)
    ax.grid(True, alpha=0.3)

def create_resource_tradeoffs(ax):
    """Resource allocation trade-offs"""
    
    # Define resource allocation scenarios
    scenarios = {
        'High δ, Low κ': {'delta': 2.0, 'kappa': 0.5, 'cost': 100, 'benefit': 0.9},
        'High δ, High κ': {'delta': 2.0, 'kappa': 2.0, 'cost': 80, 'benefit': 0.6},
        'Low δ, Low κ': {'delta': 0.5, 'kappa': 0.5, 'cost': 60, 'benefit': 0.7},
        'Low δ, High κ': {'delta': 0.5, 'kappa': 2.0, 'cost': 40, 'benefit': 0.3}
    }
    
    colors = ['green', 'orange', 'blue', 'red']
    
    for i, (scenario, params) in enumerate(scenarios.items()):
        ax.scatter(params['cost'], params['benefit'], 
                  s=200, c=colors[i], alpha=0.7, label=scenario)
        
        # Add D_M value
        D_M = abs(params['delta']) / np.sqrt(1 + params['kappa']**2)
        ax.annotate(f'D_M={D_M:.2f}', 
                   (params['cost'], params['benefit']),
                   xytext=(5, 5), textcoords='offset points', fontsize=8)
    
    ax.set_xlabel('Resource Cost', fontsize=12)
    ax.set_ylabel('Competitive Benefit', fontsize=12)
    ax.set_title('Resource Allocation Trade-offs', fontsize=14, fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.3)

def create_implementation_roadmap(ax):
    """Implementation roadmap visualization"""
    
    # Define phases
    phases = [
        {'name': 'Phase 1', 'tasks': ['D_M Calculation', 'Monitoring Setup'], 'duration': 2},
        {'name': 'Phase 2', 'tasks': ['Quadrant Classification', 'Boundary Detection'], 'duration': 3},
        {'name': 'Phase 3', 'tasks': ['Optimization Algorithms', 'Adaptive Strategies'], 'duration': 4},
        {'name': 'Phase 4', 'tasks': ['Validation Protocols', 'Control Systems'], 'duration': 3},
        {'name': 'Phase 5', 'tasks': ['Multivariate Extensions', 'Scaling'], 'duration': 5}
    ]
    
    colors = plt.cm.viridis(np.linspace(0, 1, len(phases)))
    
    y_pos = np.arange(len(phases))
    durations = [phase['duration'] for phase in phases]
    
    bars = ax.barh(y_pos, durations, color=colors, alpha=0.7)
    
    # Add labels
    for i, (bar, phase) in enumerate(zip(bars, phases)):
        ax.text(bar.get_width() + 0.1, bar.get_y() + bar.get_height()/2, 
                f"{phase['name']}\n{', '.join(phase['tasks'])}", 
                va='center', fontsize=9)
    
    ax.set_yticks(y_pos)
    ax.set_yticklabels([phase['name'] for phase in phases])
    ax.set_xlabel('Duration (weeks)', fontsize=12)
    ax.set_title('Implementation Roadmap', fontsize=14, fontweight='bold')
    ax.grid(True, alpha=0.3, axis='x')

if __name__ == "__main__":
    create_optimization_landscapes() 