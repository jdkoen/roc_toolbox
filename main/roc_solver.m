function data = roc_solver(targf,luref,model,fitStat,x0,LB,UB,varargin)
% Usage: 
%   data = roc_solver(targf,luref,model,fitStat,x0,LB,UB,varargin)
%
% ROC_SOLVER returns a structure variable containing data from
% fitting the the specified model to confidence rating data. The user
% manual described the contents of the structure variable in more detail.
%
% This function uses the interior-point algorithm in FMINCON to find the 
% best fitting model parameters using Maximum Likelihood Estimation (MLE) 
% or by minimizing the Sum-of-Squared Errors (SSE).
%
% Required Input:
%   targf - M x N matrix of observed target frequencies in each rating 
%   bin. The order of confidence ratings should be in descending order 
%   from the first element to the last. That is, the highest rating that 
%   can be given to a target item should be in the first element and the 
%   highest rating that can be given to a lure should be the last element.
%   For example, a six point scale with a '6-sure target' and '1-sure lure'
%   responses should be entered in the order [6s 5s 4s 3s 2s 1s]. The
%   number of rows indicates the number of conditions. 
%   
%   luref - M x N matrix observed lure frequencies in each rating 
%   bin. The input is identical in form to targf.
%
%   model - A string identfier for the model to be fit to the data. The
%   choise are:
%      'dpsd' - Dual Process Signal-Detection Model 
%      'msd' - Mixture Signal-Detection Model
%      'uvsd' - Unequal Variance Signal-Detection Model
%
%   fitStat - A string identifier for the fit statistic to be used in the
%   estimation. There are four options, although it is recommended to only
%   use one of the first two options. 
%       '-LL' - Negative Log Likelihood
%       'SSE' - Sum-of-Square Errors
%
%   x0 - M x N matrix parameter values to be used as starting values
%   for the FMINCON routine. The {MODEL}_GEN_PARS functions can be used to
%   generate this matrix.
%
%   LB - M x N matrix values that specify the lower boundaries of
%   the parameters specified in x0. The {MODEL}_GEN_PARS functions can be 
%   used to generate this matrix.
%
%   UB - M x N matrix values that specify the upper boundaries of
%   the parameters specified in x0. The {MODEL}_GEN_PARS functions can be 
%   used to generate this matrix. 
%
% Optional Input:
%   ('append',varstruct) - The varstruct variable is a structure variable 
%   that already exists that you would like to add the output from this
%   iteration of the model solver to. This is useful for storing output
%   from fitted models in one data structure. Briefly, this will first set
%   the output (data) equal to the struct_var variable provided by the
%   user. Next, if the dpsd model has not been ran on this data before
%   (i.e., a data.dpsd_model field does not exist), the function will
%   create and add output to the data.dpsd_model field. If the field
%   already exists, the function will create a new index of data.dpsd_model
%   and add the output to this. For example, if data.dpsd_model(1) and
%   data.dpsd_model(2) already exist, the output from this iteration will
%   be written to data.dpsd_model(3). IMPORTANT: Only add the output of
%   this function to an existing variable if the observed data in the
%   existing variable is identical to the observed data being input into
%   this function. If not, and there is a different number of conditions or
%   response bins, the funtion will crash doing while checking for previous
%   runs of the same model (i.e., a model with the same bounds and
%   constraint function). 
%
%   ('subID',subID) - This is a subject identifier that will be output in 
%   the data structure. If this field is already present in the data 
%   structure that the output is to be written to, a warning will be
%   returned if the subID currently in the structure is different from the
%   one defined in the function options. 
%
%   ('groupID',groupID) - This is a group identifier that will be output in 
%   the data structure. If this field is already present in the data 
%   structure that the output is to be written to, a warning will be
%   returned if the subID currently in the structure is different from the
%   one defined in the function options. 
%
%   ('notes',notes) - This is a string or cell array input that contains
%   notes for the version of the model being input. This is helpful to
%   identify what parameters are being estimated in the model if you are
%   testing nested models.
%
%   ('condLabels',condLabels) - This is cell array of strings input that
%   assigns a user-defined label to the conditions. If not provided, the
%   conditions are labeled numerically (e.g., Condition1, Condition2). 
%
%   ('modelID',modelID) - This is an user defined identification of the
%   model being fit to the data. This is helpful to provide if fitting
%   multiple variations of the same model to the data (i.e., different
%   versions of the model with parameter constraints). If not given, the
%   default will be the model name and the index number of dpsd_model
%   (e.g., dpsd_model(1).modelID='dpsd1'). 
%
%   ('figure',[true]/false) - This is a string input specifying if the
%   summary figure function (PLOT_SUMMARY_ROC) should be printed after the
%   solver is finished. The default behavior is to print to screen. This
%   figure is useful for diagnosing how well a model fits the data
%   visually. If the figure is displayed, you must close the figure
%   manually before it continuoues. We recommend keeping this option set to 
%   true, but turn it off if you must. You can use the PLOT_SUMMARY_ROC 
%   function with the output from ROC_SOLVER to plot the figure if you turn
%   it off.
%
%   ('saveFig',outpath) - This is a string variable that specifies the
%   directory to save a PDF file of the summary info figure. The figure is
%   saved as outpath/subID_modelID_summary_fit.pdf. If the figure is
%   displayed without this option, then the figure is not saved.
%
%   ('figTimeout',time) = This is a scalar input that defines how long
%   the summary figure will remain on the screen (in seconds) before 
%   automatically continuing  If this option is not given, the default 
%   behavior is to keep the figure on the screen until the window is 
%   manually closed. 
%
%   ('ignoreConds',ignoreConds) - This is a N x 1 vector that identifies
%    conditions whose new items (luref) will be excluded from the fit 
%   staistic calculation. This is useful when you have a paradigm, for 
%   example, with two target distributions plotted against a single lure 
%   distribution. In such instances, it is inappropriate to count the lures 
%   twice when estimating the best fitting parameters for your model. 
%   Note that in such situations, the appropriate lure frequencies must be
%   repeated because the function requires size(targf) must equal
%   size(luref). If you wanted to exclude the 2nd condition from the fit
%   statistic calculation, use this option with ignoreConds = 2. Supplying
%   this option calls the CRITERIA_CONSTRAINT function.
%
%   ('constrfun',@constrfun) - This is a function handle input for a 
%   non-linear parameter constraint function that will be supplied to the
%   FMINCON function. The input must be a function handle or you will get 
%   an error. See the manual and help FMINCON for more information 
%   on this, as well as other Matlab documentation. If not provided, the 
%   'nonlcon' option is excluded from FMINCON. 
%
%   ('options',options) - This is a structure variable input that can be
%   generated from the function optimset('fmincon'). See help OPTIMSET for
%   more information. The user can change whatever options they see fit,
%   except for the the fields options.Algorithm which is always set to
%   'interior-point'. If not provided, other defaults to the standard
%   optimset('fmincon') output are as follows:
%       options = optimset('fmincon');
%       options.TolX = 1e-8;
%       options.TolFun = 1e-4;
%       options.Display = 'notify';
%       options.UseParallel = 'always';
%       options.MaxFunEvals = 100000;
%       options.MaxIter = 100000;
%
%   The only option that cannot be controlled is the algorithm, which is
%   set to 'interior-point' by this function. 
%
%   Note that an already defined structure variable can be assigned to
%   recieve the output of this function. If the data.observed is already
%   present, then the function skips (re)creating that output. If a
%   different version of the model is being fit to the data (i.e., a
%   version of the model with a new constraint), then the field containing
%   thte models output becomes a structured array. 
%
% Authored by: Joshua Koen

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The ROC Toolbox is the proprietary property of The Regents of the       
% University of California (“The Regents.”)                                
%
% Copyright © 2014 The Regents of the University of California, Davis
% campus. All Rights Reserved.   
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted by nonprofit, research institutions for
% research use only, provided that the following conditions are met:  
%
% •	Redistributions of source code must retain the above copyright 
% notice, this list of conditions and the following disclaimer.  
%
% •	Redistributions in binary form must reproduce the above copyright
% notice, this list of conditions and the following disclaimer in the
% documentation and/or other materials provided with the distribution.   
%
% •	The name of The Regents may not be used to endorse or promote 
% products derived from this software without specific prior written
% permission.   
%
% The end-user understands that the program was developed for research
% purposes and is advised not to rely exclusively on the program for any
% reason.  
%
% THE SOFTWARE PROVIDED IS ON AN "AS IS" BASIS, AND THE REGENTS HAVE NO
% OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
% MODIFICATIONS. THE REGENTS SPECIFICALLY DISCLAIM ANY EXPRESS OR IMPLIED
% WARRANTIES, INCLUDING BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
% IN NO EVENT SHALL THE REGENTS BE LIABLE TO ANY PARTY FOR DIRECT,
% INDIRECT, SPECIAL, INCIDENTAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES,
% INCLUDING BUT NOT LIMITED TO  PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES, LOSS OF USE, DATA OR PROFITS, OR BUSINESS INTERRUPTION, 
% HOWEVER CAUSED AND UNDER ANY THEORY OF LIABILITY WHETHER IN CONTRACT,
% STRICT LIABILITY OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
% ANY WAY OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF
% ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.             
%
% If you do not agree to these terms, do not download or use the software.
% This license may be modified only in a writing signed by authorized
% signatory of both parties.  
%
% For commercial license information please contact
% copyright@ucdavis.edu. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check if model exists and the size of targf/luref
model_check(model);
freq_size_check(targf,luref);

