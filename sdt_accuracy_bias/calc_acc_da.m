function da = calc_acc_da(targf,luref)
% Usage: 
%   da = calc_acc_da(targf,luref)
%
% CALC_ACC_DA calculates the discrimination index da. This measure is
% based on the slope of the z-transformed ROC, which is estimated with 
% linear regression. 
%
% If there are an odd number (e.g., 7) of confidence bins, the hit rate 
% (HR) and false alarm rate (FAR) do not include the middle point. For 
% example the HR and FAR are based on the 7, 6, and 5 ratings if using
% a 7-point rating scale. This occurs because calculation of da requires
% using the HR and FAR. 
%
% Also, If the HR and/or FAR is equal to 0 or 1, the z-score will be -Inf
% or +Inf, respectively, and will cause da to equal -Inf/Inf.
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
if sum(size(targf)~=size(luref))>0
    error('Size of target and lure inputs are inconsistent.')
end

% Calculate z-scores
temp=freq2zscores(targf,luref);

% Preallocate variables
da=zeros(size(targf,1),1);

for a=1:size(targf,1)
    % Remove Inf/NaN values from zscores
    cleaned_zscores=remove_bad_zvalues(temp.target.zscores(a,:),...
        temp.lure.zscores(a,:));
    
    % Check for adequate number of points (>= 2). If < 2, return NaN
    if length(cleaned_zscores.target)<2
        da(a) = NaN;
    else
        % Calculate slope and intercept of the zROC
        zroc=polyfit(cleaned_zscores.lure,cleaned_zscores.target,1);

        % Calculate hit rate and false alarm rate.
        HR=temp.target.cumulative(a,floor(size(temp.target.cumulative,2)/2));
        FAR=temp.lure.cumulative(a,floor(size(temp.lure.cumulative,2)/2));

        % Calculate da
        da(a)=sqrt(2/(1+zroc(1)^2))*(norminv(HR)-(zroc(1)*norminv(FAR)));
    end
end