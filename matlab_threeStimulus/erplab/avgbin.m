% - This function is part of ERPLAB Toolbox -
%
% Usage
% >> waverage = avgbin(ERP, bop)
%
% For Bin Operations GUI/scripting purposes
%
% Author: Javier
%

function  average = avgbin(ERP, bop)

if nargin<1
        help avgbin
        return
end
if nargin<2
        error('ERPLAB says:  error at avgbin(). You must specify bin indexes to be averaged!')
end
if ~iserpstruct(ERP)
        error('ERPLAB says:  error at avgbin(). Your data structure is not an ERP structure!')
end
if ischar(bop)
        bop = str2num(char(regexp(bop,'\d+','match')'))';
end
binarray = unique(bop);
if length(binarray)~=length(bop)
        fprintf('\n*** WARNING: Repeated bins were ignored.\n\n')
end
if length(binarray)<2
        error('ERPLAB says:  error at avgbin(). You must specify 2 bin indexes at leat!')
end
if max(binarray)>ERP.nbin
        error('ERPLAB says:  error at avgbin(). Some specified bins do not exist!')
end

datavg  = ERP.bindata(:,:,binarray);
average = mean(datavg, 3);

