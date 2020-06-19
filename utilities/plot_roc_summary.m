function f = plot_roc_summary(data,model,index,varargin)
% Usage:
%   f = plot_roc_summary(data,model,index,varargin)
%
% This function plots the observed and fitted ROC data, the best fitting
% paramters, and a plethora of fit statistics. A structure variable is
% returned with the handle for the figure (f.figure_handle) and the
% directory where the figure will be saved (f.outpath), if requested. 
%
% Required Input: 
%   data - This should be a structure variable that is output from the
%   ROC_SOLVER function.
%
%   model - String indicating the model whose data you would like to plot
%   (e.g., 'dpsd'). 
%
%   index - A numeric identifier of the iteration for the specified model
%   you would like to plot. Typically, this will be 1 unless you have
%   stored multiple iterations of one model (e.g., 'dpsd') in the same
%   structure variable. See the 'append' option in the ROC_SOLVER function
%   for more informatino on this.
%
% Optional Input:  
%   ('plot_conds', cond_labels) - A cell array of strings specifying the 
%       conditions you would like to plot. The default is to plot all
%       conditions in a model. However, if there are many conditions (e.g.,
%       more than 4), then it may be useful to plot only a subset of the
%       conditions you want to inspect. 
%
%   ('outpath',outpath) - This option specifies a directory to save the
%   summary figure that is printed to the screen. The file is saved in a
%   PDF format. The file name is formated from the data.subID
%   and data.(model)(index).modelID fields of the supplied structure
%   variable. The file name will appear as 'subID_modelID_summary_fig.pdf'.
%
% Authored by: Frederick Barrett
% © The Regents of the University of California, Davis campus, 2013
% All rights reserved.


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
for k = 1:2:nargin-3
    switch varargin{k}
        case 'plot_conds'
            cond_labels = varargin{k+1};
        case 'outpath'
            outpath = varargin{k+1};
        otherwise
            error('%s is an unrecognized input argument.',varargin{k})
    end
end

% Error check for number of input arguments
if nargin < 3
    error('Not enough input arguments.')
end

% If outpath not given, create an empty string
if ~exist('outpath','var')
    outpath = '';
end

% Define structure of output
f = struct('figure_handle','','outpath',outpath);

% Handle which conditions to plot
if exist('plot_conds','var')
  % Condition names specified; error check for accuracy
  cond_check = ismember(cond_labels,data.condition_labels);
  ncond = length(cond_labels);
  if ~all(cond_check)
    error('The following condition labels can not be found in your observed data: %s\n',...
        cellstr(cond_labels(~cond_check),','));
  end
else
  % Plot all conditions
  cond_labels = data.condition_labels;
  ncond = length(cond_labels);
end

% Specify model field
modelField = model_info(model,'field');
 
% Get observed data
cond_idxs = find(ismember(data.condition_labels,cond_labels));
obs_hit = data.observed_data.target.cumulative(:,1:end-1);
obs_fa = data.observed_data.lure.cumulative(:,1:end-1);
obs_hit_z = data.observed_data.target.zscores;
obs_fa_z = data.observed_data.lure.zscores;
obs_acc = data.observed_data.accuracy_measures;
obs_bias = data.observed_data.bias_measures;

% Get the parameters estimates adn SEs
params = data.(modelField)(index).parameters;
parSE = data.(modelField)(index).parSE;

% Get predicted ROC/zROC
roc = data.(modelField)(index).predicted_rocs.roc;
zroc = data.(modelField)(index).predicted_rocs.zroc;
fits = data.(modelField)(index).fit_statistics;
params = data.(modelField)(index).parameters;

% Initialize figure, size it appropriately, and position on screen
f.figure_handle = figure();
set(f.figure_handle, ...
    'PaperOrientation','landscape', ...
    'PaperPositionMode','auto', ...
    'PaperType','tabloid');

pos = get(f.figure_handle,'Position');
opos = get(f.figure_handle,'OuterPosition');
edge = -(opos(1)-pos(1))/2;

ss = get(0,'ScreenSize');
if ss(3)*0.9*(8.5/11) > ss(4)
  set(gcf,'OuterPosition',[edge+ss(3)*0.05 edge+ss(4)*0.05 ...
      ss(4)*0.85*(11/8.5) ss(4)*0.9]);
else
  set(gcf,'OuterPosition',[edge+ss(3)*0.05 edge+ss(4)*0.05 ...
      ss(3)*0.9 ss(3)*0.85*(8.5/11)]);
end
fs = get(f.figure_handle,'Position');

% Plot ROCs
subplot(2,4,4); hold on;
xlabel('False Alarm Rate');
ylabel('Hit Rate');
co = get(gca,'ColorOrder');
for icond=1:ncond % scatter plot first
  scatter(roc.lure(cond_idxs(icond),:),roc.target(cond_idxs(icond),:),1);
end % for icond=1:ncond
for icond=1:ncond % observations second
  plot(obs_fa(cond_idxs(icond),:),obs_hit(cond_idxs(icond),:),...
      'o','Color',co(icond,:));
end % for icond=1:ncond

% Format ROC plot
set(gca,'xlim',[0 1],'ylim',[0 1]);
line(get(gca,'xlim'),get(gca,'ylim'),'color','k');
axis square
title('Probability ROCs');
rpos = get(gca,'Position');
rpos(1) = 0.82;
set(gca,'Position',rpos);
l = legend(cond_labels,'Location','SouthOutside');
lpos = get(l,'Position');
lpos(2) = lpos(2)-0.12;
set(l,'Position',lpos);

