FUNCTION STRECH,x
maxi=max(max(x))
mini=min(min(x))
x=255*(x-mini)/(maxi-mini)
return,x
END
