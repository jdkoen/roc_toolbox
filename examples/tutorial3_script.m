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

% This is the code that accompanies tutorial 3. The objectives of this
% tutorial are:
%   1) Use the roc_import_data function 
%   2) Extract group data by using the get_group_data function
%
% In total, four models will be fit to the data. The models that will be
% fit to the data include the EVSD model, the UVSD model, the standard DPSD
% model (Ro and F parmaeters estimated), and the MSD model with the
% lambda_targ and Dprime1_targ parameters estimated. 

%% Clear workspace and command window
clear all;
clc;

%% Define the directory to save the data to, and a variable to store file names
% This will be the examples directory of the toolbox
saveDir = fullfile(fileparts(which('tutorial3_data.csv')),'tutorial3');
mkdir(saveDir);

%% Import the data from tutorial3_data.csv
rawData = roc_import_data('tutorial3_data.csv');
% Note that rawData is a cell array of structures with the fields
% condLabels, subID, groupID, targf, and luref. 

%% Define some information about the design based on the first subject
[nConds,nBins] = size(rawData{1}.targf); % Number of conditions and rating bins
nSubs = length(rawData); % Number of subjects
fitStat = '-LL'; % The two options are '-LL' and 'SSE'

%% Fit the models to each subjects data, and save the rodData structure
subFiles = {};
for i = 1:length(rawData)
    % Initialize rocData anew for each subject
    rocData = [];
    
    % Fit the UVSD model to the data
    model = 'uvsd';
    modelID = 'evsd_model';
    parNames = {'Dprime'};
    [x0, LB, UB] = gen_pars(model,nBins,nConds,parNames);
    rocData = roc_solver(rawData{i}.targf,rawData{i}.luref, ...
        model,fitStat,x0,LB,UB, ...
        'subID',rawData{i}.subID, ...
        'groupID',rawData{i}.groupID, ...
        'condLabels',rawData{i}.condLabels, ...
        'modelID',modelID, ...
        'saveFig',saveDir, ...
        'figTimeout',2, ...
        'append',rocData);
    
    % Fit the UVSD model to the data
    model = 'uvsd';
    modelID = 'uvsd_model';
    parNames = {'Dprime' 'Vo'};
    [x0, LB, UB] = gen_pars(model,nBins,nConds,parNames);
    rocData = roc_solver(rawData{i}.targf,rawData{i}.luref, ...
        model,fitStat,x0,LB,UB, ...
        'subID',rawData{i}.subID, ...
        'groupID',rawData{i}.groupID, ...
        'condLabels',rawData{i}.condLabels, ...
        'modelID',modelID, ...
        'saveFig',saveDir, ...
        'figTimeout',2, ...
        'append',rocData);
    
    % Fit the DPSD model to the data
    model = 'dpsd';
    modelID = 'dpsd_model';
    parNames = {'Ro' 'F'};
    [x0, LB, UB] = gen_pars(model,nBins,nConds,parNames);
    rocData = roc_solver(rawData{i}.targf,rawData{i}.luref, ...
        model,fitStat,x0,LB,UB, ...
        'subID',rawData{i}.subID, ...
        'groupID',rawData{i}.groupID, ...
        'condLabels',rawData{i}.condLabels, ...
        'modelID',modelID, ...
        'saveFig',saveDir, ...
        'figTimeout',2, ...
        'append',rocData);
    
    % Fit the MSD model to the data (version 1)
    model = 'msd';
    modelID = 'msd_model';
    parNames = {'lambda_targ' 'Dprime1_targ'};
    [x0, LB, UB] = gen_pars(model,nBins,nConds,parNames);
    rocData = roc_solver(rawData{i}.targf,rawData{i}.luref, ...
        model,fitStat,x0,LB,UB, ...
        'subID',rawData{i}.subID, ...
        'groupID',rawData{i}.groupID, ...
        'condLabels',rawData{i}.condLabels, ...
        'modelID',modelID, ...
        'saveFig',saveDir, ...
        'figTimeout',2, ...
        'append',rocData);
    
    % Save rocData to a .mat file for the current subject
    matFile = fullfile(saveDir,strcat(rawData{i}.subID,'_rocData.mat'));
    subFiles{i} = matFile;
    save(matFile,'rocData');
end

%% Extract the group data for each model and save to a .mat and .csv file
% Extract the EVSD data
evsdPrefix = fullfile(saveDir,'evsd_group_data');
evsdData = get_group_data(subFiles,'uvsd',1,'rocData','saveCSV',evsdPrefix);
% Note that the model input here is the same as the model used with the
% roc_solver function. The input following the model is the index, which
% indicates what element of the structure array to extract the data from. 

% Extract the UVSD data
uvsdPrefix = fullfile(saveDir,'uvsd_group_data');
uvsdData = get_group_data(subFiles,'uvsd',2,'rocData','saveCSV',uvsdPrefix);

% Extract the DPSD data
dpsdPrefix = fullfile(saveDir,'dpsd_group_data');
dpsdData = get_group_data(subFiles,'dpsd',1,'rocData','saveCSV',dpsdPrefix);

% Extract the MSD data
msdPrefix = fullfile(saveDir,'msd_group_data');
msdData = get_group_data(subFiles,'msd',1,'rocData','saveCSV',msdPrefix);

% Save the group data structures to a .mat file
save(fullfile(saveDir,'all_group_data.mat'),'evsdData','uvsdData', ...
    'dpsdData','msdData');
