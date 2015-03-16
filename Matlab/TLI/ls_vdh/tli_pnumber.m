function npt=tli_pnumber(plistfile)
% Calculate the number of point for input file: plistfile.

finfo=dir(plistfile);
filesize=finfo.bytes;
npt=filesize/8;