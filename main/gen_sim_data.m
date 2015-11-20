function simData = gen_sim_data(model,pars,nTarg,nLure,nSamples,ignoreConds,rngSeed)
% Usage:
%   simData = gen_sim_data(model,pars,nTarg,nLure,nSamples,ignoreConds)
%
% GEN_SIM_DATA returns a strucutre containing simulated target and lure
% frequency matrices drawn fro mthe distributions defined by the model and
% pars inputs. The output of this function is useful for running bootstrap
% simulations 
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
%   nSamples - A scalar specifying the number of simulated data sets to
%   generate. 
%
% Optional Input:
%   ignoreConds - This is a N x 1 vector that identifies conditions whose
%   new items (luref) should not be simulated. Instead, the frequency of
%   responses for the conditions specified by this vector will be identical
%   to the frequencies in the condition one row above. This is useful for
%   simulating data from designs that have multiple types of target items
%   plotted against the same lure items. For example, say you have a design
%   with two types of target items and one class of lure items. Having
%   ignoreConds = 2; will result in luref(2,:) = luref(1,:). This option is
%   similar to the ignoreConds option in the roc_solver. Note that 1 cannot
%   be included in this vector, else the program will crash. 
%
%   rngSeed - Scalar value to seed the random number generator. Useful to
%   reproduce simulated data. 
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

% Define ignoreConds if it does not exist
if ~exist('ignoreConds','var')
    ignoreConds = [];
end

% Run the appropriate function to generate simulated data
simData = feval(strcat(model,'_gen_sim_data'),pars,nTarg,nLure,nSamples,ignoreConds,rngSeed);

end