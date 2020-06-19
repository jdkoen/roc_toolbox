function simData = uvsd_gen_sim_data(pars,nTarg,nLure,nSamples,ignoreConds,rngSeed)
% usage: 
%   simData = uvsd_gen_sim_data(pars,nTarg,nLure,nSamples)
%
% UVSD_GEN_SIM_DATA generates random data sets from the UVSD model using a
% bootstrap procedure. 
%
% Required Input:
%   pars - A MxN matrix of memory strength (d') and variance (Vo)
%   parameters. See UVSD_GEN_PARS for more information and to create this 
%   vector.
%
%   nTarg - A Mx1 column vector specificying the number of trials. The
%   length of this vector must equal the number of rows in pars.
%
%   nLure - A Mx1 column vector specificying the number of trials. The
%   length of this vector must equal the number of rows in pars.
%
%   nSamples - A scalar value specifying the number of random data sets to
%   generate. 
%
% Output:
%   The output is a structure variable containing a field for target
%   (targf) and lure (luref) frequencies. The frequencies are output to a
%   cell array. Each cell represents a randomly generated data set. Note
%   that, for instance, targf{1} and luref{1} correspond to the data sets
%   generated in the first sample. 
%
% Author: Joshua D. Koen


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
if ~exist('ignoreConds','var')
    ignoreConds = [];
end

% Error check for length of nTarg and nLure
if length(nTarg) ~= length(nLure) || length(nTarg) ~= size(pars,1)
    error(['The number of specified conditions are not consistent between ' ...
       'pars, nTarg, and nLure.'])
end

% Assign parameter variables
Dprime = pars(:,1);
Vo = pars(:,2);
crit = [cumsum(pars(:,3:end),2) inf(size(pars,1),1)];

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
    temp_targ{a} = zeros(nTarg(a),1);
    temp_lure{a} = zeros(nLure(a),1);
end

% Here are the cell column IDs for reference. 
% 1 - Memory strength

% Start the loop to create data.
for samp = 1:nSamples
    % Create randomized data set
    for a = 1:nconds
        % Determine fmemory
        temp_targ{a}(:,1) = norminv(rand(nTarg(a),1),-Dprime(a),Vo(a));
        temp_lure{a}(:,1) = norminv(rand(nLure(a),1));
        
        % Bin simulated data
        [simData.targf{samp}(a,:), simData.luref{samp}(a,:)] = ...
            bin_sim_data(crit(a,:), temp_targ{a}(:,1), temp_lure{a}(:,1));
        
    end
    
    % Constrain the luref frequencies by ignoreConds
    for b = 1:length(ignoreConds)
        simData.luref{samp}(ignoreConds(b),:) = ...
            simData.luref{samp}(ignoreConds(b)-1,:);
    end  
end

end
    
