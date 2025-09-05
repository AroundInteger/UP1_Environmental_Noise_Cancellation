# MATLAB Compatibility Notes

## 🚨 **Critical MATLAB Limitations**

### **Ternary Operator (`? :`) Not Supported**
**Issue**: MATLAB does not support the ternary operator syntax `condition ? value_if_true : value_if_false`

**Common Error**:
```matlab
% ❌ This will cause "Invalid use of operator" error
result = condition ? true_value : false_value;
```

**Correct MATLAB Syntax**:
```matlab
% ✅ Use if-else statements instead
if condition
    result = true_value;
else
    result = false_value;
end
```

**Files Affected**:
- `scripts/SEF_Sensitivity_Analysis.m` - Fixed
- `scripts/SEF_Sensitivity_Analysis_Simple.m` - Fixed  
- `scripts/Visualize_SEF_Sensitivity.m` - Fixed

### **Path Resolution Issues**
**Issue**: MATLAB scripts run from their directory, not the project root

**Solution**: Always use absolute paths or change directory first
```matlab
% ✅ Correct approach
project_root = fileparts(mfilename('fullpath'));
project_root = fileparts(project_root); % Go up one level from scripts/
cd(project_root);
```

---

## 📊 **Data Structure Notes**

### **Rugby Dataset Structure**
The `rugby_analysis_ready.mat` file contains:
- `analysis_data` - Main data structure
- `clean_data` - Cleaned version
- `metric_categories` - Feature categories
- `summary` - Data summary

### **Season Data Location**
Seasons are stored in `analysis_data.season` as cell arrays that need conversion:
```matlab
% Convert cell array to numeric
if iscell(data.season)
    seasons = cell2mat(data.season);
else
    seasons = data.season;
end
```

### **Team Data Location**
Teams are stored in `analysis_data.team` as cell arrays:
```matlab
% Convert to numeric team IDs
if iscell(data.team)
    [unique_teams, ~, team_ids] = unique(data.team);
else
    team_ids = data.team;
end
```

---

## 🔧 **Best Practices for MATLAB Scripts**

### **1. Always Use Absolute Paths**
```matlab
% ❌ Relative paths can fail
load('data/processed/data.mat');

% ✅ Use absolute paths
project_root = fileparts(mfilename('fullpath'));
project_root = fileparts(project_root);
data_file = fullfile(project_root, 'data', 'processed', 'data.mat');
load(data_file);
```

### **2. Handle Cell Arrays Properly**
```matlab
% ❌ Direct use of cell arrays
seasons = data.season;

% ✅ Check and convert cell arrays
if iscell(data.season)
    seasons = cell2mat(data.season);
else
    seasons = data.season;
end
```

### **3. Use if-else Instead of Ternary**
```matlab
% ❌ Ternary operator (not supported)
result = condition ? true_val : false_val;

% ✅ if-else statements
if condition
    result = true_val;
else
    result = false_val;
end
```

### **4. Validate Data Before Processing**
```matlab
% ✅ Always check data validity
if length(data) > 0 && ~isempty(data)
    % Process data
else
    error('Invalid or empty data');
end
```

---

## 📋 **Troubleshooting Checklist**

### **Before Running Scripts:**
- [ ] Check MATLAB version compatibility (R2019b+)
- [ ] Verify all required toolboxes are installed
- [ ] Ensure data files exist and are accessible
- [ ] Check for ternary operators (`? :`) in code
- [ ] Verify path resolution works correctly

### **Common Error Solutions:**
1. **"Invalid use of operator"** → Replace ternary operators with if-else
2. **"Unable to find file"** → Use absolute paths or change directory
3. **"Input arguments must be numeric"** → Convert cell arrays to numeric
4. **"Array bounds exceeded"** → Check array sizes before indexing

---

**Documentation Version**: 1.0  
**Last Updated**: January 2025  
**Status**: Active Reference  
**Next Step**: Apply these fixes to all MATLAB scripts
