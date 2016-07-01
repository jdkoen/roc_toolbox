function bootFreq = bootstrap_freqs(targf,luref,ignoreConds,rngSeed)
% Usage: 
%   bootFreq = bootstrap_freqs(targf,luref)
%
% BOOTSTRAP_FREQUENCIES randomly samples, with replacement, frequencies for
% target and lure items. The maain purpose of this function is to create
% random samples to estimate standard errors of the parameters.
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
% Optional Input:
%   ignoreConds - This is a N x 1 vector that identifies conditions whose
%   new items (luref) should be ignored. Instead, the frequency of
%   responses for the conditions specified by this vector will be identical
%   to the frequencies in the condition one row above. This is useful for
%   simulating data from designs that have multiple types of target items
%   plotted against the same lure items. For example, say you have a design
%   with two types of target items and one class of lure items. Having
%   ignoreConds = 2; will result in luref(2,:) = luref(1,:). This option is
%   similar to the ignoreConds option in the roc_solver. Note that 1 cannot
%   be included in this vector, else the program will crash. 
%
%   rngSeed - Scalar value to seed the random number generator.
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


% Error check number of inputs.
if nargin < 2
    error('Too few input arguments.')
end

% Check for errors in targf and luref, and get nBins and nConds
freq_size_check(targf,luref);
[nConds,nBins] = size(targf);

% Define ignoreConds if it does not exist
if ~exist('ignoreConds','var')
    ignoreConds = [];
end

% Seed rng with rngSeed
if exist('rngSeed','var') 
    if ~isempty(rngSeed)
        rng(rngSeed);
    end
end

% Initialize output variable
bootFreq.targf = zeros(nConds,nBins);
bootFreq.luref = bootFreq.targf;

% Generate vectors with individual trials (similar structure to targf and
% luref; rows are conditions)
nTrials.targf = sum(targf,2);
nTrials.luref = sum(luref,2);
binVals = nBins:-1:1;
for i = 1:nConds
    
    % Initialize temp variables
    temp1.targf = []; temp2.targf = zeros(size(nTrials.targf(i)));
    temp1.luref = []; temp2.luref = zeros(size(nTrials.luref(i)));
    
    % Create vector of trials and store in temp1
    for j = 1:nBins
        
        temp1.targf = horzcat(temp1.targf,repmat(binVals(j),1,targf(i,j)));
        temp1.luref = horzcat(temp1.luref,repmat(binVals(j),1,luref(i,j)));
        
    end
    
    % Randomly draw nTrials from temp1.targf and store in temp2.targf
    % Randomize is done with replacement
    for j = 1:nTrials.targf(i)
        
        randTrials = temp1.targf(randperm(nTrials.targf(i)));
        temp2.targf(j) = randTrials(1);
        clear randTrials;
        
    end
    
    % Randomly draw nTrials from temp1.luref and store in temp2.luref
    % Randomize is done with replacement
    for j = 1:nTrials.luref(i)
        
        randTrials = temp1.luref(randperm(nTrials.luref(i)));
        temp2.luref(j) = randTrials(1);
        clear randTrials;
        
    end
    
    % Store current condition in the output variable
    for j = 1:nBins
        
        bootFreq.targf(i,j) = sum(temp2.targf == binVals(j));
        bootFreq.luref(i,j) = sum(temp2.luref == binVals(j));
        
    end
    
end

% Constrain the luref frequencies by ignoreConds
for b = 1:length(ignoreConds)
    bootFreq.luref(ignoreConds(b),:) = ...
        bootFreq.luref(ignoreConds(b)-1,:);
end

end
    
        
        
        
        
        


