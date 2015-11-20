function [c,ceq,n,constrModel] = criteria_constraint(pars,model,ignoreConds,constrfun)
% Usage:
%   [c,ceq,n,constrModel] = criteria_constraint(pars,model,ignoreConds,constrfun)
%
% This function applies an equality constraint on the criteria parameters
% for the conditions specified in exc_conds. The variable ignoreConds is a
% vector defining the rows that will be excluded from the fit statistic
% calculation. This is necessary in cases when you have a paradigm with
% multiple types of targets but only group of lures (i.e., there are not
% unique target-lure sets in each row, or condition). 
%
% This function returns an empty vector for the inequality constraints 
% (c), the vector specifying the equality constraints (ceq), the number
% of inequality constraints (n), and the model that the contraints were
% applied to (constrModel). The first two outputs (c and ceq) are
% necessary for the FMINCON function call in the ROC_SOLVER function,
% whereas the latter two outputs (n and constrModel) are used within the
% ROC_SOLVER function for calculating the number of paramters to be
% estimated and error checking, respectively. 
%
% Required Input:
%   pars - A M x N matrix of parameter values. Typically, this will be
%   the x0 variable from the GEN_PARS function.
%
%   model - This specifies the model that the criteria constraints are
%   being applied to. This is necessary to constrain the appropriate
%   elements of the pars vector.
%
%   ignoreConds - This is a vector of integers specifying the rows (i.e.,
%   conditions) to be excluded from consideration in the fit statistics
%   (i.e., constrained). The criterion parameters for row M, with M >= 2,
%   will be constrained to equal the criterion parameters for row M - 1. 
%
%   constrfun - This is a function handle for another equality constraint
%   function to be appended to the criteria constaints supplied by this
%   function. In other words, this allows additional constraints to be
%   added on top of the criteria constraints.
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

% Error check pars
if size(pars,1) < 2
    error('Must have more than one condition to apply criteria constraints.')
end

% Error check ignoreConds
if sum(ignoreConds<2) > 0
    error('Values in ignoreConds must be greater than 2')
end

% Set inequality constraints
c = []; 

% Define criteria parameter
nPars = model_info(model,'nPars');
crit = pars(:,nPars+1:end);

% Set equality constraints on criteria and store in ceq1
ceq1 = zeros(length(ignoreConds),size(crit,2));
for i = 1:length(ignoreConds)
    ceq1(i,:) = crit(ignoreConds(i)-1,:) - crit(ignoreConds(i),:);
end
ceq1 = ceq1(:);

% Calculate ceq2 if constrfun exists
if isempty(constrfun)
    ceq2 = [];
else
    [~,ceq2,~,model2] = constrfun(pars);
    if ~strcmpi(model,model2)
        error(['Model specified in constraint function is different from model ' ...
        'specified for the roc_solver'])
    end
    
end    

% Finalize ceq
ceq = vertcat(ceq1,ceq2);
    
% Specify the number of contraints 
n = length(ceq);

% Specify the model this constraint is to be applied to. This is used for
% redundant checking in the roc_solver to ensure accuracy.
constrModel = model;

end