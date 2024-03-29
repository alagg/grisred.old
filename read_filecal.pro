pro read_filecal,filecal,beam_up,beam_down,time=timecal,date=datecal,$
pzero=pzero,lambda=lambda,luzin=luzin

if(keyword_set(pzero) eq 0 or pzero eq -999.) then pzero=-1.2

print,filecal

dc=rfits_im(filecal,1,dd,hdr,nrhdr,/badpix)>0
for j=2,8 do dc=dc+rfits_im(filecal,j,dd,/badpix)>0
dc=dc/8.
npos=(dd.naxis3-8)/4
im0=(rfits_im(filecal,9,dd,/badpix)-dc)>0
im1=(rfits_im(filecal,10,dd,/badpix)-dc)>0
im2=(rfits_im(filecal,11,dd,/badpix)-dc)>0
im3=(rfits_im(filecal,12,dd,/badpix)-dc)>0


cal_type=param_fits(hdr,'MEASURE =')
pos_tel=strpos(cal_type,'telescope')
pos_ins=strpos(cal_type,'instrumental')

if(pos_tel eq -1 and pos_ins ne -1) then begin	; instrumental calibration
   thpol=param_fits(hdr,'INSPOLAR=',vartype=3)+pzero
   thret=param_fits(hdr,'INSRETAR=',vartype=3)

   delta=-409.288 + 786.267e4/lambda

endif else if (pos_tel ne -1 and pos_ins eq -1) then begin	; telescope calibration
   thpol=param_fits(hdr,'TELPOLAR=',vartype=3)+pzero
   thret=param_fits(hdr,'TELRETAR=',vartype=3)

   lamref=[10830.,10938.,12818.,15000.,15650.,16000.,16500.,17000.,17500.]
   deltaref=[88.8,91.1,90.7,86.8,85.7-1.5,83.1,81.0,79.5,76.8]
   coef=poly_fit(lamref[1:*],deltaref[1:*],2)
   delta=poly(lambda,coef)
endif else begin
   print,'unknown calibration file. Please check!
   stop
endelse

imref=im0+im1+im2+im3
data=get_limits(imref,lambda,/silent)

beam_up=fltarr(4,npos)
beam_down=fltarr(4,npos)

beam_up[0,0]=mean(im0[data[0]:data[1],data[2]:data[3]])
beam_up[1,0]=mean(im1[data[0]:data[1],data[2]:data[3]])
beam_up[2,0]=mean(im2[data[0]:data[1],data[2]:data[3]])
beam_up[3,0]=mean(im3[data[0]:data[1],data[2]:data[3]])

beam_down[0,0]=mean(im0[data[4]:data[5],data[6]:data[7]])
beam_down[1,0]=mean(im1[data[4]:data[5],data[6]:data[7]])
beam_down[2,0]=mean(im2[data[4]:data[5],data[6]:data[7]])
beam_down[3,0]=mean(im3[data[4]:data[5],data[6]:data[7]])

format=['(i2,$)','(i3,$)','(i4,$)','(i5,$)','(i6,$)']

for j=1,npos-1 do begin
   if((j+1 MOD 10) eq 0) then print,j+1,format=format(fix(alog10(j+1)))
   for k=0,3 do begin
      im=(rfits_im(filecal,4*j+k+9,dd,/badpix)-dc)>0
      beam_up[k,j]=mean(im[data[0]:data[1],data[2]:data[3]])
      beam_down[k,j]=mean(im[data[4]:data[5],data[6]:data[7]])
   endfor
end

thpol=param_fits(hdr,'TELPOLAR=',vartype=3)+pzero
thret=param_fits(hdr,'TELRETAR=',vartype=3)

timecal=param_fits(hdr,'UT      =',delimiter=':',vartype=1) 
timecal=timecal[*,0]+(timecal[*,1]+timecal[*,2]/60.)/60.
timecal=mean(timecal)

datecal=reform(param_fits(hdr,'DATE-OBS=',delimiter='-',vartype=1))

luzin=fltarr(4,npos)
uno=[1,0,0,0]

q=0
for j=0,npos-1 do begin
   luzin[*,j]=retarder(thret[j],delta)#impolariz2(q,thpol[j])#uno
endfor   

return
end

