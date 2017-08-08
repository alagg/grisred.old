;returns min and max of an array without NAN, but throws away values
;outside the percentage value
function minmaxp,array,percent=percent,nan=nan,index=idx
  
  
  if n_elements(percent) eq 0 then begin
    mm=[min(array,nan=nan,subscript=imin),max(array,nan=nan,subscript=imax)]
  endif else begin
    idx=[0,0]
    val=where(finite(array) eq 1)
    if val(0) eq -1 then return,!values.f_nan+[0,0]
    afin=array[val]
    afin=afin(sort(afin))
    nel=n_elements(afin)
    n0=percent/100.*(nel)
    n1=(100-percent)/100.*(nel-1)
    
    n0=(n0>0)<(nel-1)
    n1=(n1>0)<(nel-1)
    
;  mima=[min(afin),max(afin)]
    mm=[afin(n0),afin(n1)]
    
    mm=[min(mm,nan=nan,subscript=imin),max(mm,nan=nan,subscript=imax)]
  endelse
  idx=[imin,imax]
  return,mm
end
