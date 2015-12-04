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

% This is the code that accompanies tutorial 1. The aim of this tutorial is
% to:
%   1) Learn how the targf and luref vectors are formatted
%   2) Generate the parameter vectors for the experimental design
%   3) Use to roc_solver function to fit a model to some data
%   4) Explore the options of the roc_solver
%   5) Fit multiple models to the same data set and store the output in the
%   same variable using roc_solver

%% Clear workspace and command window
clear all;
clc;

%% Load the data in the tutorial1_data.mat file
load('tutorial1_data.mat','targf','luref');

%% Define some variables of the experiment design and model fitting routine
[nConds, nBins] = size(targf); % Number of conditions and rating bins
fitStat = '-LL'; % The two options are '-LL' and 'SSE'

%% Generate the starting parameter values (x0), the lower bound of the estimates (LB), and the upper bounds (UB)
model = 'uvsd'; % Define the model to fit to the data
uvsdParNames = {'Dprime' 'Vo'}; % This defines the two parameters of the UVSD model (not criterion). 
[x0,LB,UB] = gen_pars(model,nBins,nConds,uvsdParNames); % Creates the x0, LB, and UB matrices

%% Use roc_solver to fit the UVSD model to the data, and store output in rocData
rocData = roc_solver(targf,luref,model,fitStat,x0,LB,UB);

%% Add some additional options to the roc_solver to show its flexibility, and run roc_solver again
subID = 'tutorial1_subject'; % This is the subject ID
groupID = 'group1'; % This can be used for a between-group ID
condLabels = {'item recognition'}; % Define the condition labels
modelID = 'first uvsd model'; % This is a user defined ID for the current model
outpath = fileparts(which('tutorial1_data.mat')); % Define path to write summary figure

% Add options to the roc_solver
rocData = roc_solver(targf,luref,model,fitStat,x0,LB,UB, ...
    'subID',subID, ...
    'groupID',groupID, ...
    'condLabels',condLabels, ...
    'modelID',modelID, ...
    'saveFig',outpath);

%% Run a different variant of the EVSD model (make Vo = 1), and store with the UVSD model above
evsdParNames = {'Dprime'};

% First, generate the x0, LB, and UB vectors again, using the evsdParNames
[x0,LB,UB] = gen_pars(model,nBins,nConds,evsdParNames);

% Update modelID
modelID = 'first evsd model';

% Run the roc_solver again with the same options as above, and add the
% 'append' option.
rocData = roc_solver(targf,luref,model,fitStat,x0,LB,UB, ...
    'subID',subID, ...
    'groupID',groupID, ...
    'condLabels',condLabels, ...
    'modelID',modelID, ...
    'saveFig',outpath, ...
    'append',rocData);

% You will now notice that the model fit is not as good as the initial
% model (because the UVSD model generated the data), and that the Vo
% parameter is now equal to 1 (because the elements of LB and UB that
% correspond to the Vo parameter, or the second column of x0, both equal
% 1). Also, if you type rocData in the command window, you will now notice
% that the uvsd_model field is a 1x2 structure instead of a 1x1 structure.

%% Fit a different model, the DPSD model, to the data and store in rocData
% First, define some information relevant to fitting the dpsd model to the
% data. 
model = 'dpsd';
dpsdParNames = {'Ro' 'F'};
modelID = 'first dpsd model';

% Second, generate the x0, LB, and UB vectors for the dpsd model
[x0,LB,UB] = gen_pars(model,nBins,nConds,dpsdParNames);

% Run the roc_solver again with the same options as above.
rocData = roc_solver(targf,luref,model,fitStat,x0,LB,UB, ...
    'subID',subID, ...
    'groupID',groupID, ...
    'condLabels',condLabels, ...
    'modelID',modelID, ...
    'saveFig',outpath, ...
    'append',rocData);