% Check for errors in the parameter calculation vectors (x0, LB, and UB)
if sum(size(x0)) ~= sum(size(LB)) > 0 || sum(size(x0)) ~= sum(size(UB)) > 0
    error('Size of x0, LB, and/or UB are inconsistent.')
end

% Check for consistency of LB and UB
if sum(LB>UB) > 1
    error('Elements of LB and UB appear to be backwards (i.e., LB(x)>UB(x))')
end

% Define defaults of varargin optional inputs
data = [];
subID = '';
groupID = '';
modelID = '';
notes = '';
for i = 1:size(targf,1)
    condLabels{i} = strcat('Condition',num2str(i));
end
figure = true;
outpath = '';
figTimeout = [];
ignoreConds = [];
constrfun = '';
options = optimset('fmincon');
options.TolX = 1e-8;
options.TolFun = 1e-4;
options.Display = 'notify';
options.UseParallel = 'always';
options.MaxFunEvals = 100000;
options.MaxIter = 100000;

% Update defaults based on varargin
for k = 1:2:nargin-7
    switch varargin{k}
        case 'append'
            data = varargin{k+1};
        case 'subID'
            subID = varargin{k+1};
        case 'groupID'
            groupID = varargin{k+1};
        case 'notes'
            notes = varargin{k+1};
        case 'condLabels'
            condLabels = varargin{k+1};
        case 'modelID'
            modelID = varargin{k+1};
        case 'outpath'
            outpath = varargin{k+1};
        case 'figure'
            figure = varargin{k+1};
        case 'saveFig'
            outpath = varargin{k+1};
        case 'figTimeout'
            figTimeout = varargin{k+1};
        case 'ignoreConds'
            ignoreConds = varargin{k+1};
        case 'constrfun'
            constrfun = varargin{k+1};
        case 'options'
            options = varargin{k+1};        
        otherwise
            error('%s is an unrecognized input argument.',varargin{k})
    end
