      subroutine get_xn_vcs(KINE,Q2,W,EIMEV,EFMEV,THETA_E,THCM_P,PHICM_P,SIGLAB,SIG)
c
      implicit none
      character*5 kine   
      real*8 THETA_E,EIMEV,EFMEV,THCM_P,PHICM_P,THE,TH,PHI,Q2,W
      real*8 SIGLAB,SIG
      real*8 EB_LOW,EB_HI,EB_STEP
      real*8 Ee_LOW,Ee_HI,Ee_STEP
      real*8 Eth_LOW,Eth_HI,Eth_STEP
      real*8 Thgg_LOW,Thgg_HI,Thgg_STEP
      real*8 Phgg_LOW,Phgg_HI,Phgg_STEP
      integer*4 EB_NBIN,Ee_NBIN,Eth_NBIN,Thgg_NBIN,Phgg_NBIN
      integer ios
c     
      integer nx,n1,n2,n3,n4,n5
      integer nt1,nt2,nt3,nt4,nt5
      integer ntt1,ntt2,ntt3,ntt4,ntt5
      integer i,j,k,l,m
      parameter (Nx=5)
c      parameter (N1=8,N2=156,N3=40,N4=106,N5=37)
      parameter (N1=8,N2=131,N3=40,N4=86,N5=37)
      integer NA(nx)
      real*4 X(Nx)
      real*4 A(N1+N2+N3+N4+N5)
      real*4 vcs_xs(N1,N2,N3,N4,N5),d1,d2,d3,d4,d5
      real*4 fint
      integer Ntot
      logical debug /.false./
      
c
	logical*4	firsttime	/.true./
	logical*4	locforunt
	integer*4	chan
        save
c
      THE =  THETA_E*180/3.14159
      TH=180-THCM_P*180/3.14159
      PHI=180+PHICM_P*180/3.14159
      if (PHI .gt. 360) PHI=PHI-360
      if (PHI .gt. 180) PHI= 360-PHI
      X(1) = EIMEV
      X(2) = EFMEV
      X(3) = THE
      X(4) = TH
      X(5) = PHI
