% PS探测的相关函数
% Contents of PS-related functions


function [K, RowCols, ADIs, Mean_Amp, Std_Amp] = PS_Detection(Filename1);    
                                                % detect permannent scatters (PS) from a number of SLC SAR images
                                                % Filename1: a text file containing file names of all SLC SAR images 
function TRI_PS = PS_TIN(RowCols);
                                                % form a  triangular irregular network with all permannent scatters
function Phi = Phase_Extraction(Filename2, RowCols);
                                                % extract phase data at permannent scatters from differential interferograms
                                                % Filename2: a text file containing file names of all differential interferograms 
function hdhdhhf  