end

% Force options.Algorithm to be 'interior-point'
if ~strcmpi(options.Algorithm,'interior-point')    
   options.Algorithm = 'interior-point';
end

% If a figure outpath is provided, make sure figure is set to true
if ~isempty(outpath)
    figure = true;
end

% Combine constraint functions if needed, and output necessary data
if ~isempty(constrfun) && ~isempty(ignoreConds)
    constrfun = @(pars) criteria_constraint(pars,model,ignoreConds,constrfun);
elseif isempty(constrfun) && ~isempty(ignoreConds)
    constrfun = @(pars) criteria_constraint(pars,model,ignoreConds,[]);
end

if ~isempty(constrfun)
    eval('[~,~,nConstr,contr_model] = constrfun(x0);'); 
else
    contr_model = model;
    nConstr = 0;
end

% Check if model specified in constraint function is the same as the model
% specified for the solver
if ~strcmpi(contr_model,model)
    error(['Model specified in contraint function is different from model ' ...
        'specified for the solver'])
end

% Summarize some information about the model design, number of trials, and
% the field name to write the optimized output.
nConds = size(targf,1);
nBins = size(targf,2);
[nObs,nPars,df] = summarize_model(nConds,nBins,nConstr,x0,LB,UB,ignoreConds);
nTrials = calc_nTrials(targf,luref,ignoreConds);
modelField = model_info(model,'field');

