function gdata = get_group_data(dataFiles,model,index,varName,varargin)
% usage: 
%   gdata = get_group_data(dataFiles,model,index,varName,varargin)
%
% GET_GROUP_DATA extracts the parameter estimates and fit statistics for
% the specified model from data stored in .mat files.
%
% Required Input:
%   dataFiles - The dataFiles input is a cell array of strings containing
%   file names (including file paths if not in pwd). There must be at least
%   two file names for this option to work. It is important to ensure that
%   the data files you enter contain the same model(s) fit to multiple
%   subjects with the same number of conditions and confidence bins.
%
%   model - A string identfier for the model to be fit to the data. The
%   choise are:
%      'dpsd' - Dual Process Signal-Detction Model 
%      'msd' - Mixture Signal-Detection Model
%      'uvsd' - Unequal Variance Signal-Detection Model     
%
%   index - A scalar value that identifies the iteration of a specific
%   model. If only one iteration of the specified model has been conducted
%   on the data, then just enter 1. 
%
%   varName - This specifies the name of the variable in the .mat files
%   that contains the data structure from the ROC_SOLVER function. This is
%   required as it is passed to the LOAD function. The input must be a
%   string.
%
% Optional Input:
%   ('saveTXT', prefix) - If given, this option writes the output to four
%   tab-delimeted text files. 
%
%   ('saveCSV', prefix) - If given, this option writes the output to four
%   csv files. 
%
%   The .txt/csv files, if requested, are named in the following format:
%       {prefix}_pars      - parameter estimates 
%       {prefix}_fit_stats - goodness of fit measures 
%       {prefix}_freq_data - response frequencies for each condition X
%                            rating bin
%       {prefix}_acc_bias  - signal detection measures of accuracy and
%                            reponse bias
%
%   The prefix input can contain a file path, but no file extension. The
%   outputs are in the format of {prefix}_pars.txt, {prefix}_fit_stats.txt,
%   and  for the parameter estmates and fit statistics, respectively.
%     
%   ('saveCSV', prefix) - If given, this option writes the output to a
%   two csv files. The outputs are in the format of {prefix}_pars.csv and 
%   {prefix}_fit_stats.csv for the parameter estmates and fit statistics, 
%   respectively.
%
% Output:
%   GET_GROUP_DATA returns a  structered variable containing:
%       1) Subject IDs, Group IDs, and condition labels in sepertate cell
%       arrays
%       2) Parameter estimates in a matrix (conditions in columns, subjects
%       in rows)
%       3) Fit statistics in column vectors.
%
% Authored by: Joshua D. Koen

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

% Define varargin variables
for k = 1:2:nargin-4
    switch varargin{k}
        case 'saveTXT'
            saveTXT = varargin{k+1};
            % Error check if file save path exists
            if ~isdir(fileparts(saveTXT))
                error('%s is not an existing directory.',saveTXT)
            end
        case 'saveCSV'
            saveCSV = varargin{k+1};
            % Error check if file save path exists
            if ~isdir(fileparts(saveCSV))
                error('%s is not an existing directory.',saveCSV)
            end
        otherwise
            error('%s is an unrecognized input argument.',varargin{k})
    end
end

% Return error if nargin < 3
if nargin < 3
    error('Not enough input arguments.')
end

% Check if dataFiles is a cellstr or structure variable.
if ~iscellstr(dataFiles)
    error('The dataFiles variable is not a cell string of file names.')
end

% Check if length of dataFiles is greater than or equal to 2. 
if length(dataFiles) < 2
    error('This function requires at least two file names in dataFiles to run.')
end



% Preallocate some variables
nsubs = length(dataFiles);
conds_check = zeros(nsubs,1);

% Specify model field
model_field = model_info(model,'field');

