!
! Copyright (C) 2002-2011 Quantum ESPRESSO group
! This file is distributed under the terms of the
! GNU General Public License. See the file `License'
! in the root directory of the present distribution,
! or http://www.gnu.org/copyleft/gpl.txt .
!
#define DIMS2D(my_array) lbound(my_array,1):ubound(my_array,1),lbound(my_array,2):ubound(my_array,2)
!=----------------------------------------------------------------------------=!
   MODULE wvfct_gpum
!=----------------------------------------------------------------------------=!
     USE kinds, ONLY :  DP

     IMPLICIT NONE
     SAVE
     !
     REAL(DP), ALLOCATABLE, TARGET :: g2kin_d(:)

     REAL(DP), ALLOCATABLE, TARGET :: et_d(:, :)

     !
#if defined(__CUDA)
     attributes (DEVICE) :: g2kin_d, et_d

     LOGICAL :: g2kin_ood = .false.    ! used to flag out of date variables
     LOGICAL :: g2kin_d_ood = .false.    ! used to flag out of date variables
     LOGICAL :: et_ood = .false.    ! used to flag out of date variables
     LOGICAL :: et_d_ood = .false.    ! used to flag out of date variables
     !
#endif
     CONTAINS
     !
     SUBROUTINE using_g2kin(changing)
         !
         USE wvfct, ONLY : g2kin
         implicit none
         LOGICAL, INTENT(IN) :: changing
#if defined(__CUDA)
         !
         IF (g2kin_ood) THEN
             IF (.not. allocated(g2kin_d)) THEN
                CALL errore('using_g2kin_d', 'PANIC: sync of g2kin from g2kin_d with unallocated array. Bye!!', 1)
                stop
             END IF
             IF (.not. allocated(g2kin)) THEN
                print *, "WARNING: sync of g2kin with unallocated array. Bye!"
                IF (changing)    g2kin_d_ood = .true.
                return
             END IF
             print *, "Really copied g2kin D->H"
             g2kin = g2kin_d
             g2kin_ood = .false.
         ENDIF
         IF (changing)    g2kin_d_ood = .true.
#endif
     END SUBROUTINE using_g2kin
     !
     SUBROUTINE using_g2kin_d(changing)
         !
         USE wvfct, ONLY : g2kin
         implicit none
         LOGICAL, INTENT(IN) :: changing
#if defined(__CUDA)
         !
         IF (.not. allocated(g2kin)) THEN
             IF (allocated(g2kin_d)) DEALLOCATE(g2kin_d)
             g2kin_d_ood = .false.
             RETURN
         END IF
         IF (g2kin_d_ood) THEN
             IF ( allocated(g2kin_d) .and. (SIZE(g2kin_d)/=SIZE(g2kin))) deallocate(g2kin_d)
             IF (.not. allocated(g2kin_d)) THEN
                 ALLOCATE(g2kin_d, SOURCE=g2kin)
             ELSE
                 print *, "Really copied g2kin H->D"
                 g2kin_d = g2kin
             ENDIF
             g2kin_d_ood = .false.
         ENDIF
         IF (changing)    g2kin_ood = .true.
#else
         CALL errore('using_g2kin_d', 'Trying to use device data without device compilated code!', 1)
#endif
     END SUBROUTINE using_g2kin_d
     !
     SUBROUTINE using_et(changing)
         !
         USE wvfct, ONLY : et
         implicit none
         LOGICAL, INTENT(IN) :: changing
#if defined(__CUDA)
         !
         IF (et_ood) THEN
             IF (.not. allocated(et_d)) THEN
                CALL errore('using_et_d', 'PANIC: sync of et from et_d with unallocated array. Bye!!', 1)
                stop
             END IF
             IF (.not. allocated(et)) THEN
                print *, "WARNING: sync of et with unallocated array. Bye!"
                IF (changing)    et_d_ood = .true.
                return
             END IF
             print *, "Really copied et D->H"
             et = et_d
             et_ood = .false.
         ENDIF
         IF (changing)    et_d_ood = .true.
#endif
     END SUBROUTINE using_et
     !
     SUBROUTINE using_et_d(changing)
         !
         USE wvfct, ONLY : et
         implicit none
         LOGICAL, INTENT(IN) :: changing
#if defined(__CUDA)
         !
         IF (.not. allocated(et)) THEN
             IF (allocated(et_d)) DEALLOCATE(et_d)
             et_d_ood = .false.
             RETURN
         END IF
         IF (et_d_ood) THEN
             IF ( allocated(et_d) .and. (SIZE(et_d)/=SIZE(et))) deallocate(et_d)
             IF (.not. allocated(et_d)) THEN
                 ALLOCATE(et_d, SOURCE=et)
             ELSE
                 print *, "Really copied et H->D"
                 et_d = et
             ENDIF
             et_d_ood = .false.
         ENDIF
         IF (changing)    et_ood = .true.
#else
         CALL errore('using_et_d', 'Trying to use device data without device compilated code!', 1)
#endif
     END SUBROUTINE using_et_d
     !     
     SUBROUTINE deallocate_wvfct_gpu
       IF( ALLOCATED( g2kin_d ) ) DEALLOCATE( g2kin_d )
       IF( ALLOCATED( et_d ) ) DEALLOCATE( et_d )
     END SUBROUTINE deallocate_wvfct_gpu
!=----------------------------------------------------------------------------=!
   END MODULE wvfct_gpum
!=----------------------------------------------------------------------------=!
