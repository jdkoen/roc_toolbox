function chi_sq = calc_chi_squared(targf,pred_targf,luref,pred_luref,ignoreConds)
% Usage: 
%   chi_sq = calc_chi_squared(targf,pred_targf,luref,pred_luref,ignoreConds)
%
% CALC_CHI_SQUARED calculates the chi^2 value betwen observed and predicted 
% rating data. 
%
% Input: 
%   targf - A MxN row vector of observed target frequencies in each rating 
%   bin. The order of confidence ratings should be in descending order 
%   from the first column to the last. That is, the highest rating that 
%   can be given to a target item should be in the first element and the 
%   highest rating that can be given to a lure should be the last element.
%   For example, a six point scale with a '6-sure target' and '1-sure lure'
%   responses should be entered in the order [6s 5s 4s 3s 2s 1s].
%
%   pred_targf - A MxN row vector of predicted target frequencies for each 
%   rating bin. The order of values is identical to targf.
%
%   luref - A MxN row vector of observed lure frequencies in each rating 
%   bin. The order of values should is identical targf.
%
%   pred_tluref - A MxN row vector of predicted lure frequencies for each 
%   rating bin. The order of values should is identical targf.
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
        sum(size(targf)~=size(pred_targf))>0 || ...
        sum(size(targf)~=size(pred_luref))>0
    error('Size of observed and/or predicted target and lure inputs are inconsistent.')
end

% Preallocate Variables
targ_chi=zeros(size(targf));
lure_chi=zeros(size(targf));

for a=1:size(targf,1)
    for b=1:size(targf,2)
        % Calculate Chi^2 at each bin.
        targ_chi(a,b)=((targf(a,b)-pred_targf(a,b)).^2)./pred_targf(a,b);
        lure_chi(a,b)=((luref(a,b)-pred_luref(a,b)).^2)./pred_luref(a,b);
    end
end

% Sum the targ_chi matrix
chi_sq_targ = sum(sum(targ_chi));

% Sum the lure_chi matrix excluding rows that are in ignoreConds if necessary
if isempty(ignoreConds)
    chi_sq_lure = sum(sum(lure_chi));
else
    chi_sq_lure = 0;
    for i = 1:size(lure_chi,1)
        if any(ismember(ignoreConds,i)) % Use any to skip summing excluded rows
            continue;
        else
            chi_sq_lure = chi_sq_lure + sum(lure_chi(i,:));
        end
    end
end

chi_sq = chi_sq_targ + chi_sq_lure;

end