% Determine index of model to output 
if isfield(data,modelField)
    index = length(data.(modelField))+1;
else
    index = 1;
end

% Specify function handle to pass to fmincon
modelf = @(pars) calc_model_fit(fitStat,model,pars,targf,luref,ignoreConds);

%Print start information to screen
fprintf('Fitting the %s model to the data...',upper(model))

% Use fmincon to find the best fitting model parameters
tic;
[bf_pars,min_val,exitflag,output] = ...
    fmincon(modelf,x0,[],[],[],[],LB,UB,constrfun,options);
solve_time = toc;

% Return success, failure, or error from the fminsearchbnd function.
if exitflag == 1 || exitflag ==2
    fprintf('DONE\n')
    if exitflag ==1
        fprintf('Local minimum achieved and parameter constraints satisfied.')
    else
        fprintf('Local minimum is possible, and paramter constraints satisfied.')
        fprintf('\nFMINCON stopped because the the change in all of the parameters')
        fprintf('\nis less than options.TolX (%d).',options.TolX)
    end
elseif exitflag == 0 
    fprintf('FAILED\n')
    fprintf('Check output for more information.')
else
    fprintf('WARNING\n')
    fprintf('Exitflag was not 0, 1, or 2. The exit flag was %d.', exitflag)    
    fprintf(['Check the optimization_info.messages field of \n' ... 
        ' the output for more information.'])
end

% Create structure variable output from model fit.
fprintf('\nCreating output...')

% Assign subID, groupID, and condLabels
data.subID = subID;
data.groupID = groupID;
if iscolumn(condLabels)
    data.condition_labels = condLabels';
else
    data.condition_labels = condLabels;
end

% Create output for observed data, if not already present. 
if ~isfield(data,'observed_data')    
    % Calculate observed data, summary accuracy measures, and summary
    data.observed_data = freq2zscores(targf,luref);
    [data.observed_data.accuracy_measures,...
        data.observed_data.bias_measures] = calc_rating_acc_bias(targf,luref);
end

% Add modelID and notes
if ~isempty(modelID)
    data.(modelField)(index).modelID = modelID;
else
    data.(modelField)(index).modelID = [model num2str(index)];
end
data.(modelField)(index).model_notes = notes;

% Degress of Freedom
data.(modelField)(index).fit_statistics.df = df;

% Model Log Likelihood
data.(modelField)(index).fit_statistics.log_likelihood = ...
    -calc_model_fit('-LL',model,bf_pars,targf,luref,ignoreConds);

% Model G
data.(modelField)(index).fit_statistics.g_obs = ...
    calc_model_fit('G',model,bf_pars,targf,luref,ignoreConds);
data.(modelField)(index).fit_statistics.g_pval = ...
    1-chi2cdf(data.(modelField)(index).fit_statistics.g_obs,df);

