function [targf_sim,luref_sim] = bin_sim_data(crit,targ_vals,lure_vals)
% Usage:
%   [targf_sim,luref_sim] = bin_sim_data(crit,targ_vals,lure_vals);
% 
% BIN_SIM_DATA returns a matrix of target and lure frequencies of simulated
% data. This function is writen to be used with functions that create
% simulated (i.e., bootstrapped) data from signal detection models for
% rating ROCs.
%
% Required input:
%   crit - This is a vector of criterion values, which is used to
%   determine what bin a trial belongs to. 
%
%   targ_vals - This is a vector of "evidence" values for target trials.
%   The magnitude of each element of this vector relative to the crit
%   vector determines what rating will be assigned to a trial.
%
%   lure_vals - This is the same as targ_vals, but for lure trials. 
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

% Preallocate confidence bins
targf_sim = zeros(size(crit));
luref_sim = zeros(size(crit));

% Loop through each criterion bin and trial
for i = 1:length(crit)
        
    % Create trial masks based on the current criterion location. This is
    % used to count frequencies
    if i == 1   
        targMask = targ_vals <= crit(i);
        lureMask = lure_vals <= crit(i);
    else
        targMask = (targ_vals > crit(i-1)) & (targ_vals <= crit(i));
        lureMask = (lure_vals > crit(i-1)) & (lure_vals <= crit(i));
    end
    
    % Count the frequency, and store in targf_sim and luref_sim
    targf_sim(i) = sum(targMask);
    luref_sim(i) = sum(lureMask);
    
end

end    