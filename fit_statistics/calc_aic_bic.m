function [aic,cor_aic,bic] = calc_aic_bic(LL,nPars,nTrials)
% Usage: 
%   [aic,cor_aic,bic]=calc_aic_bic(LL,nPars,nTrials)
%
% CALC_AIC_BIC calculates the Akaike Information Criterion (AIC), the 
% corrected AIC, and the Bayesian information criterion (BIC). 
%
% Required Input: 
%   LL - The optimized log-likelihood value.
%   nPars - The number of parameters in the model.
%   nTrials - The number of trials in the observed data.
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
if nargin<3
    error('Not enough inputs given to the function.')
end

% Error check for size of inputs
if length(LL)~=length(nPars) || length(LL)~=length(nPars)
    error('Size of inputs are inconsistent.')
end

% Preallocate variables
aic=zeros(length(LL),1);
cor_aic=zeros(length(LL),1);
bic=zeros(length(LL),1);

for a=1:length(LL)
    % Calculate AIC
    aic(a,1)=(-2*LL(a,1))+(2*nPars(a,1));
    
    % Calculate Corrected AIC
    cor_aic(a,1)=aic(a,1)+((2*nPars*(nPars+1))/(nTrials-nPars-1));

    % Calculate BIC
    bic(a,1)=(-2*LL(a,1))+(nPars(a,1)*log(nTrials(a,1)));
end

end