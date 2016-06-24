function outData = calc_parameter_se_covar(data,model,index,varargin)
% Usage:
%   outData = calc_parameter_se_covar(data,model,index,varargin)
%
% CALC_PARAMETER_SE_COVAR returns the hessian matrix, covariance matrix, and
% correlation matrix, for the parameters of the specified model that were
% fit to the data (including criterion parameters). Thus, parameters that
% were not allowed to vary in the model fitting routine (e.g., parameters
% where the lower and upper bounds were identical) are not included.
% The Hessian matrix is obtained using numerical approximation.
% Additionally, the standard errors for the parameter estimates are
% provided for convenience. The data is returned in a structure variable. 
%
% Required Input:
%   data - This should be a structure variable that is output from the
%   ROC_SOLVER function.
%
%   model - String indicating the model whose data you would like to plot
%   (e.g., 'dpsd'). 
%
%   index - A numeric identifier of the iteration for the specified model
%   you would like to plot. Typically, this will be 1 unless you have
%   stored multiple iterations of one model (e.g., 'dpsd') in the same
%   structure variable. See the 'append' option in the ROC_SOLVER function
%   for more informatino on this.
%
% Optional Input:  
%   ('delta', delta) - This is a scalar input specifying the step size for
%   calculating the Hessian matrix. If not given, the default is .001. 
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

% Set defaults
delta = .001;
for k = 1:2:nargin-3
    switch varargin{k}
        case 'delta'
            delta = varargin{k+1};
    end
end

% Extract the original data and bf_pars vectors from the data structure
targf = data.observed_data.target.frequency;
luref = data.observed_data.lure.frequency;
model_field = model_info(model,'field');
nPars = model_info(model,'nPars');
bf_pars = data.(model_field)(index).optimization_info.bf_pars;

% Based on the model, select the non-criterion parameters that were
% estimated.
fitPars = ...
    data.(model_field)(index).optimization_info.lower_bounds ~= ...
    data.(model_field)(index).optimization_info.upper_bounds;    

% Convert bf_pars to theta vector. This will be re-shaped later.
theta = bf_pars(:)';

% Create the e vector to set up e_i's and e_j's
e = eye(length(theta)) .* delta;

% Create the hessian matrix (C)
for i = 1:length(theta)
    for j = 1:length(theta)
        
        % Set up the paramter vectors for the calculations
        vec1 = reshape(theta + e(i,:) + e(j,:),size(bf_pars));
        vec2 = reshape(theta + e(i,:) - e(j,:),size(bf_pars));
        vec3 = reshape(theta - e(i,:) + e(j,:),size(bf_pars));
        vec4 = reshape(theta - e(i,:) - e(j,:),size(bf_pars));
        
        % Do the math in a piecewise fasion for each cell in C on the
        % positive value of the log-likelihood function
        eq1 = -1*calc_model_fit('-LL',model,vec1,targf,luref,[]);
        eq2 = -1*calc_model_fit('-LL',model,vec2,targf,luref,[]);
        eq3 = -1*calc_model_fit('-LL',model,vec3,targf,luref,[]);
        eq4 = -1*calc_model_fit('-LL',model,vec4,targf,luref,[]);
        
        % Calculate C(i,j)
        C(i,j) = eq1 - eq2 - eq3 + eq4;
        
    end
end

% Finish off hessian matrix calculation and select the fitted pars.
hessMat = C ./ (4 .* (delta .^ 2));
hessMat = hessMat(fitPars,fitPars);

% Calculate covarMat using the left divide notation (not INV due to issues
% reported online).  
covarMat = hessMat\eye(size(hessMat));

% Calculate correlation matrix using corrcov
corrMat = corrcov(covarMat);

% Get the par SE vector
parSE = sqrt(diag(covarMat))';

% Get the parNames variable
parNames = model_info(model,'parNames');
for i = (length(fitPars)-nPars):-1:1
    parNames = [parNames strcat('c',num2str(i))];
end
parNames = parNames(fitPars);

% Make the output
outData.parNames = parNames;
outData.hessMat = hessMat;
outData.covarMat = covarMat;
outData.corrMat = corrMat;
outData.parSE = parSE;

end