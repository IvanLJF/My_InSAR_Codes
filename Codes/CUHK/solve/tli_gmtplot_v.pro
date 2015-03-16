PRO TLI_GMTPLOT_V
  workpath=SOURCEROOT()
  shell_plot= workpath+'plot_linear_defo.sh'
  arg1='a'
  arg2='b'
  
  command_line= shell_plot+' '+arg1
  SPAWN, [shell_plot, arg1, arg2]

END