function neg_ll = calc_neg_log_likelihood(targf,pred_targp,luref,pred_lurep,ignoreConds)
% Usage: 
%   neg_ll = calc_neg_log_likelihood(targf,pred_targp,luref,pred_lurep,ignoreConds)
%
% CALC_NEG_LOG_LIKELIHOOD calculates the negative log likelhood value 
% betwen observed and predicted data. The negative  of the log likelihood
% is calculated for the purposes of using minimization routines for model
% fitting purposes. 
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
%   pred_targp - A 1xN row vector of predicted target raw proportions
%   (i.e., non-cumulative) for each rating bin. The order of values is the
%   same as targf.
%
%   luref - A 1xN row vector of observed lure frequencies in each rating 
%   bin. The order of values is the same as targf.
%
%   pred_tluref - A 1xN row vector of predicted lure raw proportions (i.e.,
%   non-cumulative) for each rating bin. The order of values is the
%   same as targf.
%
%   ignoreConds - This is a Mx1 vector that identifies what rows, if any, of
%   the luref condition are to be excluded from the fit statistic
%   calculation. 
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

% Check for errors in the number of input arguments. 
if nargin<5
    error('Not enough inputs given to the function.')
end

% Check for errors in matching lengths of input variables. 
if sum(size(targf)~=size(luref))>0 || ...
        sum(size(targf)~=size(pred_targp))>0 || ...
        sum(size(targf)~=size(pred_lurep))>0
    error('Size of observed and/or predicted target and lure inputs are inconsistent.')
end

% Preallocate target and lure G^2 vectors
targll=zeros(size(targf));
lurell=zeros(size(targf));

% Calculate the negative log-likelihood for each rating bin
for a=1:size(targf,1)
    for b=1:size(targf,2)
        
        if targf(a,b)==0
            targll(a,b)=0;
        else
            targll(a,b)=-targf(a,b)*log(pred_targp(a,b));
        end
        
        if luref(a,b)==0
            lurell(a,b)=0;
        else
            lurell(a,b)=-luref(a,b)*log(pred_lurep(a,b));
        end
    end
end

% Sum the targll matrix
neg_ll_targ = sum(sum(targll));

% Sum the lurell matrix excluding rows that are in ignoreConds if necessary
if isempty(ignoreConds)
    neg_ll_lure = sum(sum(lurell));
else
    neg_ll_lure = 0;
    for i = 1:size(lurell,1)
        if any(ismember(ignoreConds,i)) % Use any to skip summing excluded rows
            continue;
        else
            neg_ll_lure = neg_ll_lure + sum(lurell(i,:));
        end
    end
end

neg_ll = neg_ll_targ + neg_ll_lure;
        
end