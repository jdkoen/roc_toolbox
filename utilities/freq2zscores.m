function rating_data = freq2zscores(targf,luref)
% Usage: 
%   rating_data = freq2zscores(targf,luref)
%
% FREQ2ZSCORES converts frequencies from ratings experiments to raw
% proportions, cumulative proportions, and z-scores.
%
% Cumulative proportions of 0 and 1 cause z-scores to be estimated as
% -Inf and +Inf, respectively. Such values are omitted from the output when
% this occurs. Additionally, the last element of the cumulative confidence
% bin, which is constrained to equal 1, and is also omitted from the
% output. 
%
% Required Input:
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
%   IMPORTANT: Do not exclude confidence bins that were never used, as this 
%   will create inconsistencies in the data.
% 
%   NOTE: All vectors must be the same size, else an error is retured.
%   Thus, each condition must hvae unique target and lure trials.
%
% Output:
%   The output is structure variable containing frequencies, proportions, 
%   cumulative proportions, and z-scores. The data for each condition are
%   reported as seperate rows in the structure variables, similar to how
%   multiple conditions are input into this function. Below is the form of 
%   the structure variable:
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

% Check for errors in the number of input arguments. 
if nargin < 2
    error('Not enough inputs given to the function.')
end

% Check for input mismatch in frequency vectors.
if sum(size(targf) ~= size(luref)) > 0
    error('Size of target and lure inputs are inconsistent.')
end

% Preallocate Variables
targp = zeros(size(targf));
lurep = zeros(size(targf));
targc = zeros(size(targf));
lurec = zeros(size(targf));

% Calculate raw and cumulative proportions
for a = 1:size(targf,1)
    % Raw proportions
    targp(a,:) = targf(a,:) ./ sum(targf(a,:));
    lurep(a,:) = luref(a,:) ./ sum(luref(a,:));

    % Cumulative proportions
    targc(a,:) = cumsum(targf(a,:)) ./ sum(targf(a,:));
    lurec(a,:) = cumsum(luref(a,:)) ./ sum(luref(a,:));
end

% Convert cumulative proportions to z-Scores, and remove the cumulative
% proportino equal to 1.
targz = norminv(targc(:,1:size(targf,2)-1));
lurez = norminv(lurec(:,1:size(targf,2)-1));

% Create structure variable output
rating_data.target.frequency = targf;
rating_data.target.proportions = targp;
rating_data.target.cumulative = targc;
rating_data.lure.frequency = luref;
rating_data.lure.proportions = lurep;
rating_data.lure.cumulative = lurec;
rating_data.target.zscores = targz;
rating_data.lure.zscores = lurez;

end
