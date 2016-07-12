%% Alpha Script: Estimate Posterior Distribution of Parameters Using Grid Search
% The purpose of this script is to establish a framework to estimate the
% posterior distribution of the parameter estimates given a set of priors.
% This script fits the DPSD model to an example data set and, given a set
% of priors for each parameters, computes the expected posterior
% distribution. The posterior is computed as follows:
%
% p(theta|data) = p(data|theta) * p(theta)
%
% To be fully implemented into the ROC Toolbox, a method needs to be
% develop that (1) allows users to easily define priors, (2) an input
% framework that will automatically develop the function for the posterior
% distribution (as defined above) given N priors, and (3) that can be
% easily expanded to accommodate any experimental design (as the ROC
% toolbox does currently with the MLE estimation). 
%
% For ease of demonstrating how to do this, I assume the F and criterion
% parameters from the MLE estimatation are 100% accurate (i.e., my prior
% belief in these parameters are whatever MLE says they are). This is
% circular, and is never recommended in a real analysis. This is to avoid
% having a very large N-dimensional parameter space (in this example, there
% are 14 parameters).
%
% If we can accomplish integrating the definition of priors into the code
% then it should be fairly simple to estimate the posterior distribution
% for each data set using MCMC estimation wiht the SLICESAMPLE.m function.
%
% To resolve the rounding issue when using SLICESAMPLE.m, the likelihood
% pdf can be defined as a log-likelihood PDF (with the 'logpdf' instead of
% 'pdf' flag).

%% Define Example data (Same as supplemental material)
% Column 1 is Sure Old and Column 20 is Sure New.
% Row 1 is Low Frequency Words and Row 2 is High Frequency words.
targf = [77	18	13	8	4	3	5	4	8	7	4	5	3	7	1	5	5   7	11	5;
         57	25	13	9	9	3	7	8	13	11	8	11	5	2	4	3	5   6	0	1];
luref = [3	2	8	4	4	3	1	4	11	8	15	15	6	7	6	11	14  28	33	17;
         5	9	6	8	4	5	7	4	11	12	20	13	10	7	8	5	15  17	28	6];
     
% For ease of this example, collapse data into 6 bins as done in Mickes et
% al. (2007), Psych Bull Rev.
targf = [sum(targf(:,1:4),2) sum(targf(:,5:7),2) sum(targf(:,8:10),2) ...
    sum(targf(:,11:13),2) sum(targf(:,14:16),2) sum(targf(:,17:end),2)];
luref = [sum(luref(:,1:4),2) sum(luref(:,5:7),2) sum(luref(:,8:10),2) ...
    sum(luref(:,11:13),2) sum(luref(:,14:16),2) sum(luref(:,17:end),2)];

%% Fit the DPSD model using MLE
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

% Use ROC_SOLVER to fit the model to the data
rocData = roc_solver(targf,luref,model,fitStat,x0,LB,UB, ...
    'subID',subID,'condLabels',condLabels,'modelID',modelID);

%% Define Likelihood Function and Priors 
% Define likelihood function
likelihood = @(pars) calc_likelihood(pars,model,targf,luref,10^290);

% Define Priors (all are uninformative and are uniform distributions)
priors.Ro1 = @(x) unifpdf(x);
priors.Ro2 = @(x) unifpdf(x);

% Define a function to handle constant (unchanging) parameters
bf_pars = rocData.dpsd_model.optimization_info.bf_pars;
pars = @(Ro) horzcat(Ro,bf_pars(:,2:end));

% Define the posterior distribution
posterior = @(p) likelihood(pars(p(:,1))) * ... % This is the likelihood
    priors.Ro1(p(1,1)) * priors.Ro2(p(2,1)); % Priors on the two F parameters

% Compute posterior at best parameter point
bestPost = posterior(bf_pars(:,1));
fprintf('Posterior at best fitting parameters: %s\n',num2str(bestPost));

%% Do User-Defined Grid Search of the parameter space
fprintf('Grid Estimation of Posterior...\n');
% Define ranges of parameters (make them close to best fitting parameters)
grid.Ro1 = .0:.01:.6;
grid.Ro2 = 0:.01:.6;

% Initialize postData
postData = zeros(structfun(@length,grid)');

% Create a 4 level for loop
for i = 1:length(grid.Ro1)
    for j = 1:length(grid.Ro2)
        
        p = [
            grid.Ro1(i); grid.Ro2(j)
            ];
        postData(i,j) = posterior(p);
        
    end
end

% Make mesh plot
figure;
mesh(grid.Ro2,grid.Ro1,postData*10^200); % Scale it up again to make it visible
xlim([0 .6]); xlabel('Ro: High Freq');
ylim([0 .6]); ylabel('Ro: Low Freq');
zlabel('Posterior');
view([40,30,60])

%% Estimate posterior using MCMC estimation
% Define options
fprintf('MCMC Estimation of Posterior...\n');
nSamples = 10000;
burnin = 5000;

% ReDefine the posterior distribution (to take row vectors
posterior = @(p) likelihood(pars(p')) * ... % This is the likelihood
    priors.Ro1(p(1)) * priors.Ro2(p(2)); % Priors on the two F parameters

trace = slicesample([.2 .2],nSamples,'pdf',posterior,'burnin',burnin,'width',.1);

% Make trace plot
figure;
subplot(2,1,1)
plot(trace(:,1)); ylabel('Ro: Low Freq'); ylim([0 .6]);
subplot(2,1,2);
plot(trace(:,2)); ylabel('Ro: High Freq'); ylim([0 .6]);
xlabel('Sample');

% Make 3d hist
figure;
hist3(fliplr(trace));
xlim([0 .6]); xlabel('Ro: High Freq');
ylim([0 .6]); ylabel('Ro: Low Freq');
zlabel('Posterior (Count)');
view([40,30,60])


