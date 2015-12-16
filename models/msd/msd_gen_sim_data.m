function simData = msd_gen_sim_data(pars,nTarg,nLure,nSamples,ignoreConds,rngSeed)
% usage: 
%   simData = msd_gen_sim_data(pars,nTarg,nLure,nSamples)
%
% MSD_GEN_SIM_DATA generates random data sets from the DPSD model using a
% bootstrap procedure. The random data sets are returned to a structure
% variable with a targf and luref fields. The frequency matrices are in a
% cell array, such that targf{1} and luref{1} correspond to the data sets
% generated in the first sample. 
%
% Required Input:
%   pars - An M x N vector of paramter values for the MSD model. See 
%   MSD_GEN_PARS for more information and to create this vector.
%
%   nTarg - A M x 1 vector specificying the number of trials. The
%   length of this vector must equal the number of rows in pars.
%
%   nLure - A M x 1 vector specificying the number of trials. The
%   length of this vector must equal the number of rows in pars.
%
%   nSamples - A scalar value specifying the number of random data sets to
%   generate.
%
% Optional Input:
%   ignoreConds - This is a N x 1 vector that identifies conditions whose
%   new items (luref) should not be simulated. Instead, the frequency of
%   responses for the conditions specified by this vector will be identical
%   to the frequencies in the condition one row above. This is useful for
%   simulating data from designs that have multiple types of target items
%   plotted against the same lure items. For example, say you have a design
%   with two types of target items and one class of lure items. Having
%   ignoreConds = 2; will result in luref(2,:) = luref(1,:). This option is
%   similar to the ignoreConds option in the roc_solver. 
%
%   rngSeed - Scalar value to seed the random number generator. Useful to
%   reproduce simulated data. 
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

% Error check number of inputs.
if nargin < 4
    error('Too few input arguments.')
end

% Seed rng with rngSeed
if exist('rngSeed','var') 
    if ~isempty(rngSeed)
        rng(rngSeed);
    end
end

% If ignoreConds doesn't exist, set it as empty
if ~exist(ignoreConds,'var')
    ignoreConds = [];
end

% Error check for length of nTarg and nLure
if length(nTarg) ~= length(nLure) || length(nTarg) ~= size(pars,1)
    error(['The number of specified conditions are not consistent between ' ...
       'pars, nTarg, and nLure.'])
end

% Error check that nSamples is >= 1
if ~(nSamples >= 1)
    error('The number of sampled data sets must be >= 1.')
end

% Assign parameter variables
lambda_targ = pars(:,1);
Dprime1_targ = pars(:,2);
var1_targ = pars(:,3);
Dprime2_targ = pars(:,4);
var2_targ = pars(:,5);
lambda_lure = pars(:,6);
Dprime1_lure = pars(:,7);
var1_lure = pars(:,8);
Dprime2_lure = pars(:,9);
var2_lure = pars(:,10);
crit = [cumsum(pars(:,11:end),2) inf(size(pars,1),1)];

% Specify number of conditions and response bins.
nconds = size(pars,1);
nbins = size(crit,2);
rating_bin = nbins:-1:1;

% Preallocate output variable
simData.targf = cell(nSamples,1);
simData.luref = cell(nSamples,1);
temp_targ = cell(nconds,1);
temp_lure = cell(nconds,1);
for a = 1:nconds
    temp_targ{a} = zeros(nTarg(a),4);
    temp_lure{a} = zeros(nLure(a),4);
end

% Here are the cell column IDs for reference. 
% temp_targ & temp_lure:
% 1 = Dprime1/var1 strength
% 2 = Dprime2/var2 strength
% 3 - Distribution Selector (1 in Dprime1 distro, 0 in Dprime2 distro)
% 4 - Selected strength parameter

% Start the loop to create data.
for samp = 1:nSamples
    % Create randomized data set
    for a = 1:nconds
        % Determine Dprime1/var1 target strength values
        temp_targ{a}(:,1) = ...
            norminv(rand(nTarg(a),1),-(Dprime1_targ(a)+Dprime2_targ(a)),var1_targ(a));
        
        % Determine Dprime2/var2 target strength values
        temp_targ{a}(:,2) = ...
            norminv(rand(nTarg(a),1),-Dprime2_targ(a),var2_targ(a));
        
        % Determine Dprime1/var1 lure strength values
        temp_lure{a}(:,1) = ...
            norminv(rand(nLure(a),1),(Dprime1_lure(a)+Dprime2_lure(a)),var1_lure(a));
        
        % Determine Dprime2/var2 lure strength values
        temp_lure{a}(:,2) = ...
            norminv(rand(nLure(a),1),Dprime2_lure(a),var2_lure(a));
        
        % Determine distribution selector for targets and lures
        temp_targ{a}(:,3) = (rand(nTarg(a),1) > 1-lambda_targ(a));
        temp_lure{a}(:,3) = (rand(nLure(a),1) > 1-lambda_lure(a));
        
        % Select the appropriate target strength value
        for trial = 1:nTarg(a)
            if temp_targ{a}(trial,3) == 1
                temp_targ{a}(trial,4) = temp_targ{a}(trial,1);
            else
                temp_targ{a}(trial,4) = temp_targ{a}(trial,2);
            end
        end
        
        % Select the appropriate lure strength value
        for trial = 1:nLure(a)
            if temp_lure{a}(trial,3) == 1
                temp_lure{a}(trial,4) = temp_lure{a}(trial,1);
            else
                temp_lure{a}(trial,4) = temp_lure{a}(trial,2);
            end
        end
        
        % Bin simulated data
        [simData.targf{samp}(a,:), simData.luref{samp}(a,:)] = ...
            bin_sim_data(crit(a,:), temp_targ{a}(:,4), temp_lure{a}(:,4));
        
    end
    
    % Constrain the luref frequencies by ignoreConds
    for b = 1:length(ignoreConds)
        simData.luref{samp}(ignoreConds(b),:) = ...
            simData.luref{samp}(ignoreConds(b)-1,:);
    end  
end

end
    
