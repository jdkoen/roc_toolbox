function roc_startup
% Usage:
%   roc_startup()
%
% This function adds the directories of ROC Toolbox to your path variable.
% 
% You can add the following lines to your startup.m file to automatically
% load ROC Toolbox every time you start Matlab:
% 
% addpath('/path/to/roc_toolbox');
% roc_startup;
% 
% Your startup.m is usually found in the following places:
% 
%   MAC OS X: /Users/<yourusername>/Documents/MATLAB/startup.m
%   Linux: /home/<yourusername>/matlab/startup.m
%   Windows: C:\Users\<yourusername>Documents
% 
% If no 'startup.m' exists at these places, you are free to create it. If
% this does not work, please refer to Matlab documentation for your verison
% and system to learn more about your startup.m file.
% 
% Authored by: Fred Barrett

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

%fprintf(1,'roc_startup: adding ROC Toolbox paths ...\n');
roc_path = fileparts(which('roc_startup'));

% add all files and directories in the ROC Toolbox
path(path,genpath(roc_path));
