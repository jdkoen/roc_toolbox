
% Enter the response frequency data. 
% Column 1 is Sure Old and Column 20 is Sure New.
% Row 1 is Low Frequency Words and Row 2 is High Frequency words.
targf = [77	18	13	8	4	3	5	4	8	7	4	5	3	7	1	5	5   7	11	5;
         57	25	13	9	9	3	7	8	13	11	8	11	5	2	4	3	5   6	0	1];
luref = [3	2	8	4	4	3	1	4	11	8	15	15	6	7	6	11	14  28	33	17;
         5	9	6	8	4	5	7	4	11	12	20	13	10	7	8	5	15  17	28	6];
     
% Define the model to fit to the data
model = 'dpsd'; % Fit the DPSD model to the data
parNames = {'Ro' 'F'}; % Fit the Ro and F (d') parameters of the DPSD model. Rn and vF are set to 0 and 1, respectively.
[nConds,nBins] = size(targf); % Get the number of conditions (rows) and rating bins (columns)

% Get the starting values (x0) and lower/upper bounds (LB and UB) of the
% define model
[x0,LB,UB] = gen_pars(model,nBins,nConds,parNames);

% Define options for the ROC_SOLVER function
fitStat = '-LL'; % Fit the model using MLE (by minimizing the negative log-likelihood)
subID = 'S1'; % Define the subject ID
condLabels = {'low frequency' 'high frequency'}; % Define the condition labels for the rows in targf and luref
modelID = 'dpsd'; % Specifies a name or label for the model
outpath = pwd; % Specify the directory to write the summary figure to
bootIter = 1000; % Specify the number of non-parameter bootstrap iterations to estimate SE of the parameter estimates

% Use ROC_SOLVER to fit the model to the data
rocData = roc_solver(targf,luref,model,fitStat,x0,LB,UB, ...
    'subID',subID,'condLabels',condLabels,'modelID',modelID,'saveFig',outpath, ...
    'bootIter',bootIter);



     
     

