function predData = calc_pred_data(model,pars,nTarg,nLure,output)
% Usage:
%   predData = calc_pred_data(model,pars,nTarg,nLure,output)
%
% CALC_PRED_DATA returns the predicted frequencies, proportions,
% cumulative proportions, and z-values for the specified model. 
%
% Required Input:
%   model - A string identfier for the model. This input must be an
%   existing model in teh toolbox. These models can be seen by running the
%   GET_ALL_MODELS function. 
%
%   pars - An M x N vector of paramter values for the model. This parameter
%   vector can be generated using the $model_gen_pars functions (see those
%   help files for more information on the contents of the pars, or x0,
%   variable). 
%
%   nTarg - A M x 1 vector specificying the number of trials. The
%   length of this vector must equal the number of rows in pars.
%
%   nLure - A M x 1 vector specificying the number of trials. The
%   length of this vector must equal the number of rows in pars.
%
%   output - A string variable specifying the type of predicted data to
%   calculate. 'points' will return the predicted data for each rating bin
%   specified by the pars input. 'roc' will return the predicted data for a
%   wide range of criterion values, which is useful for plotting a
%   hypothetical ROC function. The only difference is in the criterion
%   parameters that are used (points uses the criterion location specified
%   in the pars variable, whereas roc uses a range from -3 to +3). 
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

% Check for inconsistent sizes between pars, nTarg, and nLure
if size(pars,1)~=length(nTarg) || size(pars,1)~=length(nLure)
    error(['The number of conditions do not match between the pars, '...
        'nTarg, and nLure vectors.'])
end

% Run the requested function to get predData
predData = feval(strcat(model,'_calc_pred_data'),pars,nTarg,nLure,output);

end
