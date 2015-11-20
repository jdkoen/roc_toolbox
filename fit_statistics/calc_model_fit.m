function fitValue = calc_model_fit(fitStat,model,pars,targf,luref,ignoreConds)
% usage: calc_fitValue(fitStat,model,pars,targf,luref,ignoreConds)
%
% CALC_MODEL_FIT calculates the user requested fit statistic for the
% parameters specified in pars of a requested model. 
%
% Input:
%   fitStat - A string identifier for the fit statistic to be used in the
%   estimation. There are two options:
%       '-LL' - Negative Log Likelihood
%       'SSE' - Sum-of-Square Errors
%       'G' - G Fit Statistic
%       'X2' - Chi-Squared
%
%   model - A string identfier for the model. This input must be an
%   existing model in teh toolbox. These models can be seen by running the
%   GET_ALL_MODELS function. 
%
%   pars - A M x N row vector of parameters for the specified model. The
%   input requirements differ depending on the selected model.  
%
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
%   ignoreConds - This is a M x 1 vector that identifies what rows, if any, of
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

% Check if the model exists
model_check(model);

% Check for error is size of targf and luref
freq_size_check(targf,luref);

% Check if pars is the right size
par_size_check(model,size(targf,2),pars);

% Get the predicted data
predData = calc_pred_data(model,pars,sum(targf,2),sum(luref,2),'points');

% Calculate the specified fit statistic for each condition seperately.
if strcmpi(fitStat,'-LL')
    fitValue = calc_neg_log_likelihood( ...
        targf, predData.target.proportions,...
        luref, predData.lure.proportions, ...
        ignoreConds);
elseif strcmpi(fitStat,'G')
    fitValue = calc_g( ...
        targf, predData.target.proportions,...
        luref, predData.lure.proportions, ...
        ignoreConds);
elseif strcmpi(fitStat,'X2')
    fitValue = calc_chi_squared( ...
        targf, predData.target.frequency,...
        luref, predData.lure.frequency, ...
        ignoreConds);
elseif strcmpi(fitStat,'SSE')
    fitValue = calc_ss_error( ...
        targf, predData.target.proportions,...
        luref, predData.lure.proportions, ...
        ignoreConds);
else    
    error('An unrecognized fit statistic was selected. Input must -LL, G, X2, or SSE.')    
end    

end