% Model Chi^2
data.(modelField)(index).fit_statistics.chi_squared_obs = ...
    calc_model_fit('X2',model,bf_pars,targf,luref,ignoreConds);
data.(modelField)(index).fit_statistics.chi_squared_pval = ...
    1-chi2cdf(data.(modelField)(index).fit_statistics.chi_squared_obs,df);

% Model AIC, Corrected AIC, and BIC
[data.(modelField)(index).fit_statistics.aic, ...
    data.(modelField)(index).fit_statistics.cor_aic, ...
    data.(modelField)(index).fit_statistics.bic] = ...
    calc_aic_bic(data.(modelField)(index).fit_statistics.log_likelihood, ...
    nPars,nTrials);

% Calculate SSE and SST
data.(modelField)(index).fit_statistics.sse = ...
    calc_model_fit('SSE',model,bf_pars,targf,luref,ignoreConds);
data.(modelField)(index).fit_statistics.sst = ...
    calc_ss_total(targf,luref,ignoreConds);

% Model R^2
[data.(modelField)(index).fit_statistics.r_squared, ...
    data.(modelField)(index).fit_statistics.adjusted_r_squared] = ...
    calc_r_squared(data.(modelField)(index).fit_statistics.sse, ...
    data.(modelField)(index).fit_statistics.sst,nObs,nPars-nConstr);

% Best fitting model parameters
parNames = model_info(model,'parNames');
for i = 1:length(parNames)
    data.(modelField)(index).parameters.(parNames{i}) = bf_pars(:,i);
end
data.(modelField)(index).parameters.criterion = ...
    cumsum(bf_pars(:,length(parNames)+1:end),2);

% Update specific model parameter estimates
if strcmpi(model,'msd')
    data.(modelField)(index).parameters.Dprime1_targ = ...
        bf_pars(:,2) + bf_pars(:,4);
    data.(modelField)(index).parameters.Dprime1_lure = ...
        bf_pars(:,7) + bf_pars(:,9);
end

% Generate the predicted and fitted data
nTarg = sum(targf,2);
nLure = sum(luref,2);
data.(modelField)(index).predicted_data = ...
    calc_pred_data(model,bf_pars,nTarg,nLure,'points');
data.(modelField)(index).predicted_rocs = ...
    calc_pred_data(model,bf_pars,nTarg,nLure,'roc');

% Log the optimization information.
data.(modelField)(index).optimization_info.fit_stat = fitStat;
data.(modelField)(index).optimization_info.starting_pars = x0;
data.(modelField)(index).optimization_info.lower_bounds = LB;
data.(modelField)(index).optimization_info.upper_bounds = UB;
data.(modelField)(index).optimization_info.ignoreConds = ignoreConds;
data.(modelField)(index).optimization_info.nPars = nPars;
data.(modelField)(index).optimization_info.nConstr = nConstr;
data.(modelField)(index).optimization_info.nObs = nObs;
data.(modelField)(index).optimization_info.constraint_function = constrfun;
data.(modelField)(index).optimization_info.bf_pars = bf_pars;
data.(modelField)(index).optimization_info.minimum_fit_value = min_val;
data.(modelField)(index).optimization_info.solve_time = solve_time;
data.(modelField)(index).optimization_info.fmincon_options = options;
data.(modelField)(index).optimization_info.exitflag = exitflag;
data.(modelField)(index).optimization_info.messages = output;
fprintf('DONE\n')

% Plot summary figure if requested
if figure || ~isempty(outpath)
    
    % Print summary figure
    fprintf('Plotting summary figure...')
    f = plot_roc_summary(data,model,index,'outpath',outpath);
    
    % Hold script until figure is closed or timeout reached. If timeout
    % reached, the close figure.
    if ~isempty(figTimeout)
        uiwait(f.figure_handle,figTimeout)
        % Close figure if timeout reached
        if ishandle(f.figure_handle)
            close(f.figure_handle)
        end
    else
        uiwait(f.figure_handle)
    end
    fprintf('DONE\n\n')
end

end