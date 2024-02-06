function [res] = testscript_input_empty(prompt,default)
%TESTSCRIPT_INPUT A function to return a numeric input for the user
% during the operation of a testscript
% Created: Fintan Healy
% Contact: fintan.healy@bristol.ac.uk
% Date: 29/06/2020
res = input([prompt,sprintf(' (empty for %.0f)\n',default)],'s');
if isempty(res)
    res = default;
else
    res = str2double(res);
end
end

