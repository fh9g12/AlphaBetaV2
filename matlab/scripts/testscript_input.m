function [res] = testscript_input(prompt)
%TESTSCRIPT_INPUT A function to return a numeric input for the user 
% during the operation of a testscript
% Created: Fintan Healy
% Contact: fintan.healy@bristol.ac.uk
% Date: 29/06/2020
res = [];
while(isempty(res))
    res = str2num(input(prompt,'s'));  
end    
end

