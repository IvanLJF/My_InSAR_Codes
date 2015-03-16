pro test_batch_dtree
	compile_opt idl2

	;Supply existing decision tree text file
	tree_file = 'c:\decision_tree_ndvi_slope.txt'

	;Open relevant image files
	ndvi_file = 'c:\rsi\idl63\products\envi43\data\bhtmref.img'
	slope_file = 'c:\rsi\idl63\products\envi43\data\bhdemsub.img'
	envi_open_file, ndvi_file, r_fid = ndvi_fid
	envi_open_file, slope_file, r_fid = slope_fid

	;Build arrays of tree variables, input file ids, and band positions
	;Order is crucial.  The first file id and band position array are tied to the first variable, and so on....
	;Band positions for each file, as listed in the decision tree text file under "file pos", are 1-based.  Input to this routine is zero-based, so
	;be sure to account for that.  Example:  file pos = 4,3 -> pos = [3,2].  Because the number of bands can vary for each variable, they
	;must be stored in a structure variable.
	var_names = ['ndvi','slope']
	in_fids = [ndvi_fid, slope_fid]
	pos_struct = {ndvi:[3,2], slope:[0]}

	;Specify an output filename
	out_file = 'C:\batch_dt_test.img'

	;Specify which input image to use as the base, along with the spatial dimensions to operate on
	base_fid = ndvi_fid
	envi_file_query, base_fid, dims=base_dims

	;Specify an interpolation method for resizing the imagery involved.  Required, even if not used in the decision process.
	;Options are:
	;
	;0 - Nearest Neighbor
	;1 - Bilinear
	;2 - Cubic Convolution
	;
	;0 is always the safest option.  If interpolation isn't required, the specified value is ignored.
	interp = 2

	;Call the batch routine.  Result should show up in the ABL
	batch_decision_tree, tree_file=tree_file, in_fids=in_fids, pos_struct=pos_struct, var_names=var_names, out_file=out_file, $
		base_fid=base_fid, base_dims=base_dims, interp=interp, r_fid=r_fid

end