% Error check input data and determine the number of conditions  
for a = 1:nsubs
    % Load data into tdata(a) if the input is from .mat files.
    data_hold = load(dataFiles{a},varName);
    tdataname = char(fieldnames(data_hold));
    tdata(a) = data_hold.(tdataname); 

    % Error check if the field is present in the first data file.
    if ~isfield(tdata(a),model_field)
        fprintf('The following file does not contain a field the %s model:\n',upper(model))
        fprintf('%s\n',char(dataFiles{a}))        
        error('Function halted...')
    end

    % Error check if the index is out of bounds.
    if index > length(tdata(a).(model_field))
        fprintf('Index %d is out of bounds for the %s model in the following file:\n',index,upper(model))
        fprintf('%s\n',char(dataFiles{a}))        
        error('Function halted...')
        error('Index is out of bounds for subject %s in data(%d).',subID,a)
    end
    
    conds_check(a) = length(tdata(a).condition_labels);
end

% Read the number of conditions from the first element on conds_check.
nconds = conds_check(1);

% Error check for the same number of conditions in each structure array.
if sum(conds_check ~= nconds) > 0
    fprintf('\nThe first file in the list contains %d unique conditions.\n',nconds)
    fprintf('The following files have a different number of conditions:\n')
    err_files = conds_check ~= nconds;
    for b = 1:nsubs
        if err_files == 1
            if strcmpi(data_type,'struct_var')
                fprintf('%s contains a %d conditions.\n',char(data{b}),conds_check(b))
            else
                subID=num2str(tdata(a).subID);
                fprintf('Subject %s in data(%d) contains %d condition.\n',...
                    subID,conds_check(b),b)
            end
        end
    end
    error('Function halted...')
end
    
% Read the number of criterion points from the first data file
ncrit = size(tdata(1).(model_field)(index).parameters.criterion,2);

% Preallocate subject ID field
gdata.subID = cell(nsubs,1);
gdata.groupID = cell(nsubs,1);

% Read condition labels from the 1st subject in the data set.
gdata.conditions = tdata(1).condition_labels';

% Retrieve accuracy/bias, confidence, parameter and fit_stat names
acc_names = fieldnames(tdata(1).observed_data.accuracy_measures);
bias_names = fieldnames(tdata(1).observed_data.bias_measures);
acc_bias_names = [acc_names; bias_names];
par_names = fieldnames(tdata(1).(model_field)(index).parameters);
fit_names = fieldnames(tdata(1).(model_field)(index).fit_statistics);

% Preallocate confidence frequency variables
for c = 1:nconds
    gdata.rating_frequency.target{1,c} = zeros(nsubs,ncrit+1);
    gdata.rating_frequency.lure{1,c} = zeros(nsubs,ncrit+1);
end

% Preallocate accuracy/bias variables
for a = 1:length(acc_names)
    data_field = acc_names{a};
    gdata.acc_bias_measures.(data_field) = zeros(nsubs,nconds);
end
for b = 1:length(bias_names)
    data_field = bias_names{b};
    gdata.acc_bias_measures.(data_field) = zeros(nsubs,nconds);
end

% Preallocate parameter variables
for p = 1:length(par_names)
    if ~strcmpi(par_names{p}, 'criterion')
        data_field = par_names{p};
        gdata.par_estimates.(data_field) = zeros(nsubs,nconds);
    else
        for c=1:ncrit
            gdata.par_estimates.criterion{1,c} = zeros(nsubs,nconds);
        end
    end
end

% Preallocate fit statistic variables
for f = 1:length(fit_names)
    data_field = fit_names{f};
    gdata.fit_stats.(data_field) = zeros(nsubs,1);
end

% Preallocate other variables for verification purposes
gdata.model_verify.modelID = cell(nsubs,1);
gdata.model_verify.model_notes = cell(nsubs,1);
gdata.model_verify.lower_bounds = cell(nsubs,1);
gdata.model_verify.upper_bounds = cell(nsubs,1);
gdata.model_verify.constraint_function = cell(nsubs,1);