c
      if (debug) write(*,*) '*************'
	if (firsttime) then
	   if (.not.locforunt(chan)) 
     >         stop 'VCS_XS: No I/O channels!'
           open(unit=chan,status='old',iostat=ios,file='VCS_XS/'//kine//'_binning.dat')
           if (ios ==0) then
              write(*,*) ' Reading file ','VCS_XS/'//kine//'_binning.dat'
             read(chan,*) EB_LOW,EB_HI,EB_STEP,EB_NBIN
             EB_nBIN= EB_nBin+1
             EB_NBIN = n1 ! temp
             Na(1) = EB_NBIN
             read(chan,*) Ee_LOW,Ee_HI,Ee_STEP,Ee_NBIN
             Ee_nBIN= Ee_nBin+1
             Ee_NBIN = n2 ! temp
             Na(2) = Ee_NBIN
             read(chan,*) Eth_LOW,Eth_HI,Eth_STEP,Eth_NBIN
             Eth_nBIN= Eth_nBin+1
             Eth_NBIN =N3 
             Na(3) = Eth_NBIN
             read(chan,*) Thgg_LOW,Thgg_HI,Thgg_STEP,Thgg_NBIN
              thgg_nBIN= thgg_nBin+1
             thgg_NBIN = N4
             Na(4) = thgg_NBIN
             read(chan,*) Phgg_LOW,Phgg_HI,Phgg_STEP,Phgg_NBIN
              phgg_nBIN= phgg_nBin+1
             phgg_NBIN = N5
             Na(5) = phgg_NBIN
	     close (unit=chan)
             ntot=1
             do i=1,EB_NBIN
                a(ntot) = EB_low + EB_step*(i-1)
                ntot=ntot+1
                enddo
             do i=1,Ee_NBIN
                a(ntot) = Ee_low + Ee_step*(i-1)
                ntot=ntot+1                
                enddo
             do i=1,Eth_NBIN
                a(ntot) = Eth_low + Eth_step*(i-1)
                ntot=ntot+1                
                enddo
             do i=1,thgg_NBIN
                a(ntot) = thgg_low + thgg_step*(i-1)
                ntot=ntot+1                
                enddo
             do i=1,phgg_NBIN
                a(ntot) = phgg_low + phgg_step*(i-1)
                ntot=ntot+1                
                enddo
             if (ntot-1 .gt. N1+N2+N3+N4+N5) stop 'VCS_XS: Ntot too large !'
           else
              write(*,*) ' Could not open file ','VCS_XS/'//kine//'_binning.dat'
              stop
           endif
	   if (.not.locforunt(chan)) 
     >         stop 'VCS_XN: No I/O channels!'
           open(unit=chan,status='old',iostat=ios,file='final_vcs_xs/'//kine//'.txt')
           if (ios ==0) then
            write(*,*) ' Reading file ','final_vcs_xs/'//kine//'.txt'
            do i=1,EB_NBIN
               write(*,*) ' at eb_bin = ',i,' Tot  ebin = ',eb_nbin
            do j=1,Ee_NBIN
            do k=1,Eth_NBIN
            do l=1,thgg_NBIN
            do m=1,phgg_NBIN
               read(chan,*) d1,d2,d3,d4,d5,vcs_xs(i,j,k,l,m)
             ntt2 = j+EB_NBIN
             ntt3= k+EB_NBIN+Ee_NBIN
             ntt4= l+EB_NBIN+Ee_NBIN+Eth_NBIN
             ntt5= m+EB_NBIN+Ee_NBIN+Eth_NBIN+thgg_NBIN
             if (d1 .ne. a(i) ) stop ' VCS_XN: Problem with beam energy in input file'
             if (d2 .ne. a(ntt2) ) stop ' VCS_XN: Problem with electron energyinput file'
             if (d3 .ne. a(ntt3) ) stop ' VCS_XN: Problem with scattered anlge in input file'
             if (d4 .ne. a(ntt4) ) stop ' VCS_XN: Problem with thgg in input file'
             if (d5 .ne. a(ntt5) ) stop ' VCS_XN: Problem with phigg in input file'
               if (abs(d5-(phgg_low + phgg_step*(m-1)))>phgg_step/2. ) then
                  write(*,*) i,j,k,l,m,phgg_low + phgg_step*(m-1)
                  write(*,*) d1,d2,d3,d4,d5,vcs_xs(i,j,k,l,m)
                  stop
                  endif
               if (abs(d4-(thgg_low + thgg_step*(l-1)))>thgg_step/2. ) then
                  write(*,*) i,j,k,l,m,thgg_low + thgg_step*(l-1)
                  write(*,*) d1,d2,d3,d4,d5,vcs_xs(i,j,k,l,m)
                  stop
                  endif
               
               if (abs(d3-(Eth_low + Eth_step*(k-1)))>Eth_step/2. ) then
                  write(*,*) i,j,k,l,m,Eth_low + Eth_step*(k-1)
                  write(*,*) d1,d2,d3,d4,d5,vcs_xs(i,j,k,l,m)
                  stop
                  endif
               if (abs(d2-(Ee_low + Ee_step*(j-1)))>Eth_step/2. ) then
                  write(*,*) i,j,k,l,m,Ee_low + Ee_step*(j-1)
                  write(*,*) d1,d2,d3,d4,d5,vcs_xs(i,j,k,l,m)
                  stop
                  endif
               if (abs(d1-(EB_low + EB_step*(i-1)))>EB_step/2. ) then
                  write(*,*) i,j,k,l,m,EB_low + EB_step*(i-1)
                  write(*,*) d1,d2,d3,d4,d5,vcs_xs(i,j,k,l,m)
                  stop
                  endif
            enddo
            enddo
            enddo
            enddo
            enddo
 	    close (unit=chan)
           else
              write(*,*) ' Could not open file ','final_vcs_xs/'//kine//'.txt'
              stop
           endif
           
	   firsttime = .false.
        endif
          nt1= ceiling((x(1)-EB_LOW)/EB_Step) +1
          nt2= ceiling((x(2)-Ee_LOW)/Ee_Step) +1
          nt3= ceiling((x(3)-Eth_LOW)/Eth_Step) +1
          nt4= ceiling((x(4)-thgg_LOW)/thgg_Step) +1
          nt5= ceiling((x(5)-phgg_LOW)/phgg_Step) +1
         if (debug)  write(*,*) nt1,nt2,nt3,nt4,nt5
          siglab=0.
          sig=-1.
         if (debug)     write(*,'(7f10.5)') Q2/1000000.,W/1000.,x(1),x(2),x(3),x(4),x(5)
           if ( nt1 .ge. 1 .and. nt1 .le. EB_NBIN .and.
     >   nt2 .ge. 1 .and. nt2 .le. Ee_NBIN .and.
     >   nt3 .ge. 1 .and. nt3 .le. Eth_NBIN .and.
     >   nt4 .ge. 1 .and. nt4 .le. thgg_NBIN .and.
     >   nt5 .ge. 1 .and. nt5 .le. phgg_NBIN
     > ) then
             ntt2 = nt2+EB_NBIN
             ntt3= nt3+EB_NBIN+Ee_NBIN
             ntt4= nt4+EB_NBIN+Ee_NBIN+Eth_NBIN
             ntt5= nt5+EB_NBIN+Ee_NBIN+Eth_NBIN+thgg_NBIN
           SIGLAB= fint(Nx,X,na,a,vcs_xs)/1000. ! 1/1000 to convert to 1/MeV
           sig = vcs_xs(nt1,nt2,nt3,nt4,nt5)
           if (debug)    write(*,'(5f10.5,2g10.5)') a(nt1),a(ntt2),a(ntt3),a(ntt4),a(ntt5),sig,siglab*1000.
         endif
         if (debug .and. siglab .eq.0) write(*,'(a,5f10.5,1x,g10.5)') ' siglab = 0',x(1),x(2),x(3),x(4),x(5),siglab
         if (debug)   write(*,*) '*****'
c
c
c
      return
      end
c