% Plot zROCs
subplot(2,4,8); hold on;
xlabel('False Alarm Rate');
ylabel('Hit Rate');
for icond=1:ncond
  scatter(zroc.lure(cond_idxs(icond),:),zroc.target(cond_idxs(icond),:),1);
end % for icond=1:ncond
for icond=1:ncond
  plot(obs_fa_z(cond_idxs(icond),:),obs_hit_z(cond_idxs(icond),:),...
      'o','Color',co(icond,:));
end % for icond=1:ncond

% Format zROC plot
alim = max([xlim ylim]);
set(gca,'xlim',[-alim alim],'ylim',[-alim alim]);
line(xlim,ylim,'color','k');
axis square
title('zROCs');
zpos = get(gca,'Position');
zpos(1) = 0.82;
set(gca,'Position',zpos);

% Insert a table with subject, group, and model info
exitflag = data.(modelField)(index).optimization_info.exitflag;
if exitflag == 1
    fit_status = 'success';
elseif exitflag == 2
    fit_status = 'tolX criteria reached';
elseif exitflag == 3
    fit_status = 'failure';
else
    fit_status = 'warning - check for errors';
end

tsub_cols = {'subject id','group id','model','model ID','user notes', ...
    'exitflag','fit status'};
tsub_data = {num2str(data.subID), ...
    data.groupID,...
    model, ...
    data.(modelField)(index).modelID,...
    data.(modelField)(index).model_notes, ...
    num2str(exitflag), ...
    fit_status}';
uitable('Data',tsub_data,'RowName',tsub_cols,...
    'ColumnName',{''},...
    'Position',[fs(3)*0.05 fs(4)*0.72 fs(3)*0.3  fs(4)*0.3-fs(2)], ...
    'ColumnWidth',{fs(3)*0.17});
uicontrol('style','text','string','Subject, Group, and Model Information',...
    'position',[fs(3)*0.05 fs(4)*0.72+fs(4)*0.3-fs(2) ...
    fs(3)*0.3 fs(4)*0.03], 'FontWeight', 'bold');

% Insert a table with the fit statistics
tfit_data = cell2mat(struct2cell(fits));
uitable('Data',tfit_data,'RowName',fieldnames(fits),...
    'ColumnName',{''},....
    'Position',[fs(3)*0.05 fs(2)/2 fs(3)*0.3 fs(4)*0.6-fs(2)/3]);
uicontrol('style','text','string','Goodness of Fit Measures',...
    'position',[fs(3)*0.05 fs(2)/2+fs(4)*0.6-fs(2)/3 ...
    fs(3)*0.3 fs(4)*0.03], 'FontWeight', 'bold');

% Insert a table with accuracy and response bias
tarb_data = [cell2mat(struct2cell(obs_acc)')'; cell2mat(struct2cell(obs_bias)')'];
uitable('Data',tarb_data,...
    'RowName',[fieldnames(obs_acc); fieldnames(obs_bias)],...
    'ColumnName',cond_labels,...
    'Position',[fs(3)*.375 fs(4)*0.67 fs(3)*0.38 fs(4)*0.35-fs(2)]);
uicontrol('style','text','string','Accuracy and Response Bias',...
    'position',[fs(3)*.375 fs(4)*0.67+fs(4)*0.35-fs(2) ...
    fs(3)*0.38 fs(4)*0.03], 'FontWeight', 'bold');

% Insert a table with the parameter values
parLabels = fieldnames(params);
critLabels = cell(1,size(data.(modelField)(index).parameters.criterion,2));
for i = size(data.(modelField)(index).parameters.criterion,2):-1:1
    critLabels{1,i} = strcat('c',num2str(i));
end
parLabels = [parLabels(1:end-1); fliplr(critLabels)'];
    
tpar_data = cell2mat(struct2cell(params)')';
tpar_se = cell2mat(struct2cell(parSE)')';
table_data = cell(size(tpar_data));
for i = 1:numel(table_data)
    if all(isnan(tpar_se))
        table_data{i} = sprintf('%3.3f',tpar_data(i));
    else
        table_data{i} = sprintf('%3.3f (%3.3f)',tpar_data(i),tpar_se(i));
    end
end
    
uitable('Data',table_data,'RowName',parLabels,...
    'ColumnName',cond_labels,....
    'Position',[fs(3)*.375 fs(2)/2 fs(3)*0.38 fs(4)*0.6-fs(2)/3]);
uicontrol('style','text','string','Parameter Estimates',...
    'position',[fs(3)*.375 fs(2)/2+fs(4)*0.6-fs(2)/3 ...
    fs(3)*0.38 fs(4)*0.03], 'FontWeight', 'bold');

% Get Subject ID and convert to number is char
subID = data.subID;
if isnumeric(subID)
    subID = num2str(subID);
end

% Get Model ID
modelID = data.(modelField)(index).modelID;
if isnumeric(modelID)
    modelID = num2str(modelID);
end

% Create file name
saveFile = fullfile(f.outpath,strcat(subID,'_',modelID,'_summary_fig.pdf'));
% saveFile = fullfile(f.outpath,strcat(subID,'_',modelID,'_summary_fig.ps'));

% Save iamge to PostScript file
if ~isempty(outpath)
    print(f.figure_handle,'-dpdf',saveFile);
%     print(f.figure_handle,'-dpsc',saveFile);
end % if ~isempty(outpath)