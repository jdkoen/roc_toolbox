function predData = msd_calc_pred_data(pars,nTarg,nLure,output)
% usage: 
%   predData = msd_calc_pred_data(pars,nTarg,nLure,output)
%
% MSD_CALC_PREDICTED_DATA returns the predicted frequencies, proportions,
% cumulative proportions, and z-values for the MSD model with a 
% given set of parameters and criterion locations.
%
% Input:
%   pars - An MxN vector of paramter values for the MSD model. See 
%   MSD_GEN_PARS for more information and to create this vector.
%
%   nTarg - The number of target trials in a given condition. The length
%   of this vector must be equal to size(pars,1) and length(nLure). 
%
%   nLure - The number of lure trials in a given condition. The length
%   of this vector must be equal to size(pars,1) and length(nTarg). 
%
%   output - A string variable specifying the type of predicted data to
%   calculate. 'points' will return the predicted data for each rating bin
%   specified by the pars input. 'roc' will return the predicted data for a
%   wide range of criterion values, which is useful for plotting a
%   hypothetical ROC function. The only difference is in the criterion
%   parameters that are used (points uses the criterion location specified
%   in the pars variable, whereas roc uses a range from -3 to +3). 
%
% NOTE: The number of rating bins estimated is determined by the number of 
% criterion values +1 (i.e., length(pars(5:length(pars))+1). The number of
% target/lure conditions is estimated by the number of rows in pars (i.e.,
% size(pars,1))
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

% Preallocate variables
ptargc = ones(size(pars,1),size(pars,2)-8);
plurec = ones(size(pars,1),size(pars,2)-8);

% Assign parameter variables
lambda_targ = pars(:,1);
Dprime1_targ = pars(:,2);
var1_targ = pars(:,3);
Dprime2_targ = pars(:,4);
var2_targ = pars(:,5);
lambda_lure = pars(:,6);
Dprime1_lure = pars(:,7);
var1_lure = pars(:,8);
crit = cumsum(pars(:,9:end),2);

% If roc wanted, overwrite the crit variable
if strcmpi(output,'roc')
    clear crit;
    for a = 1:size(pars,1)
        crit(a,:) = linspace(-3,3,300);  
    end
end

% Calc predicted cumulative proportions
for b=1:size(pars,1)
    for c=1:size(crit,2)
        
        % Calculate predicted targets
        ptargc(b,c) = ...
            (lambda_targ(b) * normcdf(crit(b,c),-(Dprime1_targ(b)+Dprime2_targ(b)),var1_targ(b))) + ...
            ((1-lambda_targ(b)) * normcdf(crit(b,c),-Dprime2_targ(b),var2_targ(b)));
        
        % Calculate predicted lures
        plurec(b,c) = ...
            (lambda_lure(b) * normcdf(crit(b,c),Dprime1_lure(b),var1_lure(b))) + ...
            ((1-lambda_lure(b)) * normcdf(crit(b,c),0,1));
    
    end
end

% Create requested output
if strcmpi(output,'points')
    predData = cumulp2freq(ptargc,nTarg,plurec,nLure);
elseif strcmpi(output,'roc')
    predData.roc.target = ptargc;
    predData.roc.lure = plurec;
    predData.zroc.target = norminv(predData.roc.target);
    predData.zroc.lure = norminv(predData.roc.lure);
else
    error('Unrecognized input for output. Must be ''points'' or ''roc''.');
end

end
