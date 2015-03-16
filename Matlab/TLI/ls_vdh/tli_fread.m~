function data = tli_fread(inputfile, samples , format, machineformat,issamples)
% tli_fread : Read binary files from the given input file.

if (nargin < 4)
    error('Usage Error:[dat, count] = tli_fread(inputfile, samples, format, machineformat)')
end;

a=exist(inputfile,'file');
if (a == 0)
    error('ERROR: File not exist!')
end;

fid=fopen(inputfile,'r',machineformat);

% Get the element size of the input file.
switch lower(format)
    case {'int'}
        ele_size=2;
    case {'float'}
        ele_size=4;
    case {'double'}
        ele_size=8;
    case {'scomplex'}
        ele_size=4;
    case {'fcomplex'}
        ele_size=8;
    otherwise
        disp('Unknown data format');
end

% calculate the samples and lines
finfo=dir(inputfile);
filesize=finfo.bytes;
if (issamples == 1)
    lines=filesize/samples/ele_size;
else
    lines=samples;
    samples=filesize/lines/ele_size;
end

% Read the data.
data=fread(fid, [lines, samples],format);
fclose(fid);