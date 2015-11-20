function sst = calc_ss_total(targf,luref,ignoreConds)
% usage: sst = calc_ss_total(targf,luref,ignoreConds)
%
% CALC_SS_TOTAL returns the sum-of-squares total for ratings data. This
% value represents the amount of total amount of variance to be accounted
% for.
%
% Input:
%   targf - A 1xN row vector of observed target frequencies in each rating 
%   bin. The order of confidence ratings should be in descending order 
%   from the first element to the last. That is, the highest rating that 
%   can be given to a target item should be in the first element and the 
%   highest rating that can be given to a lure should be the last element.
%   For example, a six point scale with a '6-sure target' and '1-sure lure'
%   responses should be entered in the order [6s 5s 4s 3s 2s 1s].
%   
%   luref - A 1xN row vector of observed lure frequencies in each rating 
%   bin. The order of values should is identical targf.
%
%   ignoreConds - This is a M x 1 vector of numbers that identify what rows of
%   the luref condition are to be excluded from the fit statistic
%   calculation. This is useful for paradigms where you have multiple
%   target distributions plotted against a single lure distribution.
%
% NOTE: All vectors (except ignoreConds) must be the same size, else an error
% is retured.
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

% Check for errors in the number of input arguments. 
if nargin<3
    error('Not enough inputs given to the function.')
end

% Check for input mismatch in frequency vectors.
if sum(size(targf)~=size(luref))>0
    error('Size of target and lure inputs are inconsistent.')
end

% Calculate observed probabilities
obs=freq2zscores(targf,luref);

% Define mean proportions
targ_mean=mean(obs.target.proportions,2);
lure_mean=mean(obs.lure.proportions,2);

% Preallocate vairables
targ_sst=zeros(size(targf));
lure_sst=zeros(size(targf));
sst=zeros(size(targf,1),1);
     
% Calculate SST in each rating bin 
for a=1:size(targf,1)
    for b=1:size(targf,2) 
        targ_sst(a,b)=(obs.target.proportions(a,b)-targ_mean(a)).^2;
        lure_sst(a,b)=(obs.lure.proportions(a,b)-lure_mean(a)).^2;
    end
end

% Sum the targ_sst matrix
tsst = sum(sum(targ_sst));

% Sum the lure_sst excluding rows that are in ignoreConds if necessary
if isempty(ignoreConds)
    lsst = sum(sum(lure_sst));
else
    lsst = 0;
    for i = 1:size(lure_sst,1)
        if any(ismember(ignoreConds,i)) % Use any to skip summing excluded rows
            continue;
        else
            lsst = lsst + sum(lure_sst(i,:));
        end
    end
end

sst = tsst + lsst;

end