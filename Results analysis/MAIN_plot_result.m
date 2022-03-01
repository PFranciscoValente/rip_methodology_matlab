%------------------------------------------------------------------------
% PLOT MORTALITY AND RELIABILITY DATA - main
% author: Francisco Valente (paulo.francisco.valente@gmail.com), 2020
%------------------------------------------------------------------------

display('Select mortality data...')
[filename, pathname] = uigetfile();
full_filename = fullfile(pathname, filename);
mortality = importdata(full_filename);

plot_results('mortality',mortality)

display('Select reliability data...')
[filename, pathname] = uigetfile();
full_filename = fullfile(pathname, filename);
reliability = importdata(full_filename);

plot_results('reliability',reliability)