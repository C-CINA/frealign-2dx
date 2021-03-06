C*
C* Copyright 2013 Howard Hughes Medical Institute.
C* All rights reserved.
C* Use is subject to Janelia Farm Research Campus Software Copyright 1.1
C* license terms ( http://license.janelia.org/license/jfrc_copyright_1_1.html )
C*
C**************************************************************************
      PROGRAM BFACTOR
C**************************************************************************
C
      USE ISO_C_BINDING
      USE FFTW33
C
      IMPLICIT NONE
C
      INTEGER N1,N2,N3,I,ID,IP,MODE,NR1,NR2
      INTEGER NSAM,K,NSAM3,N,NN,ITEMP,IM
      INTEGER JC,L,LL,M,MM,IERR,SLEN2
      INTEGER,ALLOCATABLE :: IPW(:)
      REAL PSIZE,HW,RI2,RI3,RIH,RII,RMIN,RMAX,A(3),EP(3)
      REAL MASK,BFACT,PI,WEIGHT,SRAD2,S,SX,SY,SXX,SXY
      REAL,ALLOCATABLE :: DATA(:),PW(:)
      PARAMETER (PI=3.1415926535897)
      CHARACTER FNAME*200,CFORM,VX*15,TITLE*1600,ASYM*3
      TYPE(C_PTR) FFTW_PLANS(2)
C
      DATA  VX/'1.06 - 13.05.15'/
C     15 chars 'X.XX - XX.XX.XX' <--<--<--<--<--<--<--<--
C
      WRITE(*,1010)VX
1010  FORMAT(/'  BFACTOR ',A15,/,
     +       /'  Copyright 2013 Howard Hughes Medical Institute.',
     +       /'  All rights reserved.',
     +       /'  Use is subject to Janelia Farm Research Campus',
     +        ' Software Copyright 1.1',
     +       /'  license terms ( http://license.janelia.org/license',
     +        '/jfrc_copyright_1_1.html )'/)
C
      WRITE(*,*)'Image format [M,S,I]?'
      READ(*,1100)CFORM
1100  FORMAT(A1)
      WRITE(*,11100)CFORM
11100 FORMAT(3X,A1)
      WRITE(*,*)'Input 3D map or 2D image?'
      READ(*,1000)FNAME
1000  FORMAT(A200)
      WRITE(*,11000) FNAME(1:SLEN2(FNAME))
11000 FORMAT(3X,A)
C
      CALL IOPEN(FNAME,10,CFORM,N1,N2,N3,'OLD',ASYM,
     +           PSIZE,VX)
C      CALL IOPEN(FNAME,10,CFORM,MODE,N1,N2,N3,'OLD',
C     .           PSIZE,TITLE)
      IF ((N1.NE.N2).OR.(N1.NE.N3).OR.(N2.NE.N3)) THEN
        IF(N3.NE.1) THEN
          WRITE(*,*) 'X,Y,Z dimensions not equal'
          GOTO 999
        ELSEIF(N1.NE.N2) THEN
          WRITE(*,*) 'X,Y dimensions not equal'
          GOTO 999
        ENDIF
      ENDIF
      IF (MOD(N1,2).NE.0) THEN
        WRITE(*,*) 'Dimensions must be even'
        GOTO 999
      ENDIF
      ALLOCATE(DATA(N1*N1*N3+2*N1*N3),
     .         IPW(N1),PW(N1),STAT=IERR)
      IF (IERR.NE.0) THEN
        WRITE(*,*) ' ERROR: Memory allocation failed'
        GOTO 999
      ENDIF
C
      NSAM=N1
C      NSAMH=NSAM/2
      NSAM3=NSAM*N3*NSAM
      JC=NSAM/2+1
C
      IF (N3.EQ.1) THEN
        CALL FFTW_PLANS_2D(NSAM,DATA,DATA,FFTW_PLANS(1),FFTW_PLANS(2))
      ELSE
        CALL FFTW_PLANS_3D(NSAM,DATA,DATA,FFTW_PLANS(1),FFTW_PLANS(2))
      ENDIF
C
      DO 10 K=1,N3
        IP=NSAM*(K-1)
        DO 10 I=1,NSAM
          ID=1+(NSAM+2)*((I-1)+NSAM*(K-1))
          CALL IREAD(10,DATA(ID),I+IP)
10    CONTINUE
C
      CALL ICLOSE(10)
C
      WRITE(*,*)'Output 3D map or 2D image?'
      READ(*,1000)FNAME
      WRITE(*,11000) FNAME(1:SLEN2(FNAME))
C
      TITLE='BFACTOR: Filtered output with applied B-factor'
      CALL IOPEN(FNAME,10,CFORM,N1,N2,N3,'NEW',ASYM,
     +           PSIZE,VX)
C      CALL IOPEN(FNAME,10,CFORM,MODE,N1,N2,N3,'NEW',
C     .           PSIZE,TITLE)
C
      CALL FFTW_FWD(DATA,DATA,FFTW_PLANS(1))
C
      WRITE(*,*)
      WRITE(*,*)'Pixel size from header =',PSIZE
      WRITE(*,*)'Pixel size in A?'
      WRITE(*,*)'(Enter * to use header value)'
      READ(*,1000)FNAME
      IF (FNAME(1:1).NE."*") THEN
        READ(FNAME,*)PSIZE
      ENDIF
      WRITE(*,*)PSIZE
C
      IF (N3.NE.1) THEN
C
      WRITE(*,*)'Resolution low, high, in A'
      READ(*,*)RMIN,RMAX
      WRITE(*,*)RMIN,RMAX
      IF (RMIN.LT.RMAX) THEN
        BFACT=RMIN
        RMIN=RMAX
        RMAX=BFACT
      ENDIF
      RMIN=PSIZE/ABS(RMIN)*NSAM
      RMAX=PSIZE/ABS(RMAX)*NSAM
C
      DO 109 I=1,NSAM
        IPW(I)=0
        PW(I)=0.0
109   CONTINUE
C
      DO 110 L=1,JC
        LL=L-1
        DO 110 M=1,NSAM
          MM=M-1
          IF (MM.GE.JC) MM=MM-NSAM
          DO 110 N=1,NSAM
            NN=N-1
            IF (NN.GE.JC) NN=NN-NSAM
            ITEMP=LL**2+MM**2+NN**2
            SRAD2=SQRT(REAL(ITEMP))
            I=NINT(SRAD2)+1
              ID=2*(L+JC*((M-1)+NSAM*(N-1)))
              PW(I)=PW(I)+LOG(DATA(ID-1)**2+DATA(ID)**2)
            IPW(I)=IPW(I)+1
110   CONTINUE
C
      S=0.0
      SX=0.0
      SXX=0.0
      SXY=0.0
      SY=0.0
      NR1=NINT(RMIN)+1
      IF (NR1.EQ.1) NR1=2
      NR2=NINT(RMAX)+1
      IF (NR2.LE.NR1) NR2=NR1+1
      DO 112 I=NR1,NR2
        IF(IPW(I).NE.0) PW(I)=PW(I)/IPW(I)
        S=S+1.0
        SX=SX+(REAL(I)-1)**2
        SXX=SXX+(REAL(I)-1)**4
        SXY=SXY+(REAL(I)-1)**2*PW(I)
        SY=SY+PW(I)
112   CONTINUE
      A(1)=(SXX*SY-SX*SXY)/(S*SXX-SX**2)
      EP(1)=A(1)/100.0
      A(2)=(S*SXY-SX*SY)/(S*SXX-SX**2)
      EP(2)=A(2)/100.0
      A(3)=-2.0 
      EP(3)=A(3)/100.0
C
      CALL VA04A(A,EP,3,S,100.0,0,1,50,NR1,NR2,PW)
C      print *,'COEFS =',A(1),A(2),A(3)
      BFACT=-A(2)
C
      WRITE(*,*)
      WRITE(*,*)'Resolution        log(Power)               Fit'
      DO 113 I=NR1,NR2
        WRITE(*,1004)SQRT((NSAM*PSIZE)**2/(I-1)**2),PW(I),
     +    A(1)+A(2)*(I-1)**2+A(3)*LOG(REAL((I-1)))
1004    FORMAT(F11.2,F18.4,F18.4)
113   CONTINUE   
C
      BFACT=BFACT*2.0*(NSAM*PSIZE)**2
      WRITE(*,*)
      WRITE(*,*)'Measured B-factor =',BFACT
      WRITE(*,*)
C
      WRITE(*,*)'B-factor to be applied, in A^2'
      WRITE(*,*)'(Enter * to apply negative of measured B-factor)'
      READ(*,1000)FNAME
      IF (FNAME(1:1).NE."*") THEN
        READ(FNAME,*)BFACT
      ELSE
        BFACT=-BFACT
      ENDIF
C
      ELSE
        WRITE(*,*)'B-factor to be applied, in A^2'
        READ(*,*)BFACT
      ENDIF
C
      WRITE(*,*)BFACT
      WRITE(*,*)'Gauss filter (1) or cosine edge mask (2)?'
      READ(*,*)IM
      WRITE(*,*)IM
      IF (IM.EQ.1) THEN
        WRITE(*,*)'Gauss filter radius in A?'
      ELSE
        WRITE(*,*)'Cosine edge filter radius in A?'
      ENDIF
      READ(*,*)MASK
      WRITE(*,*)MASK
      IF (IM.NE.1) THEN
        WRITE(*,*)'Width of edge in pixels?'
        READ(*,*)HW
        WRITE(*,*)HW
      ENDIF
      MASK=MASK/PSIZE
      BFACT=BFACT/(4.0*(NSAM*PSIZE)**2)
      IF (MASK.NE.0.0) THEN
        MASK=1.0/MASK*NSAM
      ELSE
        MASK=1.0D30
      ENDIF
      RII=MASK+HW/2.0
      RIH=MASK-HW/2.0
      IF (RIH.LT.0.0) RIH=0.0
      RI2=RIH**2
      RI3=RII**2
C
      DO 111 L=1,JC
        LL=L-1
        DO 111 M=1,NSAM
          MM=M-1
          IF (MM.GE.JC) MM=MM-NSAM
          DO 111 N=1,N3
            NN=N-1
            IF (NN.GE.JC) NN=NN-N3
            ITEMP=LL**2+MM**2+NN**2
            WEIGHT=EXP(-BFACT*ITEMP)
            IF (IM.EQ.1) THEN
              WEIGHT=WEIGHT*EXP(-ITEMP/(2.0*MASK**2))
            ELSEIF ((ITEMP.GT.RI2).AND.(ITEMP.LE.RI3)) THEN
              SRAD2=SQRT(REAL(ITEMP))
              WEIGHT=WEIGHT*(1.0+COS(PI*(SRAD2-RIH)/HW))/2.0
            ELSEIF (ITEMP.GT.RI3) THEN
              WEIGHT=0.0
            ENDIF
              ID=2*(L+JC*((M-1)+N3*(N-1)))
              DATA(ID-1)=DATA(ID-1)*WEIGHT/NSAM3
              DATA(ID)=DATA(ID)*WEIGHT/NSAM3
111   CONTINUE
C
      PRINT *
      WRITE(*,*)'Resolution  Weighting Factor'
      DO 30 I=1,REAL(NSAM/2)*SQRT(3.0)
        WEIGHT=EXP(-BFACT*(I-1)**2)
        IF (IM.EQ.1) THEN
          WEIGHT=WEIGHT*EXP(-(I-1)**2/(2.0*MASK**2))
        ELSEIF (((I-1)**2.GT.RI2).AND.((I-1)**2.LE.RI3)) THEN
          SRAD2=SQRT(REAL((I-1)**2)) 
          WEIGHT=WEIGHT*(1.0+COS(PI*(SRAD2-RIH)/HW))/2.0
        ELSEIF ((I-1)**2.GT.RI3) THEN
          WEIGHT=0.0
        ENDIF
        WRITE(*,1003)REAL(NSAM)/I*PSIZE,WEIGHT
1003    FORMAT(F11.2,F18.4)
30    CONTINUE
      PRINT *
C
      CALL FFTW_BWD(DATA,DATA,FFTW_PLANS(2))
C
      DO 20 K=1,N3
        IP=NSAM*(K-1)
        DO 20 I=1,NSAM
          ID=1+(NSAM+2)*((I-1)+NSAM*(K-1))
          CALL IWRITE(10,DATA(ID),I+IP)
20    CONTINUE
C
      CALL ICLOSE(10)
      PRINT *
      WRITE(*,*) ' NORMAL TERMINATION OF BFACTOR'
C
999   CONTINUE
C
      END
C
C**************************************************************************
      SUBROUTINE CALCFX(N,X,F,N1,N2,PW)
C**************************************************************************
      IMPLICIT NONE
C
      INTEGER N,I,N1,N2
      REAL X(*),F,S,PW(*)
C
      S=0.0
      DO 20 I=N1,N2
C        S=S+(PW(I)-X(1)-X(2)*(I-1)**2)**2
        S=S+(PW(I)-X(1)-X(2)*(I-1)**2-X(3)*LOG(REAL((I-1))))**2
20    CONTINUE
C
      F=S
C
      RETURN   
      END
C**************************************************************************
      INTEGER FUNCTION SLEN2(STRG)
C**************************************************************************
C Determines length of string STRG
C**************************************************************************
      IMPLICIT NONE
C
      INTEGER I
      CHARACTER*200 STRG
C**************************************************************************
C
      DO 10 I=200,1,-1
        IF (STRG(I:I).NE." ") GOTO 20
10    CONTINUE
C
20    CONTINUE
      SLEN2=I
C
      RETURN
      END
C**************************************************************************
      SUBROUTINE VA04A(X,E,N,F,ESCALE,IPRINT,ICON,
     +                 MAXIT,N1,N2,PW)
C**************************************************************************
C  STANDARD FORTRAN 66 (A VERIFIED PFORT SUBROUTINE)  - Powell minimisation
C  some changes were made to reduce diagnostic output and prevent occasional
C  crashes (Niko, 12. June 1998)
C  Calls CALCFX
C**************************************************************************
      DIMENSION W(20),X(*),E(*),XS(10),PW(*)
C**************************************************************************
C	W[N*(N+3)]
      DDMAG=0.1*ESCALE
      SCER=0.05/ESCALE
      ICNT=0
      MAXX=100*MAXIT
      DO 999 I=1,N
        XS(I)=X(I)
  999 CONTINUE
      JJ=N*N+N
      JJJ=JJ+N
      K=N+1
      NFCC=1
      IND=1
      INN=1
      DO 1 I=1,N
      DO 2 J=1,N
      W(K)=0.
      IF(I-J)4,3,4
    3 W(K)=ABS(E(I))
      W(I)=ESCALE
    4 K=K+1
    2 CONTINUE
    1 CONTINUE
      ITERC=1
      ISGRAD=2
      ICNT=ICNT+1
      IF (ICNT.GT.MAXX) GOTO 998
      CALL CALCFX(N,X,F,N1,N2,PW)
      FKEEP=ABS(F)+ABS(F)
    5 ITONE=1
      FP=F
      SUM=0.
      IXP=JJ
      DO 6 I=1,N
      IXP=IXP+1
      W(IXP)=X(I)
    6 CONTINUE
      IDIRN=N+1
      ILINE=1
    7 DMAX=W(ILINE)
      DACC=DMAX*SCER
      DMAG=AMIN1(DDMAG,0.1*DMAX)
      DMAG=AMAX1(DMAG,20.*DACC)
      DDMAX=10.*DMAG
      GO TO (70,70,71),ITONE
   70 DL=0.
      D=DMAG
      FPREV=F
      IS=5
      FA=F
      DA=DL
    8 DD=D-DL
      DL=D
   58 K=IDIRN
      DO 9 I=1,N
      X(I)=X(I)+DD*W(K)
      K=K+1
    9 CONTINUE
      ICNT=ICNT+1
      IF (ICNT.GT.MAXX) GOTO 998
      CALL CALCFX(N,X,F,N1,N2,PW)
      NFCC=NFCC+1
      GO TO (10,11,12,13,14,96),IS
   14 IF(F-FA)15,16,24
   16 IF (ABS(D)-DMAX) 17,17,18
   17 D=D+D
      GO TO 8
   18 WRITE(6,19)
   19 FORMAT(5X,50HPOWELL MIN: MAXIMUM CHANGE DOES NOT ALTER FUNCTION)
C   19 FORMAT(5X,44HVA04A MAXIMUM CHANGE DOES NOT ALTER FUNCTION)
      GO TO 20
   15 FB=F
      DB=D
      GO TO 21
   24 FB=FA
      DB=DA
      FA=F
      DA=D
   21 GO TO (83,23),ISGRAD
   23 D=DB+DB-DA
      IS=1
      GO TO 8
   83 D=0.5*(DA+DB-(FA-FB)/(DA-DB))
      IS=4
      IF((DA-D)*(D-DB))25,8,8
   25 IS=1
      IF(ABS(D-DB)-DDMAX)8,8,26
   26 D=DB+SIGN(DDMAX,DB-DA)
      IS=1
      DDMAX=DDMAX+DDMAX
      DDMAG=DDMAG+DDMAG
      IF(DDMAX-DMAX)8,8,27
   27 DDMAX=DMAX
      GO TO 8
   13 IF(F-FA)28,23,23
   28 FC=FB
      DC=DB
   29 FB=F
      DB=D
      GO TO 30
   12 IF(F-FB)28,28,31
   31 FA=F
      DA=D
      GO TO 30
   11 IF(F-FB)32,10,10
   32 FA=FB
      DA=DB
      GO TO 29
   71 DL=1.
      DDMAX=5.
      FA=FP
      DA=-1.
      FB=FHOLD
      DB=0.
      D=1.
   10 FC=F
      DC=D
   30 A=(DB-DC)*(FA-FC)
      B=(DC-DA)*(FB-FC)
      IF((A+B)*(DA-DC))33,33,34
   33 FA=FB
      DA=DB
      FB=FC
      DB=DC
      GO TO 26
   34 D=0.5*(A*(DB+DC)+B*(DA+DC))/(A+B)
      DI=DB
      FI=FB
      IF(FB-FC)44,44,43
   43 DI=DC
      FI=FC
   44 GO TO (86,86,85),ITONE
   85 ITONE=2
      GO TO 45
   86 IF (ABS(D-DI)-DACC) 41,41,93
   93 IF (ABS(D-DI)-0.03*ABS(D)) 41,41,45
   45 IF ((DA-DC)*(DC-D)) 47,46,46
   46 FA=FB
      DA=DB
      FB=FC
      DB=DC
      GO TO 25
   47 IS=2
      IF ((DB-D)*(D-DC)) 48,8,8
   48 IS=3
      GO TO 8
   41 F=FI
      D=DI-DL
      DD=(DC-DB)*(DC-DA)*(DA-DB)/(A+B)
      IF (DD.LT.0.0) DD=1E-10
      DD=SQRT(DD)
      DO 49 I=1,N
      X(I)=X(I)+D*W(IDIRN)
      W(IDIRN)=DD*W(IDIRN)
      IDIRN=IDIRN+1
   49 CONTINUE
      IF (DD.EQ.0.0) DD=1E-10
      W(ILINE)=W(ILINE)/DD
      ILINE=ILINE+1
      IF(IPRINT-1)51,50,51
   50 CONTINUE
C   50 WRITE(6,52) ITERC,NFCC,F,(X(I),I=1,N)
   52 FORMAT (/1X,9HITERATION,I5,I15,16H FUNCTION VALUES,
     110X,3HF =,E21.14/(5E24.14))
      GO TO(51,53),IPRINT
   51 GO TO (55,38),ITONE
   55 IF (FPREV-F-SUM) 94,95,95
   95 SUM=FPREV-F
      JIL=ILINE
   94 IF (IDIRN-JJ) 7,7,84
   84 GO TO (92,72),IND
   92 FHOLD=F
      IS=6
      IXP=JJ
      DO 59 I=1,N
      IXP=IXP+1
      W(IXP)=X(I)-W(IXP)
   59 CONTINUE
      DD=1.
      GO TO 58
   96 GO TO (112,87),IND
  112 IF (FP-F) 37,37,91
   91 D=2.*(FP+F-2.*FHOLD)/(FP-F)**2
      IF (D*(FP-FHOLD-SUM)**2-SUM) 87,37,37
   87 J=JIL*N+1
      IF (J-JJ) 60,60,61
   60 DO 62 I=J,JJ
      K=I-N
      W(K)=W(I)
   62 CONTINUE
      DO 97 I=JIL,N
      W(I-1)=W(I)
   97 CONTINUE
   61 IDIRN=IDIRN-N
      ITONE=3
      K=IDIRN
      IXP=JJ
      AAA=0.
      DO 65 I=1,N
      IXP=IXP+1
      W(K)=W(IXP)
      IF (AAA-ABS(W(K)/E(I))) 66,67,67
   66 AAA=ABS(W(K)/E(I))
   67 K=K+1
   65 CONTINUE
      DDMAG=1.
      IF (AAA.EQ.0.0) AAA=1E-10
      W(N)=ESCALE/AAA
      ILINE=N
      GO TO 7
   37 IXP=JJ
      AAA=0.
      F=FHOLD
      DO 99 I=1,N
      IXP=IXP+1
      X(I)=X(I)-W(IXP)
      IF (AAA*ABS(E(I))-ABS(W(IXP))) 98,99,99
   98 AAA=ABS(W(IXP)/E(I))
   99 CONTINUE
      GO TO 72
   38 AAA=AAA*(1.+DI)
      GO TO (72,106),IND
   72 IF (IPRINT-2) 53,50,50
   53 GO TO (109,88),IND
  109 IF (AAA-0.1) 89,89,76
   89 GO TO (20,116),ICON
  116 IND=2
      GO TO (100,101),INN
  100 INN=2
      K=JJJ
      DO 102 I=1,N
      K=K+1
      W(K)=X(I)
      X(I)=X(I)+10.*E(I)
  102 CONTINUE
      FKEEP=F
      ICNT=ICNT+1
      IF (ICNT.GT.MAXX) GOTO 998
      CALL CALCFX(N,X,F,N1,N2,PW)
      NFCC=NFCC+1
      DDMAG=0.
      GO TO 108
   76 IF (F-FP) 35,78,78
   78 CONTINUE
C   78 WRITE(6,80)
   80 FORMAT (5X,43HPOWELL MIN: ACCURACY LIMITED BY ERRORS IN F)
C   80 FORMAT (5X,37HVA04A ACCURACY LIMITED BY ERRORS IN F)
      GO TO 20
   88 IND=1
   35 TMP=FP-F
      IF (TMP.GT.0.0) THEN
      DDMAG=0.4*SQRT(TMP)
      ELSE
      DDMAG=0.0
      ENDIF
      ISGRAD=1
  108 ITERC=ITERC+1
      IF (ITERC-MAXIT) 5,5,81
81    CONTINUE
C   81 WRITE(6,82) MAXIT
   82 FORMAT(I5,30H ITERATIONS COMPLETED BY VA04A)
      IF (F-FKEEP) 20,20,110
  110 F=FKEEP
      DO 111 I=1,N
      JJJ=JJJ+1
      X(I)=W(JJJ)
  111 CONTINUE
      GO TO 20
  101 JIL=1
      FP=FKEEP
      IF (F-FKEEP) 105,78,104
  104 JIL=2
      FP=F
      F=FKEEP
  105 IXP=JJ
      DO 113 I=1,N
      IXP=IXP+1
      K=IXP+N
      GO TO (114,115),JIL
  114 W(IXP)=W(K)
      GO TO 113
  115 W(IXP)=X(I)
      X(I)=W(K)
  113 CONTINUE
      JIL=2
      GO TO 92
  106 IF (AAA-0.1) 20,20,107
   20 CONTINUE
      RETURN
  107 INN=1
      GO TO 35
  998 CONTINUE
      DO 997 I=1,N
        X(I)=XS(I)
  997 CONTINUE
      CALL CALCFX(N,X,F,N1,N2,PW)
      PRINT *,'VA04A ENDLESS LOOP SAFETY CATCH: ICNT = ',ICNT
      RETURN
      END
