function rating_data = cumulp2freq(targc,num_targ,lurec,num_lure)
% usage: 
%   cumulp2freq(targc,num_targ,lurec,num_lure)
%
% CUMULP2FREQ converts cumulative proportions to raw (i.e., non-cumulative)
% proportions, frequencies, and z-scores. 
%
% Cumulative proportions of 0 and 1 cause z-scores to be estimated as
% -Inf and +Inf, respectively. Such values are omitted from the output when
% this occurs. Additionally, the last element of the cumulative confidence
% bin, which is constrained to equal 1, and is also omitted from the
% output. 
%
% Required Input:
%   targc - A M x N matrix of cumulative confidence proportions for 
%   target trials. The order of proportions should be ascending such that
%   the first element is the smallest and the last element is the largest
%   proportion. The first element should be greater than or equal to 0 and
%   the last should be equal to 1. 
%
%   num_targ - A value indicating the number of target trials. 
%
%   lurec - A M x N matrix of cumulative confidence proportions for 
%   lure trials. The format of this is identical to targc.
%
%   num_lure - A value indicating the number of lure trials.
%
%   NOTE: targc and lurec must be the same length, else an error is 
%   retured.
%
% Format of output:
%
%   The output is structure variable containing frequencies, proportions, 
%   cumulative proportions, and z-scores. Below is the format of the 
%   structure variable:
%
%       target.frequency=[target_frequencies]
%       target.proportions=[target_raw_proportions]
%       target.cumulative=[target_cumulative_proportions]
%       target.zscores=[target_zscores]
%       lure.frequency=[lure_frequencies]
%       lure.proportions=[lure_raw_proportions]
%       lure.cumulative=[lure_cumulative proportions]
%       lure.zscores=[lure_zscores]
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

% Error check for numer of input arguments.
if nargin < 4
    error('Not enough inputs given to the function.')
end

% Error check for length of targc and lurec
if sum(size(targc) ~= size(lurec))>0
    error('Size of target and lure inputs are inconsistent.')
end

% Error check for length of num_targ and num_lure
if length(num_targ) ~= length(num_lure)
    error('Length of input for number of target and lure trials are not equal.')
end

% Error check for the number of rows in cumulative proportion and trials
% input.
if size(targc,1) ~= length(num_targ)
    error(['The number conditions for targc/lurec are inconsistent with '...
        'the number of conditions in the num_targ/num_lure'])
end

% Error check for out of range values. 
if sum(sum(targc>1)) > 0 || sum(sum(targc<0)) > 0 
    error(['A value in the cumulative proportion vector for target items',...
        ' is out of range (<0 or >1).'])    
elseif sum(sum(lurec>1)) > 0 || sum(sum(lurec<0)) > 0
    error(['A value in the cumulative proportion vector for lure items',...
        ' is out of range (<0 or >1).'])
end

% Preallocate variables
targp = zeros(size(targc));
lurep = zeros(size(targc));
targf = zeros(size(targc));
luref = zeros(size(targc));

% Calc predicted probabilites at each bin
for a = 1:size(targc,1)
    for b = 1:size(targc,2)
        if b == 1
            targp(a,b) = targc(a,b);
            lurep(a,b) = lurec(a,b);
        else
            targp(a,b) = targc(a,b) - targc(a,b-1);
            lurep(a,b) = lurec(a,b) - lurec(a,b-1);
        end
    end
    
    % Calculate predicted frequencies
    targf(a,:) = targp(a,:) * num_targ(a);
    luref(a,:) = lurep(a,:) * num_lure(a);
end

% Create structure variable output
rating_data = freq2zscores(targf,luref);
    
end
               
               
               
               
               
               
               
               