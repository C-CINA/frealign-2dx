#!/bin/csh -f

set starfile = $1
set parfile = $2

if ($1 == "" || $2 == "") then
  echo ""
  echo -n "Input Relion star file?"
  echo ""
  set starfile = $<
  echo $starfile
  echo ""
  echo -n "Output Frealign par file?"
  echo ""
  set parfile = $<
  echo $parfile
endif

set psi = `grep _rlnAnglePsi $starfile | awk -F\# '{print $2+1}'`
if ($psi == "") set psi = 0
set theta = `grep _rlnAngleTilt $starfile | awk -F\# '{print $2+1}'`
if ($theta == "") set theta = 0
set phi = `grep _rlnAngleRot $starfile | awk -F\# '{print $2+1}'`
if ($phi == "") set phi = 0
set y = `grep _rlnOriginY $starfile | awk -F\# '{print $2+1}'`
if ($y == "") set y = 0
set x = `grep _rlnOriginX $starfile | awk -F\# '{print $2+1}'`
if ($x == "") set x = 0
set mag = `grep "_rlnMagnification " $starfile | awk -F\# '{print $2+1}'`
if ($mag == "") then
  echo ""
  echo -n "Magnification at the detector?"
  echo ""
  set m = $<
  echo $m
endif
# set dstep = `grep "_rlnDetectorPixelSize " $starfile | awk -F\# '{print $2+1}'`
# if ($dstep == "") then
#  echo ""
#  echo -n "Detector pixel size?"
#  echo ""
#  set d = $<
#  echo $d
#endif
echo ""
echo -n "Pixel size in Angstrom?"
echo ""
set d = $<
echo $d
set image = `grep "_rlnGroupNumber " $starfile | awk -F\# '{print $2+1}'`
if ($image == "") set image = 0
set df1 = `grep "_rlnDefocusU " $starfile | awk -F\# '{print $2+1}'`
if ($df1 == "") then
  echo "ERROR: no defocus1 values found in star file."
  exit
endif
set df2 = `grep "_rlnDefocusV " $starfile | awk -F\# '{print $2+1}'`
if ($df1 == "") then
  echo "ERROR: no defocus2 values found in star file."
  exit
endif
set dang = `grep "_rlnDefocusAngle " $starfile | awk -F\# '{print $2+1}'`
if ($dang == "") then
  echo "ERROR: no astigmatic angle values found in star file."
  exit
endif

if ($mag == "") then
  grep "@" $starfile  | awk '{print 0.0,$0}' | awk '{printf "%7d%8.2f%8.2f%8.2f%10.2f%10.2f%8d%6d%9.1f%9.1f%8.2f%7.2f%11d%11.4f%8.2f%8.2f\n",NR,$'$psi',$'$theta',$'$phi',-'$d'*$'$x',-'$d'*$'$y','$m',$'$image',$'$df1',$'$df2',$'$dang',100.0,-500,1.0,20.0,0.0}' > $parfile
else
  grep "@" $starfile  | awk '{print 0.0,$0}' | awk '{printf "%7d%8.2f%8.2f%8.2f%10.2f%10.2f%8d%6d%9.1f%9.1f%8.2f%7.2f%11d%11.4f%8.2f%8.2f\n",NR,$'$psi',$'$theta',$'$phi',-'$d'*$'$x',-'$d'*$'$y',$'$mag',$'$image',$'$df1',$'$df2',$'$dang',100.0,-500,1.0,20.0,0.0}' > $parfile
endif
#
echo ""
