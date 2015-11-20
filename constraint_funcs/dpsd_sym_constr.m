function [c,ceq,n,constrModel] = dpsd_sym_constr(pars)
% usage:
%   [c,ceq,n,constrModel] = dpsd_sym_constr(pars)
%
% This function constrains the Ro and Rn parameters to be equal to each
% other within, but not across, each condition (i.e., row) in pars. This 
% should be passed to the ROC_SOLVER function as a function handle.
%
% This function returns the vector specifying the inequality constraints 
% (c), the vector specifying the inequality constraints (ceq), the number
% of inequality constraints (n), and the model that the contraints were
% applied to (constrModel). The first two outputs (c and ceq) are
% necessary for the FMINCON function call in the ROC_SOLVER function,
% whereas the latter two outputs (n and constrModel) are used within the
% ROC_SOLVER function for calculating the number of paramters to be
% estimated and error checking, respectively. 
%
% Required Input:
%   pars - A M x N matrix of parameter values. Typically, this will be
%   the x0 variable from the GEN_PARS function. See help GEN_PARS for more
%   information.
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

% Set inequality constraints
c = []; 

% Set equality constraints
ceq = zeros(size(pars,1),1);
for curCond = 1:size(pars,1)
    ceq(curCond) = pars(curCond,1) - pars(curCond,2);
end

% Manually specify the number of contraints 
n = length(ceq);

% Specify the model this constraint is to be applied to. This is used for
% redundant checking in the roc_solver to ensure accuracy.
constrModel = 'dpsd';

end