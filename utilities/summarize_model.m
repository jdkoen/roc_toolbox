function [nObs,nPars,df] = summarize_model(nConds,nBins,nConstr,pars,LB,UB,ignoreConds)
% Usage:
%   [nObs,nPars,df] = summarize_model(nConds,nBins,x0,LB,UB)
%
% SUMMARIZE_MODEL returns the number of observed data points the number of
% free parameters in the model, and the degrees of freedom in the model.
% Also, if degress of freedom is negative, an error is thrown. 
%
% Required Input:
%   nConds - A scalar input indicating the number of within-subject
%   conditions in the model.
%
%   nBins - A scalar input specifying the number of rating bins.
%
%   nConstr - A scalar input specifying the number of parametrs that are
%   constrained with a non-linear constraint function.
%
%   pars - A matrix of parameters for a model.
%
%   LB - A matrix of lower bounds for pars
%
%   UB - A matrix of upper bounds for pars.
%
%   ignoreConds - A vector defining the number of lure conditions to ignore
%   when calculating the model fit. It is used here to correctly calculate
%   the number of observations.
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

% Calculate number of observed data points
nObs = 2 * nConds * nBins - (nBins * length(ignoreConds));

% Calculate the number of parameters in the model
nPars = length(pars(:)) - (sum(LB(:)==UB(:))) - nConstr;

% Calculate the degrees of freedom
df = (nObs - (2 * nConds - length(ignoreConds)) - nPars);

% If negative degrees of freedom, return an error. 
if df < 0
    error('There are too few degrees of freedom to fit the specified model.')
end

end

