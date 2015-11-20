function data = roc_import_data(filename)
% Usage:
%   data = roc_import_data(filename)
%
% ROC_IMPORT_DATA imports data from comma-separated (.CSV) or tab-delimited
% (.TXT) files into a format to be used with the ROC TOOLBOX. The data
% should be in long format, such that each row represents one confidence
% frequency for the combination of variables, which are described below. 
%
% Additional descriptions of this can be found in the manual, and an
% exampled data file can be found in the EXAMPLES folder of the
% distribution. Please note that data from multiple subjects can be
% imported in one step (i.e., multiple subjects can be included in one
% file).  
%
% Required Input:
%   filename - The name of the .CSV or .TXT file that you wish to import
%   data from. 
%
% Columns of .CSV/.TXT File:
%   (1) subject ID - The first column lists the subject identifier. This must be
%   present for each row that contains a given subjects data.
%
%   (2) group - The second column lists the group the subject was in.
%   This might not be relevant to your particular experiment, especially if
%   you have a completely within subject design. If you have a between
%   subject variable, you can include that information here (e.g., Young
%   versus Old adults). If you do not have a between subjects variable, you
%   can jsut have the field be empty or have a redundant value across each
%   subject. Note that you can only include one value here. If you have
%   multiple between-subject factors, like A1/A2 and B1/B2, then just
%   include the factorial combinations (e.g., A1-B1, A1-B2, A2-B1, A2-B2). 
%
%   (3) condition - The third column labels the within subject condLabels,
%   such as Full vs. Divided attention. 
%
%   (4) trial yype - The fourth column lables the trial type, and can only
%   have two different values: Targets and Lures. 
%
%   (5) rating bin - The fifth columns labels the rating bin. The data here
%   should be numeric with the largest values representing the highest
%   confidence that an item is a Target (e.g., '6-Sure Target') and the
%   lowest value repsenting the highest confidence than an item is a Lure
%   (e.g., '1-Sure Lure). 
%
%   (6) frequency - The sixth column contains the numeric entries for the
%   number of responses in a given rating bin for the combination of
%   subject ID, condition, and trial type (group is not included in this
%   because the primary group variable is the subject ID). 
%
% Format of Output:
%   The imported data is stored in a cell array of structure variables.
%   Each subject's data is stored in a different cell of the cell array
%   (e.g., data{i} contains the structure for subject ith in the list). The
%   fields of the structure variable are:
%       data{i}.condLabels = Condition labels
%       data{i}.subID = subject identifier
%       data{i}.groupID = group identifier
%       data{i}.targf = matrix of frequencies for target trials
%       data{i}.luref = matrix of frequencies for lure trials
%
% The data{i}.targf and data{i}.luref can be used as inputs to the
% ROC_SOLVER function. The other fields are not required in the ROC_SOLVER,
% but can be used as option inputs. 
% 
% Authored by: Frederick Barrett & Joshua D. Koen

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

% initialize output variable
data = {};

[~, ~, filetype] = fileparts(filename); 

% import data from csv file
if isequal(filetype,'.csv')
    raw_data = loadtxt(filename,'delim',',','verbose','off','convert','off');
elseif isequal(filetype,'.txt')
    raw_data = loadtxt(filename,'verbose','off','convert','off');
else
    error(['File must be a comma-separated (.csv) or ' ...
        'tab-delimited (.txt) file.'])
end

% Specify column labels
cols = struct('subID',1,'groupID',2,'condition',3,'trialType',4,...
    'ratingBin',5,'response',6); % Numbers ID columns in raw_data.

% Convert strings of rating bin and frequencies to numbers
for i = 1:size(raw_data,1)
    raw_data{i, cols.ratingBin} = str2double(raw_data{i, cols.ratingBin});
    raw_data{i, cols.response} = str2double(raw_data{i, cols.response});
end

% Sort raw_data
raw_data = sortcell(raw_data,[cols.subID cols.condition ...
    cols.trialType cols.ratingBin]);

% get unique subjects IDs
subids = raw_data(:,cols.subID);
usubs = unique(subids);
nsubs = length(usubs);

% iterate over subjects
for isub=1:nsubs
  % Select indexes of cell array with the current subject ID
  smask = ismember(subids,usubs(isub));
  
  if ~any(smask), continue, end
  
  % get unique condLabels in a subject, and count them
  ucond = unique(raw_data(smask,cols.condition));
  ncond = length(ucond);
  
  % grab subID, groupID, and condLabels
  data{isub}.condLabels = ucond;
  data{isub}.subID = usubs{isub};
  data{isub}.groupID = cell2mat(unique(raw_data(smask,cols.groupID)));

    % iterate over condLabels
    for icond=1:ncond
      cmask = smask & ismember(raw_data(:,cols.condition),ucond{icond});
      
      if ~any(cmask), continue, end
      
      targmask = cmask & ismember(lower(raw_data(:,cols.trialType)),'target');
      luremask = cmask & ismember(lower(raw_data(:,cols.trialType)),'lure');
      
      data{isub}.targf(icond,:) = flipud(raw_data(targmask,cols.response))';
      data{isub}.luref(icond,:) = flipud(raw_data(luremask,cols.response))';
    end % for icond=1:ncond
    
    % Convert targf and luref to numeric matrices
    data{isub}.targf = cell2mat(data{isub}.targf);
    data{isub}.luref = cell2mat(data{isub}.luref);
end % for isub=1:nsubs

data = data';
