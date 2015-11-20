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

% This is the code that accompanies tutorial 2. The objectives of this
% tutorial are:
%   1) Analyze data from multiple-condition designs
%   2) Fit numerous DPSD iterations of the DPSD model to the same data with
%   roc_solver
%   3) Use the excludeCond and constrfun options in roc_solver
%
% The data was simulated from the DPSD model. There are 2 conditions 
% parameters:
%   Condition 1 - Ro = .3, Rn = .3, F = .85, vF = 1 (vF is variance of F)
%   Condition 2 - Ro = .3, Rn = .1, F = .75, vF = 1 (vF is variance of F)
% Note that the luref1 variable has lures generated separately for each
% condition . However, the luref2 variables has lures generated from a 
% single condition (thus both rows are identical).

%% Clear workspace and command window
clear all;
clc;

%% Load the data in the tutorial1_data.mat file
load('tutorial2_data.mat'); % Contains nBins, nConds, pars, parNames, model

%% Define the fit statistic, model, and design info
fitStat = '-LL'; % The two options are '-LL' and 'SSE'
model = 'dpsd'; % Fit the DPSD model to the data
[nConds,nBins] = size(targf1); % Define the number of conditions (rows) and number of rating bins (columns)
parNames = {'Ro' 'Rn' 'F'}; % Define the parameters of the DPSD model to fit

%% Run Model Fitting for the targf1 and luref1 variables
% Initialize rocData1 so that we can use the append option
rocData1 = [];

%% Fit the Full Model to the Data
% Generate the x0, LB, and UB matrices. Note that parNames inclues Ro, Rn,
% and F, which are the three parameters we wish to estimate (we will not
% estimate vF, which is set to equal 1). 
[x0, LB, UB] = gen_pars(model,nBins,nConds,parNames);

% Write some notes on this model, which can be passed to the roc_solver
modelNotes = 'Full Model'; 

% Fit the DPSD model to the data with roc_solver
rocData1 = roc_solver(targf1,luref1,model,fitStat,x0,LB,UB, ...
    'notes',modelNotes, ...
    'append',rocData1);

%% Fit a model where Rn is forced to equal 0 
% You can modify the previous x0, LB, and UB variables to set Rn = 0
x0(:,2) = 0;
LB(:,2) = 0;
UB(:,2) = 0;

% Alternatively, you can use gen_pars without Rn as a parameter
[x0, LB, UB] = gen_pars(model,nBins,nConds,{'Ro' 'F'});

% Write some notes on this model, which can be passed to the roc_solver
modelNotes = 'Ro and F Only Model; Rn = 0'; 

% Fit the DPSD model to the data with roc_solver
rocData1 = roc_solver(targf1,luref1,model,fitStat,x0,LB,UB, ...
    'notes',modelNotes, ...
    'append',rocData1);

%% Fit a model where Rn is forced to equal .5 
% You can modify the previous x0, LB, and UB variables to set Rn = .5
x0(:,2) = .5;
LB(:,2) = .5;
UB(:,2) = .5;

% Write some notes on this model, which can be passed to the roc_solver
modelNotes = 'Ro and F Only Model; Rn = .5'; 

% Fit the DPSD model to the data with roc_solver
rocData1 = roc_solver(targf1,luref1,model,fitStat,x0,LB,UB, ...
    'notes',modelNotes, ...
    'append',rocData1);

%% Fit a model where Ro = Rn within each condition using the constrfun option
% Generate the x0, LB, and UB matrices.
[x0, LB, UB] = gen_pars(model,nBins,nConds,parNames);

% Create a function handle for the constraint function
constrfun = @dpsd_sym_constr;

% Write some notes on this model, which can be passed to the roc_solver
modelNotes = 'Symmetrical Model [Ro(i) = Rn(i)]'; 

% Fit the DPSD model to the data with roc_solver
rocData1 = roc_solver(targf1,luref1,model,fitStat,x0,LB,UB, ...
    'notes',modelNotes, ...
    'constrfun',constrfun, ...
    'append',rocData1);

%% Run Model Fitting for the targf2 and luref2 variables
% Initialize rocData2 so that we can use the append option
rocData2 = [];

%% Fit a model where the criterion are equal across conditions using the ignoreConds option
% The ignoreConds is the same as the previous model. 
% Update the parNames to only estimate Ro and F
parNames = {'Ro' 'F'};

% Generate the x0, LB, and UB matrices.
[x0, LB, UB] = gen_pars(model,nBins,nConds,parNames);

% Write some notes on this model, which can be passed to the roc_solver
modelNotes = 'Constrained Criteria Model'; 

% Set the ignoreConds variable to 2, indiciating condition 2 luref fit will
% be ignored
ignoreConds = 2;

% Fit the DPSD model to the data with roc_solver
rocData2 = roc_solver(targf2,luref2,model,fitStat,x0,LB,UB, ...
    'notes',modelNotes, ...
    'ignoreConds',ignoreConds, ...
    'append',rocData2);
