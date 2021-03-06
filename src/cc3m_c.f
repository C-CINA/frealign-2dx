C*
C* Copyright 2013 Howard Hughes Medical Institute.
C* All rights reserved.
C* Use is subject to Janelia Farm Research Campus Software Copyright 1.1
C* license terms ( http://license.janelia.org/license/jfrc_copyright_1_1.html )
C*
C**************************************************************************
      REAL FUNCTION CC3M_C(NSAM,IRAD,AMAG,SPEC,A3DF,
     +			 MAXR1,MAXR2,PHI,THETA,PSI,SHX,SHY,IBUF,
     +			 PBUC,RBFACT,SINCLUT,IPAD,RBUF,FSCT,
     +                   IEWALD,THETATR,CTFF,RI2,RI3,RIH,
     +                   HALFW,PWEIGHTS,FFTW_PLANS,SM)
C**************************************************************************
C  Calculates overall score, used to search and refine all parameters
C  Score is SNR weighted so that data near CTF zero does not 
C  affect orientation parameters - similar function is available unweighted.
C  Uses functions PDIFF and AINTERPO3DS or AINTERPO3DBIG.
C  Used in CALCFX, PREFINE and PSEARCH
C**************************************************************************
C
      USE ISO_C_BINDING
      USE FFTW33
C
      IMPLICIT NONE

      INTEGER NSAM,JC,I,J,II,JJ,MAXR1,MAXR2,IRAD,ID,MAXR12
      INTEGER MAXR22,ITEMP,IBUF,IPAD,IBIN,IB1,IB2,IB,IC
      REAL DM(9),PHI,THETA,PSI,CPHI,SPHI,CTHE,STHE,CPSI,SPSI
      REAL PHASE,X3,Y3,Z3,DPHA,SHX,SHY,PDIFF,FSCT(*),W,SNRP
      REAL WGT,AMAG,PI2,RBFACT,SINCLUT(*),RBUF(*),SNRV,R,SCAL
      REAL RI2,RI3,RIH,HALFW,PWEIGHTS(*),SM(9)
      DOUBLE PRECISION SUM1,SUM2,SUM3
      PARAMETER  (PI2=3.1415926535897/2.0)
      COMPLEX SAMP,SPEC(*),PSHFT,AINPO,AINTERPO3DS
      COMPLEX A3DF(*),AINTERPO3DBIG,PBUC(*)
C MW for Ewald sphere corrected extraction
      COMPLEX EWALDEX,CTFF(*),CTFR,CTFL
      INTEGER IEWALD
      REAL THETATR         ! needed by function EWALDEX
      TYPE(C_PTR) FFTW_PLANS(*)
C**************************************************************************
      JC=NSAM/2+1
      IC=NSAM*JC
C      NSAMH=NSAM/2
      W=1.0/REAL(NSAM)
      MAXR12=MAXR1**2
      MAXR22=MAXR2**2
      CPHI=COS(PHI)
      SPHI=SIN(PHI)
      CTHE=COS(THETA)
      STHE=SIN(THETA)
      CPSI=COS(PSI)
      SPSI=SIN(PSI)

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
      DO 20 I=1,4*NSAM/2+NSAM*NSAM+4*NSAM
        RBUF(I)=0.0
20    CONTINUE
      IB1=4*NSAM/2
      IB2=IB1+NSAM*NSAM
      SCAL=1.0/NSAM/NSAM
C
      DO 30 I=0,JC-1
      	II=I+1
      	DO 30 J=-JC+1,JC-1
      	  ITEMP=I**2+J**2
          IF ((ITEMP.GE.MAXR12).AND.(ITEMP.LT.MAXR22)) THEN
      	    JJ=J+1
      	    IF (JJ.LT.1) JJ=JJ+NSAM
      	      ID=II+JC*(JJ-1)
      	      CTFR=CTFF(ID)
      	      CTFL=CTFF(ID+IC)
            IF (IEWALD.NE.0) THEN 
C MW call ewald sphere corrected extraction
              IF (IEWALD.LT.0) THEN
                CTFR=CONJG(CTFR)
                CTFL=CONJG(CTFL)
              ENDIF
              AINPO=EWALDEX(NSAM,IRAD,A3DF,SINCLUT,IPAD,
     +                         I,J,DM,THETATR,CTFR,CTFL)
            ELSE 
      	      X3=DM(1)*I+DM(4)*J
      	      Y3=DM(2)*I+DM(5)*J
      	      Z3=DM(3)*I+DM(6)*J
      	      IF (IBUF.GE.0) THEN
                IF (IRAD.EQ.0) THEN
                  AINPO=AINTERPO3DBIG(NSAM,IPAD,A3DF,X3,Y3,Z3)
                ELSE
                  AINPO=AINTERPO3DS(IPAD*NSAM,IRAD,A3DF,
     +                              X3,Y3,Z3,SINCLUT,IPAD)
                ENDIF
              ENDIF
              AINPO=AINPO*(CTFR+CONJG(CTFL))
            ENDIF
      	      IF (IBUF.GT.0) PBUC(ID)=AINPO
      	      IF (IBUF.LT.0) AINPO=PBUC(ID)
              IB=IB1+2*ID
              RBUF(IB-1)=REAL(AINPO)*SCAL
              RBUF(IB)=AIMAG(AINPO)*SCAL
          ENDIF
30    CONTINUE
C
      CALL FFTW_BWD(RBUF(IB1+1),RBUF(IB1+1),FFTW_PLANS(2))
      CALL MASKCOS2_C(NSAM,RBUF(IB1+1),RI2,RI3,RIH,HALFW,
     +                AMAG,PSI)
      CALL FFTW_FWD(RBUF(IB1+1),RBUF(IB1+1),FFTW_PLANS(1))
C
      DO 31 I=0,JC-1
      	II=I+1
      	DO 31 J=-JC+1,JC-1
      	  ITEMP=I**2+J**2
          IF ((ITEMP.GE.MAXR12).AND.(ITEMP.LT.MAXR22)) THEN
      	    JJ=J+1
      	    IF (JJ.LT.1) JJ=JJ+NSAM
            PHASE=SHX*I+SHY*J
            PSHFT=CMPLX(COS(PHASE),SIN(PHASE))
      	      ID=II+JC*(JJ-1)
      	      SAMP=SPEC(ID)*PSHFT
              IB=IB1+2*ID
              AINPO=CMPLX(RBUF(IB-1),RBUF(IB))
C
            IBIN=4*(INT(SQRT(FLOAT(ITEMP))+0.5)+1)
            RBUF(IBIN-3)=RBUF(IBIN-3)+REAL(SAMP*CONJG(AINPO))
            RBUF(IBIN-2)=RBUF(IBIN-2)+CABS(SAMP)**2
            RBUF(IBIN-1)=RBUF(IBIN-1)+CABS(AINPO)**2
            RBUF(IBIN)=RBUF(IBIN)+1.0
C
          ENDIF
31    CONTINUE
C
      SUM1=0.0
      SUM2=0.0
      SUM3=0.0
      DO 10 I=2,NSAM/2
        IBIN=4*I
        IF(RBUF(IBIN).NE.0.0) THEN
C          IF (FSCT(I).LT.0.95) THEN
C            R=ABS(RBUF(IBIN-3)/SQRT(RBUF(IBIN-1)))
C          ELSE
            R=RBUF(IBIN-3)/SQRT(RBUF(IBIN-1))
C          ENDIF
          WGT=EXP(-RBFACT*(I-1)**2)
          SUM3=SUM3+R*WGT
          SUM2=SUM2+WGT**2*RBUF(IBIN-2)
          SUM1=SUM1+1.0
        ENDIF
10    CONTINUE
      IF (SUM1*SUM2.NE.0.0) SUM3=SUM3/SQRT(SUM1*SUM2)
      CC3M_C=SUM3
C
      RETURN
      END
