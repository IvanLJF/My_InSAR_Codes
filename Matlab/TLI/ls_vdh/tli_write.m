function tli_write(outputfile, data, precision)
% write data into the specified outputfile.
if nargin <3, precision='double'; end
fid=fopen(outputfile, 'w');
fwrite(fid, data,precision);
fclose(fid);