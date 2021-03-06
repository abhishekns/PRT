function output = prtEmlClassLogisticDiscriminantRun(inputX,prtEmlLogisticDiscriminantStruct)
% output = prtEmlClassLogisticDiscriminantRun(inputX,prtEmlLogisticDiscriminantStruct)
% 
%   As a prtEml*Run function, prtEmlClassLogisticDiscriminantRun takes
%   individual vectors of features and outputs scalar values corresponding
%   to the class estimates of the classifier.  The classifier structure
%   should be the second input.  Note that the second input is not a
%   prtClass object.

% Copyright (c) 2014 CoVar Applied Technologies
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.





%#eml

internalX = cat(1,1,inputX(:));
outX = prtEmlLogisticDiscriminantStruct.w'*internalX;
output = 1./(1 + exp(-outX));
