function [x0, LB, UB] = gen_pars(model,nBins,nConds,parNames)
% Usage:
%   x0 = gen_pars(model,nBins,nConds,parNames)
%   [x0,LB,UB] = gen_pars(model,nBins,nConds,parNames)
%
% GEN_PARS returns a vector of parameter values (x0) and, if requested,
% lower (LB) and upper (UB) bounds for the specified model. The 
% LB and UB variables are used with ROC_SOLVER to constrain the 
% starting parameters (x0) for the specified model.
%
% Required Input:
%   model - A string identfier for the model. This input must be an
%   existing model in teh toolbox. These models can be seen by running the
%   GET_ALL_MODELS function. 
%
%   nBins - This is the number of confidence bins in the scale used in
%   the experiment. This input creates a total of n-1 criterion points 
%   ranging between -1.5 and 1.5 using the following formula:
%       criterion_x0=[-1.5 ones(1,nBins-2)*(3/(nBins-2))];
%       criterion_LB=[-Inf zeros(1,nBins-2)];
%       criterion_UB=[Inf Inf inf(1,nBins-2)];
%
%   nConds - This corresponds to the number of experimental conditions
%   in the data that will be simultaneously fitted. For example, if there
%   is only one group of target items and one group of lure items, then
%   nConds should equal 1, If there are two classes of target and lure
%   items
%
%   parNames - This is a cell array of strings corresponding to the names
%   of the parameters to be estimated. See the (model)_gen_pars help
%   information for more details on the parameters.
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

% Check if model exists
model_check(model);

% Check if all parNames are allowable parameters
par_name_check(model,parNames);

% Run the requested function to get x0, LB, and UB
[x0, LB, UB] = feval(strcat(model,'_gen_pars'),nBins,nConds,parNames);

end