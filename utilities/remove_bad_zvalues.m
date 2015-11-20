function cleaned_zscores = remove_bad_zvalues(targz,lurez)
% usage: 
%   cleaned_zscores = remove_bad_zvalues(targz,lurez)
%
% REMOVE_BAD_ZVALUES removes Inf and NaN values from the z-score vector. 
% This is mainly to be used to be able to calculate z-ROC measures like 
% slope and intercept. 
%
% Rquired Input:
%   targz - M x N matrix of observed target z-scores for each rating 
%   bin. The order of confidence ratings should be in descending order 
%   from the first element to the last. That is, the highest rating that 
%   can be given to a target item should be in the first element and the 
%   highest rating that can be given to a lure should be the last element.
%   For example, a six point scale with a '6-sure target' and '1-sure lure'
%   responses should be entered in the order [6s 5s 4s 3s 2s 1s]. The
%   number of rows indicates the number of conditions. 
%
%   lurez - M x N matrix observed lure z-scores for each rating 
%   bin. The input is identical in form to targf.
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
if nargin<2
    error('Not enough inputs given to the function.')
end

% Check for input mismatch in frequency vectors.
if sum(size(targz,2)~=size(lurez,2))>0
    error('Size of target and lure inputs are inconsistent.')
end

% Remove Inf/-Inf z-values
for a=size(targz,2):-1:1    
    if isinf(targz(a)) || isnan(targz(a)) || isinf(lurez(a)) || isnan(lurez(a))
        targz(a)=[];
        lurez(a)=[];
    end    
end

% Create output variable
cleaned_zscores.target=targz;
cleaned_zscores.lure=lurez;

end