% Extract the data and format into a usable format for group analysis.
for d=1:nsubs
    % Extract subject IDs
    gdata.subID{d} = tdata(d).subID;
    gdata.groupID{d} = tdata(d).groupID;
    
    % Extract confidence frequency data
    for c = 1:nconds
        gdata.rating_frequency.target{1,c}(d,:) = ...
            tdata(d).observed_data.target.frequency(c,:);
        gdata.rating_frequency.lure{1,c}(d,:) = ...
            tdata(d).observed_data.lure.frequency(c,:);
    end
    
    % Extract accuracy/bias data
    for a = 1:length(acc_names)
        data_field = acc_names{a};
        gdata.acc_bias_measures.(data_field)(d,:) = ...
            tdata(d).observed_data.accuracy_measures.(data_field)';
    end
    for b = 1:length(bias_names)
        data_field = bias_names{b};
        gdata.acc_bias_measures.(data_field)(d,:) = ...
            tdata(d).observed_data.bias_measures.(data_field)';
    end
        
    % Extract parameter values
    for p = 1:length(par_names)
         if ~strcmpi(par_names{p}, 'criterion')
            data_field = par_names{p};
            gdata.par_estimates.(data_field)(d,:) = ...
                tdata(d).(model_field)(index).parameters.(data_field)';
         else
             for c = 1:ncrit
                 gdata.par_estimates.criterion{1,c}(d,:) = ...
                     tdata(d).(model_field)(index).parameters.criterion(:,c)';
             end
         end
    end   
    
    % Extract fit statistics
    % Preallocate fit statistic variables
    for f = 1:length(fit_names)
        data_field = fit_names{f};
        gdata.fit_stats.(data_field)(d,:) = ...
            tdata(d).(model_field)(index).fit_statistics.(data_field)';
    end

    % Extract verification data.
    gdata.model_verify.modelID{d} = ...
        tdata(d).(model_field)(index).modelID;
    gdata.model_verify.model_notes{d} = ...
        tdata(d).(model_field)(index).model_notes;
    gdata.model_verify.lower_bounds{d} = ...
        tdata(d).(model_field)(index).optimization_info.lower_bounds;
    gdata.model_verify.upper_bounds{d} = ...
        tdata(d).(model_field)(index).optimization_info.upper_bounds;
    gdata.model_verify.constraint_function{d} = ...
        tdata(d).(model_field)(index).optimization_info.constraint_function;
end

