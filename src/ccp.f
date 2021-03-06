C*
C* Copyright 2013 Howard Hughes Medical Institute.
C* All rights reserved.
C* Use is subject to Janelia Farm Research Campus Software Copyright 1.1
C* license terms ( http://license.janelia.org/license/jfrc_copyright_1_1.html )
C*
C**************************************************************************
      SUBROUTINE CCP(NSAM,IRAD,AMAG,SPEC,A3DF,RBUF,DANGIN,
     +			 MAXR1,MAXR2,PHI,THETA,PSI,SHX,SHY,CCMAX,
     +			 CCD,CCC,CBUF,IQUAD,MASK,
     +                   SINCLUT,IPAD,IEWALD,THETATR,CTFF,
     +                   RI2,RI3,RIH,HALFW,IQUADMAX,FFTW_PLANS,SM)
C**************************************************************************
C  Calculates cross-correlation between projected 3D model and experimental 
C    particle image :- used in PSEARCH
C  Calls FFTW and uses function AINTERPO3DS or AINTERPO3DBIG.
C  Used in PSEARCH.
C  MW uses function EWALDEX if IEWALD is true
C**************************************************************************
C
      USE ISO_C_BINDING
      USE FFTW33
C
      IMPLICIT NONE

      INTEGER NSAM,JC,I,J,II,JJ,MAXR1,MAXR2,IRAD,NSAMH,ID,MAXR12
      INTEGER MAXR22,ITEMP,IX,IY,IQUAD,IDD,ICON,III,JJJ,MASK(5)
      INTEGER IPAD,IC,IQUADMAX,NPSI,IPSI,IPAD2,NP,IQ,NSAMRH
      INTEGER ID2,JJ2,IXM,IYM,NSAMR,JCR
      REAL DM(9),PHI,THETA,PSI,CPHI,SPHI,CTHE,STHE,CPSI,SPSI
      REAL PHASE,X3,Y3,Z3,SHX,SHY,PI,SUM,SUM2,SM(9)
      REAL AMAG,CC,CCD(*),CCMAX,SINCLUT(*),RI2,RI3,RIH,HALFW
      REAL PSIS,RBUF(*),CCM,SX,SY,PSIM,DANGIN,DANG
      PARAMETER  (PI=3.1415926535897,IPAD2=4)
      COMPLEX SAMP,SPEC(*),PSHFT,AINPO,CCC(*)
      COMPLEX A3DF(*),AINTERPO3DBIG,AINTERPO3DS,CBUF(*)
C MW for Ewald sphere corrected extraction
      COMPLEX EWALDEX,CTFF(*),CTFR,CTFL
      INTEGER IEWALD
      REAL THETATR         ! needed by function EWALDEX
      TYPE(C_PTR) FFTW_PLANS(*)
C**************************************************************************
C      	write(*,19) PHI,THETA,PSI,SHX,SHY,AMAG
19	format(' Entering CCP with PHI,THETA,PSI,SHX,SHY,AMAG',6F5.1)
C      SCAL=1.0/NSAM/NSAM
      JC=NSAM/2+1
      IC=NSAM*(NSAM+2)/2
      NSAMH=NSAM/2
      NSAMRH=NSAMH/2
      IF (2*NSAMRH.NE.NSAMH) NSAMRH=(NSAMH+1)/2
      JCR=NSAMRH+1
      NSAMR=2*NSAMRH
      MAXR12=MAXR1**2
      MAXR22=MAXR2**2
      CPHI=COS(PHI)
      SPHI=SIN(PHI)
      CTHE=COS(THETA)
      STHE=SIN(THETA)
      CPSI=COS(PSI)
      SPSI=SIN(PSI)
C
      DANG=0.25
      IF(DANGIN.NE.0.0) DANG=DANGIN
      NPSI=NINT(90.0/DANG)
C
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C To save time, 90 deg rotated projections are generated by index permutation...
C  i.e. the projection structure factors are interpolated only for IQUAD=1
C       then recalled from CBUF for the 3 other rotated projections
C
C PSI=		 0  90 180 270
C D1=CPSI=	 1   0  -1   0
C D2=SPSI=	 0   1   0  -1
C D3=0.0
C D4=-SPSI=	 0  -1   0   1
C D5=CPSI=	 1   0  -1   0
C D6=0.0
C X=		 I  -J  -I   J
C Y=		 J   I  -J  -I
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C  Below is the standard Eulerian rotation ZYZ
C    The model or its transform is rotated first by PHI around Z, then 
C    by THETA about the new Y, and thirdly by PSI about the new Z.
C
C    The rotation matrix used is  R=R(psi)*R(theta)*R(phi) as in Spider
C
C                 c  s  0          c  0 -s          c  s  0
C                -s  c  0     *    0  1  0     *   -s  c  0
C                 0  0  1          s  0  c          0  0  1
C
C                 about Z          about Y          about Z
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      DM(1)=(CPHI*CTHE*CPSI-SPHI*SPSI)/ABS(AMAG)
      DM(2)=(SPHI*CTHE*CPSI+CPHI*SPSI)/ABS(AMAG)
      DM(3)=-STHE*CPSI/ABS(AMAG)
      DM(4)=(-CPHI*CTHE*SPSI-SPHI*CPSI)/ABS(AMAG)
      DM(5)=(-SPHI*CTHE*SPSI+CPHI*CPSI)/ABS(AMAG)
      DM(6)=STHE*SPSI/ABS(AMAG)
C MW next lines uncommented for Ewald sphere correction
      DM(7)=STHE*CPHI/ABS(AMAG)
      DM(8)=STHE*SPHI/ABS(AMAG)
      DM(9)=CTHE/ABS(AMAG)
      CALL MATMUL_T(DM,SM,DM)
C
      DO 52 I=1,NSAM*JC
        CCC(I)=CMPLX(0.0,0.0)
52    CONTINUE
      DO 30 I=0,JC-2
      	II=I+1
      	DO 30 J=-JC+1,JC-1
      	  ITEMP=I**2+J**2
      	  JJ=J+1
      	  IF (JJ.LT.1) JJ=JJ+NSAM
      	  ID=II+JC*(JJ-1)
          IF ((ITEMP.GE.MAXR12).AND.(ITEMP.LT.MAXR22)
     +			       .AND.(ABS(J).NE.JC-1)) THEN
            CTFR=CTFF(ID)
            CTFL=CTFF(ID+IC)
      	      X3=DM(1)*I+DM(4)*J
      	      Y3=DM(2)*I+DM(5)*J
      	      Z3=DM(3)*I+DM(6)*J
              IF (IRAD.EQ.0) THEN
                CCC(ID)=AINTERPO3DBIG(NSAM,IPAD,A3DF,
     +                     X3,Y3,Z3)
              ELSE
                CCC(ID)=AINTERPO3DS(IPAD*NSAM,IRAD,A3DF,
     +                     X3,Y3,Z3,SINCLUT,IPAD)
              ENDIF
              CCC(ID)=CCC(ID)*(CTFR+CONJG(CTFL))
          ENDIF
30    CONTINUE
cc      CALL FFTW_BWD(CCC,CCC,FFTW_PLANS(2))
cc      CALL MASKCOS2(NSAM,CCC,RI2,RI3,RIH,HALFW,AMAG)
cc      CALL FFTW_FWD(CCC,CCC,FFTW_PLANS(1))
C
      CCMAX=-1E30
      NP=NPSI
      IQ=IQUADMAX
      IF (MASK(3).EQ.0) THEN
        NP=1
        IQ=1
      ENDIF
C
      DO 99 IPSI=1,NP
C
      PSIS=(IPSI-1)*PI/2.0/NPSI
      IF (IPSI.EQ.1) THEN
        CALL ROTATE2D(NSAM,-IPAD2,CCC,CBUF,PSIS,RBUF,
     +                FFTW_PLANS)
      ELSE
        CALL ROTATE2D(NSAM,IPAD2,CCC,CBUF,PSIS,RBUF,
     +                FFTW_PLANS)
      ENDIF
C
      DO 10 IQUAD=1,IQ
C
        SUM=0.0
        SUM2=0.0
C
        DO 31 I=0,NSAMRH
      	  II=I+1
      	  DO 31 J=-NSAMRH,NSAMRH-1
      	    ITEMP=I**2+J**2
      	    JJ=J+1
      	    JJ2=JJ
      	    IF (JJ.LT.1) THEN
              JJ=JJ+NSAM
              JJ2=JJ2+NSAMR
            ENDIF
      	    ID=II+JC*(JJ-1)
            ID2=II+JCR*(JJ2-1)
c            IF ((ITEMP.GE.MAXR12).AND.(ITEMP.LT.MAXR22)
            IF ((ITEMP.GE.1).AND.(ITEMP.LT.MAXR22)
     +			       .AND.(ABS(J).NE.JC-1)) THEN
      	      IF (IQUAD.EQ.1) THEN
      	        AINPO=CBUF(ID)
      	      ELSE
      	        IF (IQUAD.EQ.2) THEN
      		  IF (J.LE.0) THEN
      		    III=-J+1
      		    JJJ=I+1
      		    ICON=1
      		  ELSE
      		    III=J+1
      		    JJJ=-I+1
      		    IF (JJJ.LT.1) JJJ=JJJ+NSAM
      		    ICON=-1
      		  ENDIF
      	        ELSEIF (IQUAD.EQ.3) THEN
      		  III=I+1
      		  JJJ=J+1
      		  IF (JJJ.LT.1) JJJ=JJJ+NSAM
      		  ICON=-1
      	        ELSEIF (IQUAD.EQ.4) THEN
      		  IF (J.GT.0) THEN
      		    III=J+1
      		    JJJ=-I+1
      		    IF (JJJ.LT.1) JJJ=JJJ+NSAM
      		    ICON=1
      		  ELSE
      		    III=-J+1
      		    JJJ=I+1
      		    ICON=-1
      		  ENDIF
      	        ENDIF
      	        IDD=III+JC*(JJJ-1)
      	        AINPO=CBUF(IDD)
      	        IF (ICON.EQ.-1) AINPO=CONJG(AINPO)
      	      ENDIF
C              PHASE=SHX*I+SHY*J
C              PSHFT=CMPLX(COS(PHASE),SIN(PHASE))
C      	       SAMP=SPEC(ID)*PSHFT
      	      SAMP=SPEC(ID)
      	      CCC(ID2)=SAMP*CONJG(AINPO)
      	      SUM=SUM+CABS(AINPO)**2
      	      SUM2=SUM2+CABS(SAMP)**2
      	    ELSE
      	      CCC(ID2)=CMPLX(0.0,0.0)
            ENDIF
31      CONTINUE
C
        CALL FFTW_BWD(CCC,CCC,FFTW_PLANS(8))
        CCM=-1E30
C cross-correlation is searched in (x,y) unless MASK is zero
        IXM=0
        IYM=0
C   Assume that particle is roughly centered: search only over NSAM/2
C   in each direction
        DO 40 IX=-6*MASK(4),6*MASK(4)
          J=IX+1
          IF (J.LT.1) J=J+NSAMR
          DO 40 IY=-6*MASK(5),6*MASK(5)
            I=IY+1
            IF (I.LT.1) I=I+NSAMR
            ID=J+(NSAMR+2)*(I-1)
            IF (CCD(ID).GT.CCM) THEN
              CCM=CCD(ID)
              IXM=IX
              IYM=IY
            ENDIF
40      CONTINUE
        CCM=0.0
        DO 41 IX=IXM-1,IXM+1
          J=IX+1
          IF (J.LT.1) J=J+NSAMR
          DO 41 IY=IYM-1,IYM+1
            I=IY+1
            IF (I.LT.1) I=I+NSAMR
            ID=J+(NSAMR+2)*(I-1)
            CCM=CCM+CCD(ID)
41      CONTINUE
        CC=CCM/SQRT(SUM)/SQRT(SUM2)/9
C        CC=CCM/SQRT(SUM)/SQRT(SUM2)
C
        IF (CC.GT.CCMAX) THEN
          SX=REAL(IXM)/NSAMR*PI*2.0
          SY=REAL(IYM)/NSAMR*PI*2.0
          PSIM=PSI+(IQUAD-1)*PI/2.0+PSIS
          CCMAX=CC
        ENDIF
C
10    CONTINUE
C
99    CONTINUE
C
      SHX=SX
      SHY=SY
      PSI=PSIM
c      print *,shx,shy,psi,ccmax
C
C      write(*,1000) CCMAX,SUM,SUM2
1000	format(' Leaving CCP with CCMAX,SUM,SUM2',3F20.1)
C
      RETURN
      END
