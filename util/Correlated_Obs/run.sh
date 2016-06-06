#!/bin/sh
#date of first radstat file
bdate=2014040700
#date of last radstat file
edate=2014041218
#instrument name, as it would appear in the title of a diag file
instr=iasi_metop-b
#location of radstat file
exp=prcorrctl
diagdir=/scratch4/NCEPDEV/da/noscrub/${USER}/archive/${exp}
#working directory
wrkdir=/scratch4/NCEPDEV/stmp4/${USER}/iasi
#location the covariance matrix is saved to
savdir=$wrkdir
#type- 0 for all, 1 for sea, 2 for land, 3 for ice, 4 for snow, 5 for ice, snow, land and mixed FOVs
type=1
#cloud 1 for clear FOVs, 2 for clear channels
cloud=2
#absolute value of the maximum allowable sensor zenith angle (degrees)
angle=30
#option to output the channel wavenumbers
wave_out=.true.
#option to output the assigned observation errors
err_out=.true.
#option to output the correlation matrix
corr_out=.false.
#condition number to recondition Rcov.  Set <0 to not recondition
kreq=-60
ndate=/da/save/Kristen.Bathmann/anl_tools/ndate
####################

cdate=$bdate
[ ! -d ${wrkdir} ] && mkdir ${wrkdir}
[ ! -d ${savdir} ] && mkdir ${savdir}
cp cov_calc $wrkdir
nt=0
cd $wrkdir
while [[ $cdate -le $edate ]] ; do
   while [[ ! -f $diagdir/radstat.gdas.$cdate ]] ; do 
     cdate=`$ndate +06 $cdate`
     if [ $cdate -gt $edate ] ; then
        break
     fi
   done
   nt=`expr $nt + 1`
   if [ $nt -lt 10 ] ; then
      fon=000$nt
   elif [ $nt -lt 100 ] ; then
      fon=00$nt
   elif [ $nt -lt 1000 ] ; then
      fon=0$nt
   else
      fon=$nt
   fi
   if [ ! -f danl_${fon} ];
   then
      cp $diagdir/radstat.gdas.$cdate .
      tar --extract --file=radstat.gdas.${cdate} diag_${instr}_ges.${cdate}.gz diag_${instr}_anl.${cdate}.gz
      gunzip *.gz
      rm radstat.gdas.$cdate
      if [ -f diag_${instr}_ges.${cdate} ];
      then
         mv diag_${instr}_anl.${cdate} danl_${fon}
         mv diag_${instr}_ges.${cdate} dges_${fon}
      else
         nt=`expr $nt - 1`
      fi
   fi
   cdate=`$ndate +06 $cdate`
done
./cov_calc <<EOF
$nt $type $cloud $angle $instr $wave_out $err_out $corr_out $kreq
EOF

cp Rcov_$instr $savdir

[ -f Rcorr_$instr ] && cp Rcorr_$instr $savdir
[ -f wave_$instr ] && cp wave_$instr $savdir
[ -f err_$instr ] && cp err_$instr $savdir