% Create data for TXT and CSV files if requested
if exist('saveTXT','var') || exist('saveCSV','var')
    % Create headers for confidence frequencies
    cHeaders{1} = 'subID';
    cHeaders{2} = 'groupID';
    column = 3; % This specifies the current column for iterating over the condition labels
    
    % Assibn column headers for the confidence frequencies
    for curCond = 1:nconds
        for itemType = 1:2 % 1 is targets, 2 is lures        
            for curBin = ncrit+1:-1:1
                if itemType == 1
                    cHeaders{column} = [gdata.conditions{curCond} '_' ...
                        num2str(curBin) '_target'];
                else
                    cHeaders{column} = [gdata.conditions{curCond} '_' ...
                        num2str(curBin) '_lure'];
                end
                column = column+1;
            end
        end
    end
    
    
    % Create accuracy/bias parameter headers
    abHeaders{1} = 'subID';
    abHeaders{2} = 'groupID';
    column = 3; % This specifies the current column for iterating over the condition labels
    
    % Assign column headers for the accuracy and bias data
    for curAB = 1:length(acc_bias_names)
        for curCond = 1:nconds
            abHeaders{column} = [gdata.conditions{curCond} '_' acc_bias_names{curAB}];
            column = column + 1;
        end
    end
    
    % Create parameter column headers
    parHeaders{1} = 'subID';
    parHeaders{2} = 'groupID';
    column = 3; % This specifies the current column for iterating over the condition labels
    
    % Assign column headers for parameter names (not criterion)    
    for curPar = 1:length(par_names)
        for curCond = 1:nconds
            if ~strcmpi(par_names{curPar}, 'criterion')
                parHeaders{column} = [gdata.conditions{curCond} '_' par_names{curPar}];
                column = column + 1;
            end
        end
    end

    % Assign column headers for the criterion
    for curCrit = (ncrit+1):-1:2
        for curCond = 1:nconds
            parHeaders{column} = [gdata.conditions{curCond} '_crit' num2str(curCrit)];
            column = column + 1;
        end
    end
    
    % Create cell array for each value in cVals
    % Get subID and groupID
    for curSub = 1:nsubs
        cVals{curSub,1} = gdata.subID{curSub};
        cVals{curSub,2} = gdata.groupID{curSub};
    end
    
    % Get confidence frequencies
    % Extract confidence frequency data
    temp_freq = cell(1,nconds*2);
    for i = 2:2:length(temp_freq)
        temp_freq{i-1} = gdata.rating_frequency.target{1,i/2};
        temp_freq{i} = gdata.rating_frequency.lure{1,i/2};
    end
    temp_freq = num2cell(cell2mat(temp_freq));
    cVals = [cVals temp_freq];
    cData = [cHeaders; cVals];    
                    
    % Write accuracy/bias data to CSV file
    if exist('saveCSV','var')
        saveFile = [saveCSV '_freq_data.csv'];
        fid = fopen(saveFile, 'wt');
        for i = 1:size(cData,1)
            for j = 1:size(cData,2)
                if isnumeric(cData{i,j})
                    fprintf(fid, '%f,', cData{i,j});
                elseif ischar(cData{i,j})
                    fprintf(fid, '%s,', cData{i,j});
                end
            end
            fprintf(fid, '\n');
        end
        fclose(fid);
    end
    
    % Write accuracy/bias to a tab delimited .txt file
    if exist('saveTXT','var')
        saveFile = [saveTXT '_freq_data.txt'];
        fid = fopen(saveFile, 'wt');
        for i = 1:size(cData,1)
            for j = 1:size(cData,2)
                if isnumeric(cData{i,j})
                    fprintf(fid, '%f\t', cData{i,j});
                elseif ischar(abData{i,j})
                    fprintf(fid, '%s\t', cData{i,j});
                end
            end
            fprintf(fid, '\n');
        end
        fclose(fid);
    end
    
    % Create cell array for each value in abVals
    % Get subID and groupID
    for curSub = 1:nsubs
        abVals{curSub,1} = gdata.subID{curSub};
        abVals{curSub,2} = gdata.groupID{curSub};
    end
    
    % Get accuracy and bias measures into abVals
    for curAB = 1:length(acc_bias_names)
        abVals = [abVals num2cell(gdata.acc_bias_measures.(acc_bias_names{curAB}))];
    end
    
    % Create parData cell array
    abData = [abHeaders; abVals];
    
    % Write accuracy/bias data to CSV file
    if exist('saveCSV','var')
        saveFile = [saveCSV '_acc_bias_data.csv'];
        fid = fopen(saveFile, 'wt');
        for i = 1:size(abData,1)
            for j = 1:size(abData,2)
                if isnumeric(abData{i,j})
                    fprintf(fid, '%f,', abData{i,j});
                elseif ischar(abData{i,j})
                    fprintf(fid, '%s,', abData{i,j});
                end
            end
            fprintf(fid, '\n');
        end
        fclose(fid);
    end
    
    % Write accuracy/bias to a tab delimited .txt file
    if exist('saveTXT','var')
        saveFile = [saveTXT '_acc_bias_data.txt'];
        fid = fopen(saveFile, 'wt');
        for i = 1:size(abData,1)
            for j = 1:size(abData,2)
                if isnumeric(abData{i,j})
                    fprintf(fid, '%f\t', abData{i,j});
                elseif ischar(abData{i,j})
                    fprintf(fid, '%s\t', abData{i,j});
                end
            end
            fprintf(fid, '\n');
        end
        fclose(fid);
    end
    
    % Create cell array for each value in parVals
    % Get subID and groupID
    for curSub = 1:nsubs
        parVals{curSub,1} = gdata.subID{curSub};
        parVals{curSub,2} = gdata.groupID{curSub};
    end

    % Get parameter estimates (including each criterion point)
    for curPar = 1:length(par_names)
        if ~strcmpi(par_names{curPar}, 'criterion')
            parVals = [parVals num2cell(gdata.par_estimates.(par_names{curPar}))];
        else
            for curCrit = 1:ncrit
                parVals = [parVals num2cell(gdata.par_estimates.criterion{curCrit})];
            end
        end
    end

    % Create parData cell array
    parData = [parHeaders; parVals];
    
    % Write parameter data to tab-delimited text file
    if exist('saveCSV','var')
        saveFile = [saveCSV '_pars.csv'];
        fid = fopen(saveFile, 'wt');
        for i = 1:size(parData,1)
            for j = 1:size(parData,2)
                if isnumeric(parData{i,j})
                    fprintf(fid, '%f,', parData{i,j});
                elseif ischar(parData{i,j})
                    fprintf(fid, '%s,', parData{i,j});
                end
            end
            fprintf(fid, '\n');
        end
        fclose(fid);
    end
    
    % Write a tab delimited .txt file
    if exist('saveTXT','var')
        saveFile = [saveTXT '_pars.txt'];
        fid = fopen(saveFile, 'wt');
        for i = 1:size(parData,1)
            for j = 1:size(parData,2)
                if isnumeric(parData{i,j})
                    fprintf(fid, '%f\t', parData{i,j});
                elseif ischar(parData{i,j})
                    fprintf(fid, '%s\t', parData{i,j});
                end
            end
            fprintf(fid, '\n');
        end
        fclose(fid);
    end
    
    % Create fit_stat column headers
    fitHeaders = ['subID' 'groupID' fit_names' 'modelID'];
    
    % Create cell array for each value in data
    % Get subID and groupID
    for curSub = 1:nsubs
        fitVals{curSub,1} = gdata.subID{curSub};
        fitVals{curSub,2} = gdata.groupID{curSub};
    end
    
    % Get fit statistics into fitVals
    for curFit = 1:length(fit_names)
        fitVals = [fitVals num2cell(gdata.fit_stats.(fit_names{curFit}))];
    end
    
    % Add modelID info to fitVals
    for curCol = 1:length(fitHeaders)
        for curSub = 1:nsubs
            if strcmpi(fitHeaders{curCol}, 'modelID')
                fitVals{curSub,curCol} = gdata.model_verify.modelID{curSub};
            elseif strcmpi(fitHeaders{curCol}, 'model_notes')
                fitVals{curSub,curCol} = gdata.model_verify.model_notes{curSub};
            elseif strcmpi(fitHeaders{curCol}, 'constraint_function') % Add an if ~= [] to all the above
                fitVals{curSub,curCol} = gdata.model_verify.constraint_function{curSub};
            else
                continue
            end
        end
    end
    
    % Create fitData cell array
    fitData = [fitHeaders; fitVals];
    
    % Write parameter data to tab-delimited text file
    if exist('saveCSV','var')
        saveFile = [saveCSV '_fit_stats.csv'];
        fid = fopen(saveFile, 'wt');
        for i = 1:size(fitData,1)
            for j = 1:size(fitData,2)
                if isnumeric(fitData{i,j})
                    fprintf(fid, '%f,', fitData{i,j});
                elseif ischar(fitData{i,j})
                    fprintf(fid, '%s,', fitData{i,j});
                end
            end
            fprintf(fid, '\n');
        end
        fclose(fid);
    end
    
    
    % Write a tab delimited .txt file
    if exist('saveTXT','var')
        saveFile = [saveTXT '_fit_stats.txt'];
        fid = fopen(saveFile, 'wt');
        for i = 1:size(fitData,1)
            for j = 1:size(fitData,2)
                if isnumeric(fitData{i,j})
                    fprintf(fid, '%f\t', fitData{i,j});
                elseif ischar(fitData{i,j})
                    fprintf(fid, '%s\t', fitData{i,j});
                end
            end
            fprintf(fid, '\n');
        end
        fclose(fid);
    end
end    
            
end   