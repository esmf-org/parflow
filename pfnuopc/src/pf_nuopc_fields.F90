#include "pf_nuopc_macros.h"

module parflow_nuopc_fields

  use ESMF
  use NUOPC
  use parflow_nuopc_flags
  use iso_c_binding, only: c_null_char, c_int, c_double, c_float

  implicit none

  private

  type pf_fld_mk_type
    character(len=64)              :: fname      = "dummy" ! state name
    character(len=64)              :: units      = "-"     ! units
    type(ESMF_Field), pointer      :: efld       => null()
    integer(ESMF_KIND_I4), pointer :: ptr(:,:) => null()
  endtype pf_fld_mk_type

  type pf_fld_2d_type
    character(len=64)           :: fname      = "dummy" ! state name
    character(len=64)           :: units      = "-"     ! units
    type(ESMF_Field), pointer   :: efld       => null()
    real(ESMF_KIND_R4), pointer :: ptr(:,:) => null()
  endtype pf_fld_2d_type

  type pf_fld_3d_type
    character(len=64)           :: fname      = "dummy" ! state name
    character(len=64)           :: units      = "-"     ! units
    type(ESMF_Field), pointer   :: efld       => null()
    real(ESMF_KIND_R4), pointer :: ptr(:,:,:) => null()
  endtype pf_fld_3d_type

  ! internal fields
  type(pf_fld_3d_type) :: pf_flux = &
    pf_fld_3d_type(fname="PF_FLUX      ", units="1 h-1")
  type(pf_fld_2d_type) :: pf_gws = &
    pf_fld_2d_type(fname="PF_GWS       ", units="-")
  type(pf_fld_2d_type) :: pf_gws_min = &
    pf_fld_2d_type(fname="PF_GWS_MIN   ", units="-")
  type(pf_fld_2d_type) :: pf_gws_max = &
    pf_fld_2d_type(fname="PF_GWS_MAX   ", units="-")
  type(pf_fld_3d_type) :: pf_porosity = &
    pf_fld_3d_type(fname="PF_POROSITY  ", units="-")
  type(pf_fld_3d_type) :: pf_pressure = &
    pf_fld_3d_type(fname="PF_PRESSURE  ", units="m")
  type(pf_fld_3d_type) :: pf_pressurec = &
    pf_fld_3d_type(fname="PF_PRESSUREC ", units="m")
  type(pf_fld_3d_type) :: pf_saturation = &
    pf_fld_3d_type(fname="PF_SATURATION", units="-")
  type(pf_fld_3d_type) :: pf_smois = &
    pf_fld_3d_type(fname="PF_SMOIS     ", units="-")
  type(pf_fld_3d_type) :: pf_specific = &
    pf_fld_3d_type(fname="PF_SPECIFIC  ", units="m3")
  type(pf_fld_3d_type) :: pf_sres = &
    pf_fld_3d_type(fname="PF_SRES      ", units="-")
  type(pf_fld_3d_type) :: pf_ssat = &
    pf_fld_3d_type(fname="PF_SSAT      ", units="-")
  type(pf_fld_3d_type) :: pf_alpha = &
    pf_fld_3d_type(fname="PF_ALPHA     ", units="")
  type(pf_fld_3d_type) :: pf_n = &
    pf_fld_3d_type(fname="PF_N         ", units="-")
  type(pf_fld_3d_type) :: pf_zmult = &
    pf_fld_3d_type(fname="PF_ZMULT     ", units="m")
  type(pf_fld_3d_type) :: pf_dz = &
    pf_fld_3d_type(fname="PF_DZ        ", units="m")
  type(pf_fld_2d_type) :: pf_zwt = &
    pf_fld_2d_type(fname="PF_ZWT       ", units="m")
  type(pf_fld_2d_type) :: pf_zwt_min = &
    pf_fld_2d_type(fname="PF_ZWT_MIN   ", units="m")
  type(pf_fld_2d_type) :: pf_zwt_max = &
    pf_fld_2d_type(fname="PF_ZWT_MAX   ", units="m")
  type(pf_fld_mk_type) :: pf_mask = &
    pf_fld_mk_type(fname="PF_MASK      ", units="-")

  type pf_nuopc_fld_type
    sequence
    character(len=64)           :: sd_name    = "dummy" ! standard name
    character(len=64)           :: st_name    = "dummy" ! state name
    character(len=64)           :: units      = "-"     ! units
    logical*8                   :: layers     = .FALSE. ! layered field
    logical                     :: ad_import  = .FALSE. ! advertise import
    logical                     :: ad_export  = .FALSE. ! advertise export
    logical                     :: rl_import  = .FALSE. ! realize import
    logical                     :: rl_export  = .FALSE. ! realize export
    real(ESMF_KIND_R8)          :: vl_default = ESMF_DEFAULT_VALUE ! default value
  end type pf_nuopc_fld_type

  ! external field list
  type(pf_nuopc_fld_type),target,dimension(22) :: pf_nuopc_fld_list = (/     &
    pf_nuopc_fld_type("total_water_flux                        ", &
      "FLUX      ", "kg m-2 s-1",  .TRUE.,  .TRUE., .FALSE.), &
    pf_nuopc_fld_type("total_water_flux_layer_1                ", &
      "FLUX1     ", "kg m-2 s-1", .FALSE.,  .TRUE., .FALSE.), &
    pf_nuopc_fld_type("total_water_flux_layer_2                ", &
      "FLUX2     ", "kg m-2 s-1", .FALSE.,  .TRUE., .FALSE.), &
    pf_nuopc_fld_type("total_water_flux_layer_3                ", &
      "FLUX3     ", "kg m-2 s-1", .FALSE.,  .TRUE., .FALSE.), &
    pf_nuopc_fld_type("total_water_flux_layer_4                ", &
      "FLUX4     ", "kg m-2 s-1", .FALSE.,  .TRUE., .FALSE.), &
    pf_nuopc_fld_type("precip_drip                             ", &
      "PCPDRP    ", "kg m-2 s-1", .FALSE.,  .TRUE., .FALSE.), &
    pf_nuopc_fld_type("bare_soil_evaporation                   ", &
      "EDIR      ", "W m-2     ", .FALSE.,  .TRUE., .FALSE.), &
    pf_nuopc_fld_type("vegetation_transpiration                ", &
      "ET        ", "W m-2     ",  .TRUE.,  .TRUE., .FALSE.), &
    pf_nuopc_fld_type("porosity                                ", &
      "POROSITY  ", "-         ",  .TRUE., .FALSE.,  .TRUE.), &
    pf_nuopc_fld_type("pressure                                ", &
      "PRESSURE  ", "m         ",  .TRUE., .FALSE.,  .TRUE.), &
    pf_nuopc_fld_type("saturation                              ", &
      "SATURATION", "-         ",  .TRUE., .FALSE.,  .TRUE.), &
    pf_nuopc_fld_type("ground_water_storage                    ", &
      "GWS       ", "-         ", .FALSE., .TRUE.,  .TRUE.), &
    pf_nuopc_fld_type("soil_moisture_fraction                  ", &
      "SMOIS     ", "-         ",  .TRUE., .FALSE.,  .TRUE.), &
    pf_nuopc_fld_type("soil_moisture_fraction_layer_1          ", &
      "SMOIS1     ", "-        ", .FALSE., .TRUE.,  .TRUE.), &
    pf_nuopc_fld_type("soil_moisture_fraction_layer_2          ", &
      "SMOIS2     ", "-        ", .FALSE., .TRUE.,  .TRUE.), &
    pf_nuopc_fld_type("soil_moisture_fraction_layer_3          ", &
      "SMOIS3     ", "-        ", .FALSE., .TRUE.,  .TRUE.), &
    pf_nuopc_fld_type("soil_moisture_fraction_layer_4          ", &
      "SMOIS4     ", "-        ", .FALSE., .TRUE.,  .TRUE.), &
    pf_nuopc_fld_type("liquid_fraction_of_soil_moisture        ", &
      "SH2O       ", "-        ",  .TRUE., .FALSE.,  .TRUE.), &
    pf_nuopc_fld_type("liquid_fraction_of_soil_moisture_layer_1", &
      "SH2O1      ", "-        ", .FALSE., .FALSE.,  .TRUE.), &
    pf_nuopc_fld_type("liquid_fraction_of_soil_moisture_layer_2", &
      "SH2O2      ", "-        ", .FALSE., .FALSE.,  .TRUE.), &
    pf_nuopc_fld_type("liquid_fraction_of_soil_moisture_layer_3", &
      "SH2O3      ", "-        ", .FALSE., .FALSE.,  .TRUE.), &
    pf_nuopc_fld_type("liquid_fraction_of_soil_moisture_layer_4", &
      "SH2O4      ", "-        ", .FALSE., .FALSE.,  .TRUE.) /)

  integer                        :: pf_nz           = -1
  integer                        :: pf_cplnz        = -1
  real, allocatable              :: pf_cpldz(:)
  real(ESMF_KIND_R4), pointer    :: i_m(:,:,:)   => null()
  real(ESMF_KIND_R4), pointer    :: i_prs(:,:,:) => null()
  real(ESMF_KIND_R4), pointer    :: i_sat(:,:,:) => null()
  real(ESMF_KIND_R4), pointer    :: i_gws_est(:,:) => null()
  real(ESMF_KIND_R4), pointer    :: i_f_low(:,:) => null()
  real(ESMF_KIND_R4), pointer    :: i_f_high(:,:) => null()
  real(ESMF_KIND_R4), pointer    :: i_f_zwt(:,:) => null()
  real(ESMF_KIND_R4), pointer    :: i_zwt_low(:,:) => null()
  real(ESMF_KIND_R4), pointer    :: i_zwt_high(:,:) => null()
  real(ESMF_KIND_R4), pointer    :: i_zwt_curr(:,:) => null()

  interface create_internal_field
    module procedure create_internal_field_2d
    module procedure create_internal_field_3d
    module procedure create_internal_field_mk
  end interface

  interface destroy_internal_field
    module procedure destroy_internal_field_2d
    module procedure destroy_internal_field_3d
    module procedure destroy_internal_field_mk
  end interface

  public pf_flux
  public pf_gws
  public pf_porosity
  public pf_pressure
  public pf_pressurec
  public pf_saturation
  public pf_smois
  public pf_specific
  public pf_sres
  public pf_ssat
  public pf_alpha
  public pf_n
  public pf_zmult
  public pf_dz
  public pf_zwt
  public pf_zwt_min
  public pf_zwt_max
  public pf_mask
  public pf_nuopc_fld_list
  public field_init_metadata
  public field_init_internal
  public field_fin_internal
  public field_advertise
  public field_realize
  public field_advertise_log
  public field_realize_log
  public field_fill_state
  public field_init_zwt
  public field_prep_import
  public field_prep_export

  !-----------------------------------------------------------------------------
  contains
  !-----------------------------------------------------------------------------

  subroutine field_dictionary_add(fieldList, rc)
    type(pf_nuopc_fld_type), intent(in) :: fieldList(:)
    integer, intent(out) :: rc
    ! local variables
    integer :: n
    logical :: isPresent

    rc = ESMF_SUCCESS

    do n=lbound(fieldList,1),ubound(fieldList,1)
      isPresent = NUOPC_FieldDictionaryHasEntry( &
        fieldList(n)%sd_name, rc=rc)
      if (ESMF_STDERRORCHECK(rc)) return  ! bail out
      if (.not.isPresent) then
        call NUOPC_FieldDictionaryAddEntry( &
          StandardName=trim(fieldList(n)%sd_name), &
          canonicalUnits=trim(fieldList(n)%units), &
          rc=rc)
        if (ESMF_STDERRORCHECK(rc)) return  ! bail out
      end if
    end do

  end subroutine

  !-----------------------------------------------------------------------------
  subroutine field_init_metadata(init_nz, init_cplnz, init_cpldz, rc)
    integer, intent(in) :: init_nz
    integer, intent(in) :: init_cplnz
    real, intent(in)    :: init_cpldz(:)
    integer, intent(out) :: rc

    rc = ESMF_SUCCESS

    pf_nz = init_nz
    pf_cplnz = init_cplnz
    allocate(pf_cpldz(size(init_cpldz)), stat=rc)
    if (rc /= 0) then
      call ESMF_LogSetError(ESMF_RC_MEM_ALLOCATE, msg="allocating pf_cpldz", &
        line=__LINE__,file=__FILE__,rcToReturn=rc); return  ! bail out
    endif
    pf_cpldz = init_cpldz

  end subroutine

  !-----------------------------------------------------------------------------

  subroutine field_init_internal(internalFB, grid, rc)
    type(ESMF_FieldBundle), intent(inout) :: internalFB
    type(ESMF_Grid), intent(in)           :: grid
    integer, intent(out)                  :: rc
    ! local variables
    logical :: isCreated
    integer :: fsize(2)

    rc = ESMF_SUCCESS

    ! check that metadata has been initialized
    if (pf_nz <= 0) then
      call ESMF_LogSetError(ESMF_RC_NOT_SET, msg="pf_nz not initialized", &
        line=__LINE__,file=__FILE__,rcToReturn=rc)
      return  ! bail out
    endif

    ! create internal fields
    call create_internal_field(pf_flux, grid, pf_nz, "pf_flux", rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call create_internal_field(pf_gws, grid, "pf_gws", rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call create_internal_field(pf_gws_min, grid, "pf_gws_min", rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call create_internal_field(pf_gws_max, grid, "pf_gws_max", rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call create_internal_field(pf_porosity, grid, pf_nz, "pf_porosity", rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call create_internal_field(pf_pressure, grid, pf_nz, "pf_pressure", rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call create_internal_field(pf_pressurec, grid, pf_nz, "pf_pressurec", rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call create_internal_field(pf_saturation, grid, pf_nz, "pf_saturation", rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call create_internal_field(pf_smois, grid, pf_nz, "pf_smois", rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call create_internal_field(pf_specific, grid, pf_nz, "pf_specific", rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call create_internal_field(pf_sres, grid, pf_nz, "pf_sres", rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call create_internal_field(pf_ssat, grid, pf_nz, "pf_ssat", rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call create_internal_field(pf_alpha, grid, pf_nz, "pf_alpha", rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call create_internal_field(pf_n, grid, pf_nz, "pf_n", rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call create_internal_field(pf_zmult, grid, pf_nz, "pf_zmult", rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call create_internal_field(pf_dz, grid, pf_nz, "pf_dz", rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call create_internal_field(pf_zwt, grid, "pf_zwt", rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call create_internal_field(pf_zwt_min, grid, "pf_zwt_min", rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call create_internal_field(pf_zwt_max, grid, "pf_zwt_max", rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call create_internal_field(pf_mask, grid, "pf_mask", rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out

    ! allocate temporary fields
    call ESMF_GridGetFieldBounds(grid, totalCount=fsize, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    allocate(i_m(fsize(1), pf_nz, fsize(2)))
    allocate(i_prs(fsize(1), pf_nz, fsize(2)))
    allocate(i_sat(fsize(1), pf_nz, fsize(2)))
    allocate(i_gws_est(fsize(1), fsize(2)))
    allocate(i_f_low(fsize(1), fsize(2)))
    allocate(i_f_high(fsize(1), fsize(2)))
    allocate(i_f_zwt(fsize(1), fsize(2)))
    allocate(i_zwt_low(fsize(1), fsize(2)))
    allocate(i_zwt_high(fsize(1), fsize(2)))
    allocate(i_zwt_curr(fsize(1), fsize(2)))

    ! add fields to internal field bundle
    isCreated = ESMF_FieldBundleIsCreated(internalFB, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    if (.not. isCreated) then
      internalFB = ESMF_FieldBundleCreate(name="PF_INTERNAL", rc=rc)
      if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    endif
    call ESMF_FieldBundleAdd(internalFB, fieldList=(/ pf_flux%efld, &
      pf_gws%efld, pf_porosity%efld, &
      pf_pressure%efld, pf_pressurec%efld, pf_saturation%efld, &
      pf_smois%efld, pf_specific%efld, pf_sres%efld, pf_ssat%efld, &
      pf_alpha%efld, pf_n%efld, pf_zmult%efld, pf_dz%efld, &
      pf_zwt%efld, pf_zwt_min%efld, pf_zwt_max%efld, pf_mask%efld/), &
      rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out

  end subroutine

  !-----------------------------------------------------------------------------

  subroutine field_fin_internal(internalFB, rc)
    type(ESMF_FieldBundle), intent(inout) :: internalFB
    integer, intent(out)                  :: rc
    ! local variables
    logical :: isCreated

    rc = ESMF_SUCCESS

    ! destroy internal fields
    call destroy_internal_field(pf_flux, rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call destroy_internal_field(pf_gws, rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call destroy_internal_field(pf_gws_min, rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call destroy_internal_field(pf_gws_max, rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call destroy_internal_field(pf_porosity, rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call destroy_internal_field(pf_pressure, rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call destroy_internal_field(pf_pressurec, rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call destroy_internal_field(pf_saturation, rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call destroy_internal_field(pf_smois, rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call destroy_internal_field(pf_specific, rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call destroy_internal_field(pf_sres, rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call destroy_internal_field(pf_ssat, rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call destroy_internal_field(pf_alpha, rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call destroy_internal_field(pf_n, rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call destroy_internal_field(pf_zmult, rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call destroy_internal_field(pf_dz, rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call destroy_internal_field(pf_zwt, rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call destroy_internal_field(pf_zwt_min, rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call destroy_internal_field(pf_zwt_max, rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call destroy_internal_field(pf_mask, rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out

    deallocate(i_m)
    deallocate(i_prs)
    deallocate(i_sat)
    deallocate(i_gws_est)
    deallocate(i_f_low)
    deallocate(i_f_high)
    deallocate(i_f_zwt)
    deallocate(i_zwt_low)
    deallocate(i_zwt_high)
    deallocate(i_zwt_curr)

    ! destroy internal field bundle
    isCreated = ESMF_FieldBundleIsCreated(internalFB, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    if (isCreated) then
      call ESMF_FieldBundleDestroy(internalFB, rc=rc)
      if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    endif

    deallocate(pf_cpldz)
    pf_cplnz = -1
    pf_nz = -1

  end subroutine

  !-----------------------------------------------------------------------------

  subroutine create_internal_field_2d(field, grid, field_name, rc)
    type(pf_fld_2d_type), intent(inout) :: field
    type(ESMF_Grid), intent(in)         :: grid
    character(*), intent(in)            :: field_name
    integer, intent(out)                :: rc

    rc = ESMF_SUCCESS

    if (associated(field%efld)) then
      call ESMF_LogSetError(ESMF_RC_OBJ_CREATE, &
        msg=trim(field_name)//" exists", &
        line=__LINE__,file=__FILE__,rcToReturn=rc)
      return  ! bail out
    endif

    allocate(field%efld)
    field%efld = ESMF_FieldCreate(grid=grid, &
      typekind=ESMF_TYPEKIND_FIELD, &
      name=field%fname, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call ESMF_FieldGet(field%efld, farrayPtr=field%ptr, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call ESMF_FieldFill(field%efld, dataFillScheme="const", &
      const1=ESMF_DEFAULT_VALUE, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return
  end subroutine

  !-----------------------------------------------------------------------------

  subroutine create_internal_field_3d(field, grid, layers, field_name, rc)
    type(pf_fld_3d_type), intent(inout) :: field
    type(ESMF_Grid), intent(in)         :: grid
    integer, intent(in)                 :: layers
    character(*), intent(in)            :: field_name
    integer, intent(out)                :: rc

    rc = ESMF_SUCCESS

    if (associated(field%efld)) then
      call ESMF_LogSetError(ESMF_RC_OBJ_CREATE, &
        msg=trim(field_name)//" exists", &
        line=__LINE__,file=__FILE__,rcToReturn=rc)
      return  ! bail out
    endif

    allocate(field%efld)
    field%efld = ESMF_FieldCreate(grid=grid, &
      typekind=ESMF_TYPEKIND_FIELD, &
      gridToFieldMap=(/1,3/), &
      ungriddedLBound=(/1/), &
      ungriddedUBound=(/layers/), &
      name=field%fname, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call ESMF_FieldGet(field%efld, farrayPtr=field%ptr, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call ESMF_FieldFill(field%efld, dataFillScheme="const", &
      const1=ESMF_DEFAULT_VALUE, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return
  end subroutine

  !-----------------------------------------------------------------------------

  subroutine create_internal_field_mk(field, grid, field_name, rc)
    type(pf_fld_mk_type), intent(inout) :: field
    type(ESMF_Grid), intent(in)         :: grid
    character(*), intent(in)            :: field_name
    integer, intent(out)                :: rc

    rc = ESMF_SUCCESS

    if (associated(field%efld)) then
      call ESMF_LogSetError(ESMF_RC_OBJ_CREATE, &
        msg=trim(field_name)//" exists", &
        line=__LINE__,file=__FILE__,rcToReturn=rc)
      return  ! bail out
    endif

    allocate(field%efld)
    field%efld = ESMF_FieldCreate(grid=grid, &
      typekind=ESMF_TYPEKIND_I4, &
      name=field%fname, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call ESMF_FieldGet(field%efld, farrayPtr=field%ptr, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call ESMF_GridGetItem(grid, itemflag=ESMF_GRIDITEM_MASK, &
      farrayPtr=field%ptr, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return
  end subroutine

  !-----------------------------------------------------------------------------

  subroutine destroy_internal_field_2d(field, rc)
    type(pf_fld_2d_type), intent(inout) :: field
    integer, intent(out)                :: rc

    rc = ESMF_SUCCESS

    if (.not. associated(field%efld)) return
    call ESMF_FieldDestroy(field%efld, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    deallocate(field%efld)
  end subroutine

  !-----------------------------------------------------------------------------

  subroutine destroy_internal_field_3d(field, rc)
    type(pf_fld_3d_type), intent(inout) :: field
    integer, intent(out)                :: rc

    rc = ESMF_SUCCESS

    if (.not. associated(field%efld)) return
    call ESMF_FieldDestroy(field%efld, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    deallocate(field%efld)
  end subroutine

  !-----------------------------------------------------------------------------

  subroutine destroy_internal_field_mk(field, rc)
    type(pf_fld_mk_type), intent(inout) :: field
    integer, intent(out)                :: rc

    rc = ESMF_SUCCESS

    if (.not. associated(field%efld)) return
    call ESMF_FieldDestroy(field%efld, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    deallocate(field%efld)
  end subroutine

  !-----------------------------------------------------------------------------

  subroutine field_realize(fieldList, importState, exportState, grid, &
    realizeAllImport, realizeAllExport, rc)
    type(pf_nuopc_fld_type), intent(inout) :: fieldList(:)
    type(ESMF_State), intent(inout)        :: importState
    type(ESMF_State), intent(inout)        :: exportState
    type(ESMF_Grid), intent(in)            :: grid
    logical, intent(in)                    :: realizeAllImport
    logical, intent(in)                    :: realizeAllExport
    integer, intent(out)                   :: rc
    ! local variables
    integer :: n
    logical :: realizeImport
    logical :: realizeExport
    type(ESMF_Field) :: field_import
    type(ESMF_Field) :: field_export
    real(ESMF_KIND_FIELD), pointer :: ptr_import(:,:,:)

    rc = ESMF_SUCCESS

    ! check that metadata has been initialized
    if (pf_cplnz <= 0) then
      call ESMF_LogSetError(ESMF_RC_NOT_SET, msg="pf_cplnz not initialized", &
        line=__LINE__,file=__FILE__,rcToReturn=rc)
      return  ! bail out
    endif

    do n=lbound(fieldList,1),ubound(fieldList,1)

      ! check realize import
      if (fieldList(n)%ad_import) then
        if (realizeAllImport) then
          realizeImport = .true.
        else
          realizeImport = NUOPC_IsConnected(importState, &
            fieldName=trim(fieldList(n)%st_name),rc=rc)
          if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        endif
      else
        realizeImport = .false.
      end if
      ! check realize export
      if (fieldList(n)%ad_export) then
        if (realizeAllExport) then
          realizeExport = .true.
        else
          realizeExport = NUOPC_IsConnected(exportState, &
            fieldName=trim(fieldList(n)%st_name),rc=rc)
          if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        endif
      else
        realizeExport = .false.
      end if
      ! create import field
      if ( realizeImport ) then
        if (fieldList(n)%layers) then
          field_import = ESMF_FieldCreate(grid=grid, &
            typekind=ESMF_TYPEKIND_FIELD, &
            gridToFieldMap=(/1,3/), &
            ungriddedLBound=(/1/), &
            ungriddedUBound=(/pf_cplnz/), &
            name=fieldList(n)%st_name, rc=rc)
          if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        else
          field_import = ESMF_FieldCreate(grid=grid, &
            typekind=ESMF_TYPEKIND_FIELD, &
            name=fieldList(n)%st_name, rc=rc)
          if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        endif
        call NUOPC_Realize(importState, field=field_import, rc=rc)
        if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        fieldList(n)%rl_import = .true.
      else
        call ESMF_StateRemove(importState, (/fieldList(n)%st_name/), &
          relaxedflag=.true., rc=rc)
        if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        fieldList(n)%rl_import = .false.
      end if
      ! create export field
      if( realizeExport ) then
        if (fieldList(n)%layers) then
          field_export = ESMF_FieldCreate(grid=grid, &
            typekind=ESMF_TYPEKIND_FIELD, &
            gridToFieldMap=(/1,3/), &
            ungriddedLBound=(/1/), &
            ungriddedUBound=(/pf_cplnz/), &
            name=fieldList(n)%st_name, rc=rc)
          if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        else
          field_export = ESMF_FieldCreate(grid=grid, &
            typekind=ESMF_TYPEKIND_FIELD, &
            name=fieldList(n)%st_name, rc=rc)
          if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        endif
        call NUOPC_Realize(exportState, field=field_export, rc=rc)
        if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        fieldList(n)%rl_export = .true.
      else
        call ESMF_StateRemove(exportState, (/fieldList(n)%st_name/), &
          relaxedflag=.true., rc=rc)
        if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        fieldList(n)%rl_export = .false.
      end if

    end do

  end subroutine

  !-----------------------------------------------------------------------------

  subroutine field_advertise(fieldList, importState, exportState, &
  transferOffer, rc)
    type(pf_nuopc_fld_type), intent(in) :: fieldList(:)
    type(ESMF_State), intent(inout)     :: importState
    type(ESMF_State), intent(inout)     :: exportState
    character(*), intent(in),optional   :: transferOffer
    integer, intent(out)                :: rc
    ! local variables
    integer :: n

    rc = ESMF_SUCCESS

    do n=lbound(fieldList,1),ubound(fieldList,1)
      if (fieldList(n)%ad_import) then
        call NUOPC_Advertise(importState, &
          StandardName=fieldList(n)%sd_name, &
          Units=fieldList(n)%units, &
          TransferOfferGeomObject=transferOffer, &
          name=fieldList(n)%st_name, &
          rc=rc)
        if (ESMF_STDERRORCHECK(rc)) return  ! bail out
      end if
      if (fieldList(n)%ad_export) then
        call NUOPC_Advertise(exportState, &
          StandardName=fieldList(n)%sd_name, &
          Units=fieldList(n)%units, &
          TransferOfferGeomObject=transferOffer, &
          name=fieldList(n)%st_name, &
          rc=rc)
        if (ESMF_STDERRORCHECK(rc)) return  ! bail out
      end if
    end do

  end subroutine

  !-----------------------------------------------------------------------------

  subroutine field_advertise_log(fieldList, cname, rc)
    type(pf_nuopc_fld_type), intent(in) :: fieldList(:)
    character(*), intent(in)            :: cname
    integer, intent(out)                :: rc
    ! local variables
    integer                    :: cntImp
    integer                    :: cntExp
    integer                    :: n
    character(32)              :: label
    character(ESMF_MAXSTR)     :: logMsg

    rc = ESMF_SUCCESS

    label = trim(cname)

    ! count advertised import and export fields
    cntImp = 0
    cntExp = 0
    do n = lbound(fieldList,1), ubound(fieldList,1)
      if (fieldList(n)%ad_import) cntImp = cntImp + 1
      if (fieldList(n)%ad_export) cntExp = cntExp + 1
    enddo

    ! log advertised import fields
    write(logMsg,'(a,a,i0,a)') trim(label)//': ', &
      'List of advertised import fields(',cntImp,'):'
    call ESMF_LogWrite(trim(logMsg), ESMF_LOGMSG_INFO)
    write(logMsg,'(a,a5,a,a16,a,a)') trim(label)//': ', &
      'index',' ','name',' ','standardName'
    call ESMF_LogWrite(trim(logMsg), ESMF_LOGMSG_INFO)
    cntImp = 0
    do n=lbound(fieldList,1), ubound(fieldList,1)
      if (.NOT.fieldList(n)%ad_import) cycle
      cntImp = cntImp + 1
      write(logMsg,'(a,i5,a,a16,a,a)') trim(label)//': ', &
        cntImp,' ',trim(fieldList(n)%st_name), &
        ' ',trim(fieldList(n)%sd_name)
      call ESMF_LogWrite(trim(logMsg), ESMF_LOGMSG_INFO)
    enddo

    ! log advertised export fields
    write(logMsg,'(a,a,i0,a)') trim(label)//': ', &
      'List of advertised export fields(',cntExp,'):'
    call ESMF_LogWrite(trim(logMsg), ESMF_LOGMSG_INFO)
    write(logMsg,'(a,a5,a,a16,a,a)') trim(label)//': ', &
      'index',' ','name',' ','standardName'
    call ESMF_LogWrite(trim(logMsg), ESMF_LOGMSG_INFO)
    cntExp = 0
    do n=lbound(fieldList,1), ubound(fieldList,1)
      if (.NOT.fieldList(n)%ad_export) cycle
      cntExp = cntExp + 1
      write(logMsg,'(a,i5,a,a16,a,a)') trim(label)//': ', &
        cntExp,' ',trim(fieldList(n)%st_name), &
        ' ',trim(fieldList(n)%sd_name)
      call ESMF_LogWrite(trim(logMsg), ESMF_LOGMSG_INFO)
    enddo

  end subroutine

  !-----------------------------------------------------------------------------

  subroutine field_realize_log(fieldList, cname, rc)
    type(pf_nuopc_fld_type), intent(in) :: fieldList(:)
    character(*), intent(in)            :: cname
    integer, intent(out)                :: rc
    ! local variables
    integer                    :: cntImp
    integer                    :: cntExp
    integer                    :: n
    character(32)              :: label
    character(ESMF_MAXSTR)     :: logMsg

    rc = ESMF_SUCCESS

    label = trim(cname)

    ! count realized import and export fields
    cntImp = 0
    cntExp = 0
    do n = lbound(fieldList,1), ubound(fieldList,1)
      if (fieldList(n)%rl_import) cntImp = cntImp + 1
      if (fieldList(n)%rl_export) cntExp = cntExp + 1
    enddo

    ! log realized import fields
    write(logMsg,'(a,a,i0,a)') trim(label)//': ', &
      'List of realized import fields(',cntImp,'):'
    call ESMF_LogWrite(trim(logMsg), ESMF_LOGMSG_INFO)
    write(logMsg,'(a,a5,a,a16,a,a)') trim(label)//': ', &
      'index',' ','name',' ','standardName'
    call ESMF_LogWrite(trim(logMsg), ESMF_LOGMSG_INFO)
    cntImp = 0
    do n=lbound(fieldList,1), ubound(fieldList,1)
      if (.NOT.fieldList(n)%rl_import) cycle
      cntImp = cntImp + 1
      write(logMsg,'(a,i5,a,a16,a,a)') trim(label)//': ', &
        cntImp,' ',trim(fieldList(n)%st_name), &
        ' ',trim(fieldList(n)%sd_name)
      call ESMF_LogWrite(trim(LogMsg), ESMF_LOGMSG_INFO)
    enddo

    ! log realized export fields
    write(logMsg,'(a,a,i0,a)') trim(label)//': ', &
      'List of realized export fields(',cntExp,'):'
    call ESMF_LogWrite(trim(logMsg), ESMF_LOGMSG_INFO)
    write(logMsg,'(a,a5,a,a16,a,a)') trim(label)//': ', &
      'index',' ','name',' ','standardName'
    call ESMF_LogWrite(trim(logMsg), ESMF_LOGMSG_INFO)
    cntExp = 0
    do n=lbound(fieldList,1), ubound(fieldList,1)
      if (.NOT.fieldList(n)%rl_export) cycle
      cntExp = cntExp + 1
      write(logMsg,'(a,i5,a,a16,a,a)') trim(label)//': ', &
        cntExp,' ',trim(fieldList(n)%st_name), &
        ' ',trim(fieldList(n)%sd_name)
      call ESMF_LogWrite(trim(LogMsg), ESMF_LOGMSG_INFO)
    enddo

  end subroutine

  !-----------------------------------------------------------------------------

  subroutine field_find_standardname(fieldList, standardName, location, &
  defaultValue, rc)
    type(pf_nuopc_fld_type), intent(in)     :: fieldList(:)
    character(len=64), intent(in)           :: standardName
    integer, intent(out), optional          :: location
    real(ESMF_KIND_R8),intent(out),optional :: defaultValue
    integer, intent(out)                    :: rc
    ! local variables
    integer :: n

    rc = ESMF_RC_NOT_FOUND

    if (present(location)) location = lbound(fieldList,1) - 1
    if (present(defaultValue)) defaultValue = ESMF_DEFAULT_VALUE

    do n=lbound(fieldList,1),ubound(fieldList,1)
      if (fieldList(n)%sd_name .eq. standardName) then
        if (present(location)) location = n
        if (present(defaultValue)) defaultValue = fieldList(n)%vl_default
        rc = ESMF_SUCCESS
        return
      end if
    end do

    if (ESMF_LogFoundError(rcToCheck=rc, &
      msg="Field not found in fieldList "//trim(standardName), &
      line=__LINE__, &
      file=__FILE__)) &
      return  ! bail out

  end subroutine

  !-----------------------------------------------------------------------------

  subroutine field_find_statename(fieldList, stateName, location, &
  defaultValue, rc)
    type(pf_nuopc_fld_type), intent(in)     :: fieldList(:)
    character(len=64), intent(in)           :: stateName
    integer, intent(out), optional          :: location
    real(ESMF_KIND_R8),intent(out),optional :: defaultValue
    integer, intent(out)                    :: rc
    ! local variables
    integer :: n

    rc = ESMF_RC_NOT_FOUND

    if (present(location)) location = lbound(fieldList,1) - 1
    if (present(defaultValue)) defaultValue = ESMF_DEFAULT_VALUE

    do n=lbound(fieldList,1),ubound(fieldList,1)
      if (fieldList(n)%st_name .eq. stateName) then
        if (present(location)) location = n
        if (present(defaultValue)) defaultValue = fieldList(n)%vl_default
        rc = ESMF_SUCCESS
        return
      end if
    end do

    if (ESMF_LogFoundError(rcToCheck=rc, &
      msg="Field not found in fieldList "//trim(stateName), &
      line=__LINE__, &
      file=__FILE__)) &
      return  ! bail out

  end subroutine

  !-----------------------------------------------------------------------------

  subroutine field_fill_state(state, fill_type, fieldList, fillValue, &
  filePrefix, rc)
    type(ESMF_State), intent(inout)               :: state
    type(field_init_flag), intent(in)             :: fill_type
    type(pf_nuopc_fld_type), intent(in), optional :: fieldList(:)
    real(ESMF_KIND_R8), intent(in), optional      :: fillValue
    character(len=*), intent(in), optional        :: filePrefix
    integer, intent(out)                          :: rc
    ! local variables
    integer                                :: n
    integer                                :: itemCount
    character(len=64),allocatable          :: itemNameList(:)
    type(ESMF_StateItem_Flag), allocatable :: itemTypeList(:)
    type(ESMF_Field)                       :: field
    character(len=64)                      :: fldName
    real(ESMF_KIND_R8)                     :: defaultValue
    integer                                :: stat

    rc = ESMF_SUCCESS

    call ESMF_StateGet(state,itemCount=itemCount, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return ! bail out

    allocate(itemNameList(itemCount), stat=stat)
    if (ESMF_LogFoundAllocError(statusToCheck=stat, &
      msg="Allocation of state item name memory failed.", &
      line=__LINE__, file=__FILE__)) return  ! bail out
    allocate(itemTypeList(itemCount), stat=stat)
    if (ESMF_LogFoundAllocError(statusToCheck=stat, &
      msg="Allocation of state item type memory failed.", &
      line=__LINE__, file=__FILE__)) return  ! bail out

    call ESMF_StateGet(state,itemNameList=itemNameList, &
      itemTypeList=itemTypeList,rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return

    if ( fill_type .eq. FLD_INIT_ZERO ) then
      do n=1, itemCount
        if ( itemTypeList(n) == ESMF_STATEITEM_FIELD) then
          call ESMF_StateGet(state, field=field, &
            itemName=itemNameList(n),rc=rc)
          if (ESMF_STDERRORCHECK(rc)) return
          call ESMF_FieldFill(field, dataFillScheme="const", &
            const1=0.0_ESMF_KIND_R8, rc=rc)
          if (ESMF_STDERRORCHECK(rc)) return
          call NUOPC_SetAttribute(field, name="Updated", value="true", rc=rc)
          if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        endif
      enddo
    else if ( fill_type .eq. FLD_INIT_FILLV ) then
      if (.not. present(fillValue)) then
        call ESMF_LogSetError(ESMF_RC_ARG_BAD, &
          msg="Missing fillValue for FLD_INIT_FILLV.", &
          line=__LINE__,file=__FILE__,rcToReturn=rc)
        return  ! bail out
      end if
      do n=1, itemCount
        if ( itemTypeList(n) == ESMF_STATEITEM_FIELD) then
          call ESMF_StateGet(state, field=field, &
            itemName=itemNameList(n),rc=rc)
          if (ESMF_STDERRORCHECK(rc)) return
          call ESMF_FieldFill(field, dataFillScheme="const", &
            const1=fillValue, rc=rc)
          if (ESMF_STDERRORCHECK(rc)) return
          call NUOPC_SetAttribute(field, name="Updated", value="true", rc=rc)
          if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        endif
      enddo
    else if ( fill_type .eq. FLD_INIT_DEFAULT ) then
      if (.not. present(fieldList)) then
        call ESMF_LogSetError(ESMF_RC_ARG_BAD, &
          msg="Missing fieldList for FLD_INIT_DEFAULT.", &
          line=__LINE__,file=__FILE__,rcToReturn=rc)
        return  ! bail out
      end if
      do n=1, itemCount
        if ( itemTypeList(n) == ESMF_STATEITEM_FIELD) then
          call ESMF_StateGet(state, field=field, &
            itemName=itemNameList(n),rc=rc)
          if (ESMF_STDERRORCHECK(rc)) return
          call field_find_statename(fieldList, itemNameList(n), &
            defaultValue=defaultValue, rc=rc)
          if (ESMF_STDERRORCHECK(rc)) return
          call ESMF_FieldFill(field, dataFillScheme="const", &
            const1=defaultValue, rc=rc)
          if (ESMF_STDERRORCHECK(rc)) return
          call NUOPC_SetAttribute(field, name="Updated", value="true", rc=rc)
          if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        endif
      enddo
    else if ( fill_type .eq. FLD_INIT_FILE ) then
      if (.not. present(filePrefix)) then
        call ESMF_LogSetError(ESMF_RC_ARG_BAD, &
          msg="Missing filePrefix for FLD_INIT_FILE.", &
          line=__LINE__,file=__FILE__,rcToReturn=rc)
        return  ! bail out
      end if
      do n=1, itemCount
        if ( itemTypeList(n) == ESMF_STATEITEM_FIELD) then
          call ESMF_StateGet(state,field=field, &
            itemName=itemNameList(n),rc=rc)
          if (ESMF_STDERRORCHECK(rc)) return ! bail out
          call NUOPC_GetAttribute(field, name="StandardName", &
            value=fldName, rc=rc)
          if (ESMF_STDERRORCHECK(rc)) return ! bail out
          call ESMF_FieldRead(field, variableName=trim(fldName), &
            fileName=trim(filePrefix)//"_"//trim(itemNameList(n))//".nc", &
            iofmt=ESMF_IOFMT_NETCDF, rc=rc)
          if (ESMF_STDERRORCHECK(rc)) return ! bail out
          call NUOPC_SetAttribute(field, name="Updated", value="true", rc=rc)
          if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        endif
      enddo
    else
      call ESMF_LogSetError(ESMF_RC_NOT_IMPL, &
        msg="Unsupported fill_type for field_fill_state", &
        line=__LINE__,file=__FILE__,rcToReturn=rc)
      return  ! bail out
    end if

    deallocate(itemNameList)
    deallocate(itemTypeList)

  end subroutine field_fill_state

  !-----------------------------------------------------------------------------

  subroutine field_init_zwt(rc)
    integer, intent(out) :: rc

    ! local variables
    logical :: found
    integer :: i, j, k
    integer :: sat_idx

    rc = ESMF_SUCCESS

    pf_zwt%ptr(:,:) = 0.0

    do i = lbound(pf_zwt%ptr,1), ubound(pf_zwt%ptr,1)
    do j = lbound(pf_zwt%ptr,2), ubound(pf_zwt%ptr,2)
      if (pf_mask%ptr(i,j) == 1) then
        found = .false.
        do k = lbound(pf_pressure%ptr,2), ubound(pf_pressure%ptr,2)
          if (pf_pressure%ptr(i,k,j) >= 0.0) then
            sat_idx = k
            found = .true.
            exit
          end if
        end do
        if (found) then
           if (sat_idx > 2) then
             pf_zwt%ptr(i,j) = sum(pf_dz%ptr(i,1:sat_idx-1,j))
           endif
           pf_zwt%ptr(i,j) = pf_zwt%ptr(i,j) + (pf_dz%ptr(i,sat_idx,j) / 2.0)
        else
           pf_zwt%ptr(i,j) = sum(pf_dz%ptr(i,:,j))
        end if
      else
        pf_zwt%ptr(i,j) = 0.0_ESMF_KIND_R8
      end if
    end do
    end do

    pf_zwt_min%ptr = 0.0
    pf_zwt_max%ptr = sum(pf_dz%ptr(:,1:pf_nz,:), dim=2) ! soil column depth
    call calc_gws_from_zwt(pf_zwt_min%ptr, pf_gws_min%ptr)
    call calc_gws_from_zwt(pf_zwt_max%ptr, pf_gws_max%ptr)

  end subroutine field_init_zwt

  !-----------------------------------------------------------------------------

  subroutine field_prep_import(importState, forcType, rc)
    type(ESMF_State), intent(in)    :: importState
    type(forcing_flag), intent(out) :: forcType
    integer, intent(out)            :: rc

    ! local variables
    integer :: s_flx, s_flx1, s_flx2, s_flx3, s_flx4
    integer :: s_gws, s_smc1, s_smc2, s_smc3, s_smc4
    type(ESMF_Field) :: fld_imp_flux
    type(ESMF_Field) :: fld_imp_flux1
    type(ESMF_Field) :: fld_imp_flux2
    type(ESMF_Field) :: fld_imp_flux3
    type(ESMF_Field) :: fld_imp_flux4
    type(ESMF_Field) :: fld_imp_gws
    type(ESMF_Field) :: fld_imp_smois1
    type(ESMF_Field) :: fld_imp_smois2
    type(ESMF_Field) :: fld_imp_smois3
    type(ESMF_Field) :: fld_imp_smois4
    type(ESMF_Field) :: fld_imp_pcpdrp
    type(ESMF_Field) :: fld_imp_edir
    type(ESMF_Field) :: fld_imp_et
    real(c_float), pointer :: ptr_imp_flux(:, :, :)
    real(c_float), pointer :: ptr_imp_flux1(:, :)
    real(c_float), pointer :: ptr_imp_flux2(:, :)
    real(c_float), pointer :: ptr_imp_flux3(:, :)
    real(c_float), pointer :: ptr_imp_flux4(:, :)
    real(c_float), pointer :: ptr_imp_gws(:, :)
    real(c_float), pointer :: ptr_imp_smois1(:, :)
    real(c_float), pointer :: ptr_imp_smois2(:, :)
    real(c_float), pointer :: ptr_imp_smois3(:, :)
    real(c_float), pointer :: ptr_imp_smois4(:, :)
    real(c_float), pointer :: ptr_imp_pcpdrp(:, :)
    real(c_float), pointer :: ptr_imp_edir(:, :)
    real(c_float), pointer :: ptr_imp_et(:, :, :)
    type(ESMF_StateItem_Flag) :: itemType
    integer          :: i, k, iter
    real             :: tol, maxiter
    real, parameter  :: LVH2O = 2.501E+6 ! heat of vaporization
    real, parameter  :: CNVMH = (3600d0/1000d0) ! convert mm/s to m/h

    rc = ESMF_SUCCESS
    forcType = FORCING_ERROR

    ! check that metadata has been initialized
    if (pf_cplnz <= 0) then
      call ESMF_LogSetError(ESMF_RC_NOT_SET, msg="pf_cplnz not initialized", &
        line=__LINE__,file=__FILE__,rcToReturn=rc)
      return  ! bail out
    elseif (.not. allocated(pf_cpldz)) then
      call ESMF_LogSetError(ESMF_RC_NOT_SET, msg="pf_cpldz not initialized", &
        line=__LINE__,file=__FILE__,rcToReturn=rc)
      return  ! bail out
    endif

    ! check internal fields
    if(.not.associated(pf_flux%ptr)) then
      call ESMF_LogSetError(ESMF_RC_OBJ_INIT, msg="pf_flux missing", &
        line=__LINE__,file=__FILE__,rcToReturn=rc);  return  ! bail out
    endif

    ! search import for total water flux
    call ESMF_StateGet(importState, itemSearch="FLUX", &
      itemCount=s_flx, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    if (s_flx .gt. 0) then
      ! query import state for pf fields
      call ESMF_StateGet(importState, itemName="FLUX", &
        field=fld_imp_flux, rc=rc)
      if (ESMF_STDERRORCHECK(rc)) return  ! bail out
      call ESMF_FieldGet(fld_imp_flux, farrayPtr=ptr_imp_flux, rc=rc)
      if (ESMF_STDERRORCHECK(rc)) return  ! bail out
      do i=1, pf_cplnz
        pf_flux%ptr(:,i,:) = ptr_imp_flux(:,i,:) * CNVMH / pf_cpldz(i)
      enddo
      forcType = FORCING_WTRFLX3D
    else
      ! search import for total water flux (layers 1-4)
      call ESMF_StateGet(importState, itemSearch="FLUX1", &
        itemCount=s_flx1, rc=rc)
      if (ESMF_STDERRORCHECK(rc)) return  ! bail out
      call ESMF_StateGet(importState, itemSearch="FLUX2", &
        itemCount=s_flx2, rc=rc)
      if (ESMF_STDERRORCHECK(rc)) return  ! bail out
      call ESMF_StateGet(importState, itemSearch="FLUX3", &
        itemCount=s_flx3, rc=rc)
      if (ESMF_STDERRORCHECK(rc)) return  ! bail out
      call ESMF_StateGet(importState, itemSearch="FLUX4", &
        itemCount=s_flx4, rc=rc)
      if (ESMF_STDERRORCHECK(rc)) return  ! bail out
      if ((s_flx1.gt.0) .and. (s_flx2.gt.0) .and. &
          (s_flx3.gt.0) .and. (s_flx4.gt.0)) then
        if (pf_cplnz.ne.4) then
          call ESMF_LogSetError(ESMF_RC_NOT_IMPL, &
            msg="Unsupported number of coupled soil layers.", &
            line=__LINE__,file=__FILE__,rcToReturn=rc)
          return  ! bail out
        endif
        ! query import state for pf fields
        call ESMF_StateGet(importState, itemName="FLUX1", &
          field=fld_imp_flux1, rc=rc)
        if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        call ESMF_FieldGet(fld_imp_flux1, farrayPtr=ptr_imp_flux1, rc=rc)
        if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        call ESMF_StateGet(importState, itemName="FLUX2", &
          field=fld_imp_flux2, rc=rc)
        if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        call ESMF_FieldGet(fld_imp_flux2, farrayPtr=ptr_imp_flux2, rc=rc)
        if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        call ESMF_StateGet(importState, itemName="FLUX3", &
          field=fld_imp_flux3, rc=rc)
        if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        call ESMF_FieldGet(fld_imp_flux3, farrayPtr=ptr_imp_flux3, rc=rc)
        if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        call ESMF_StateGet(importState, itemName="FLUX4", &
          field=fld_imp_flux4, rc=rc)
        if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        call ESMF_FieldGet(fld_imp_flux4, farrayPtr=ptr_imp_flux4, rc=rc)
        if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        pf_flux%ptr(:,1,:) = ptr_imp_flux1 * CNVMH / pf_cpldz(1)
        pf_flux%ptr(:,2,:) = ptr_imp_flux2 * CNVMH / pf_cpldz(2)
        pf_flux%ptr(:,3,:) = ptr_imp_flux3 * CNVMH / pf_cpldz(3)
        pf_flux%ptr(:,4,:) = ptr_imp_flux4 * CNVMH / pf_cpldz(4)
        forcType = FORCING_WTRFLX2D
      else ! calculate total water flux
        ! query import state for pf fields
        call ESMF_StateGet(importState, itemName="PCPDRP", &
          field=fld_imp_pcpdrp, rc=rc)
        if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        call ESMF_FieldGet(fld_imp_pcpdrp, farrayPtr=ptr_imp_pcpdrp, rc=rc)
        if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        call ESMF_StateGet(importState, itemName="EDIR", &
          field=fld_imp_edir, rc=rc)
        if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        call ESMF_FieldGet(fld_imp_edir, farrayPtr=ptr_imp_edir, rc=rc)
        if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        call ESMF_StateGet(importState, itemName="ET", &
          field=fld_imp_et, rc=rc)
        if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        call ESMF_FieldGet(fld_imp_et, farrayPtr=ptr_imp_et, rc=rc)
        if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        ! calculate total water flux
        pf_flux%ptr(:,1,:) = (- ( (ptr_imp_edir(:,:) + ptr_imp_et(:,1,:)) &
                             / LVH2O ) - ptr_imp_pcpdrp(:,:) ) * &
                             CNVMH / pf_cpldz(1)
        do i=2, pf_cplnz
          pf_flux%ptr(:,i,:) = - (ptr_imp_et(:,i,:)/LVH2O) * CNVMH / pf_cpldz(i)
        enddo
        forcType = FORCING_COMPOSITE
      endif
    endif

    ! search import for ground water storage
    call ESMF_StateGet(importState, itemSearch="GWS", &
      itemCount=s_gws, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    if (s_gws .gt. 0) then
      ! query import state for pf fields
      call ESMF_StateGet(importState, itemName="GWS", &
        field=fld_imp_gws, rc=rc)
      if (ESMF_STDERRORCHECK(rc)) return  ! bail out
      call ESMF_FieldGet(fld_imp_gws, farrayPtr=ptr_imp_gws, rc=rc)
      if (ESMF_STDERRORCHECK(rc)) return  ! bail out
      pf_gws%ptr(:,:) = ptr_imp_gws(:,:)
    endif

    ! search import for soil moisture fraction (layers 1-4)
    call ESMF_StateGet(importState, itemSearch="SMOIS1", &
      itemCount=s_smc1, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call ESMF_StateGet(importState, itemSearch="SMOIS2", &
      itemCount=s_smc2, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call ESMF_StateGet(importState, itemSearch="SMOIS3", &
      itemCount=s_smc3, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    call ESMF_StateGet(importState, itemSearch="SMOIS4", &
      itemCount=s_smc4, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    if ((s_smc1.gt.0) .and. (s_smc2.gt.0) .and. &
        (s_smc3.gt.0) .and. (s_smc4.gt.0)) then
      if (pf_cplnz.ne.4) then
        call ESMF_LogSetError(ESMF_RC_NOT_IMPL, &
          msg="Unsupported number of coupled soil layers.", &
          line=__LINE__,file=__FILE__,rcToReturn=rc)
        return  ! bail out
      endif
      ! query import state for pf fields
      call ESMF_StateGet(importState, itemName="SMOIS1", &
        field=fld_imp_smois1, rc=rc)
      if (ESMF_STDERRORCHECK(rc)) return  ! bail out
      call ESMF_FieldGet(fld_imp_smois1, farrayPtr=ptr_imp_smois1, rc=rc)
      if (ESMF_STDERRORCHECK(rc)) return  ! bail out
      call ESMF_StateGet(importState, itemName="SMOIS2", &
        field=fld_imp_smois2, rc=rc)
      if (ESMF_STDERRORCHECK(rc)) return  ! bail out
      call ESMF_FieldGet(fld_imp_smois2, farrayPtr=ptr_imp_smois2, rc=rc)
      if (ESMF_STDERRORCHECK(rc)) return  ! bail out
      call ESMF_StateGet(importState, itemName="SMOIS3", &
        field=fld_imp_smois3, rc=rc)
      if (ESMF_STDERRORCHECK(rc)) return  ! bail out
      call ESMF_FieldGet(fld_imp_smois3, farrayPtr=ptr_imp_smois3, rc=rc)
      if (ESMF_STDERRORCHECK(rc)) return  ! bail out
      call ESMF_StateGet(importState, itemName="SMOIS4", &
        field=fld_imp_smois4, rc=rc)
      if (ESMF_STDERRORCHECK(rc)) return  ! bail out
      call ESMF_FieldGet(fld_imp_smois4, farrayPtr=ptr_imp_smois4, rc=rc)
      if (ESMF_STDERRORCHECK(rc)) return  ! bail out
      pf_smois%ptr(:,1,:) = ptr_imp_smois1
      pf_smois%ptr(:,2,:) = ptr_imp_smois2
      pf_smois%ptr(:,3,:) = ptr_imp_smois3
      pf_smois%ptr(:,4,:) = ptr_imp_smois4
    endif

    ! calculate pressure for coupled layers
    i_m(:,:,:) = 1-(1/pf_n%ptr(:,:,:))
    do i=1, pf_cplnz
      where (pf_mask%ptr(:,:) == 1)
        where (pf_smois%ptr(:,i,:) < pf_ssat%ptr(:,i,:))
          pf_pressurec%ptr(:,i,:) = -(1/pf_alpha%ptr(:,i,:)) * &
            ( ( ( ( (pf_smois%ptr(:,i,:)-pf_sres%ptr(:,i,:)) / &
                    (pf_ssat%ptr(:,i,:)-pf_sres%ptr(:,i,:)) ) &
                  ** (-1/i_m(:,i,:)) ) -1.0 ) ** (1/pf_n%ptr(:,i,:)) )
        elsewhere
          ! Saturated: pressure = 0
          pf_pressurec%ptr(:,i,:) = 0.0_ESMF_KIND_R4
        end where
      end where
    end do

    ! check to make sure GWS was imported
    if (s_gws .le. 0) then
      call ESMF_LogSetError(ESMF_RC_NOT_FOUND, &
        msg="GWS not found in importState", &
        line=__LINE__,file=__FILE__,rcToReturn=rc)
      return  ! bail out
    endif

    ! initialize internal arrays for bisection iteration
    i_f_low(:,:) = pf_gws_min%ptr(:,:) - pf_gws%ptr(:,:)
    i_f_high(:,:) = pf_gws_max%ptr(:,:) - pf_gws%ptr(:,:)
    i_zwt_low(:,:) = pf_zwt_min%ptr(:,:)
    i_zwt_high(:,:) = pf_zwt_max%ptr(:,:)
    i_zwt_curr(:,:) = pf_zwt%ptr(:,:)
    call calc_gws_from_zwt(pf_zwt%ptr, i_gws_est)

    ! user-defined parameters for bisection
    tol     = 1.0 ! tolerance
    maxiter = 10  ! max iteration count

    ! bisection iteration: adjust ZWT to match imported GWS
    iter = 0
    do while (iter < int(maxiter))
      iter = iter + 1
      call calc_gws_from_zwt(i_zwt_curr, i_gws_est)
      i_f_zwt = i_gws_est - pf_gws%ptr
      where (i_f_zwt * i_f_low < 0.0)
        i_zwt_high(:,:) = i_zwt_curr(:,:)
        i_f_high(:,:) = i_f_zwt
      elsewhere
        i_zwt_low(:,:) = i_zwt_curr(:,:)
        i_f_low(:,:) = i_f_zwt
      end where
      i_zwt_curr(:,:) = 0.5_ESMF_KIND_R4 * (i_zwt_low(:,:) + i_zwt_high(:,:))
      if (maxval(abs(i_gws_est - pf_gws%ptr)) <= tol) exit
    end do

    ! calculate pressure for non-coupled layers
    do k = pf_cplnz+1 , pf_nz
      where (pf_mask%ptr(:,:) == 1)
        pf_pressurec%ptr(:,k,:) = i_zwt_curr(:,:) - &
          sum(pf_dz%ptr(:,1:k,:), dim=2)
      end where
    end do

    pf_zwt%ptr(:,:) = i_zwt_curr(:,:)
  end subroutine

  subroutine calc_gws_from_zwt(zwt, gws_est)
    real(ESMF_KIND_R4), intent(in)  :: zwt(:,:)
    real(ESMF_KIND_R4), intent(out) :: gws_est(:,:)

    integer :: k

    i_prs(:,:,:) = pf_pressure%ptr(:,:,:)
    i_sat(:,:,:) = pf_saturation%ptr(:,:,:)
    i_m(:,:,:) = 1-(1/pf_n%ptr(:,:,:))

    do k = pf_cplnz+1, pf_nz
      i_prs(:,k,:) = zwt(:,:) - sum(pf_dz%ptr(:,1:k,:), dim=2)
      where ((pf_mask%ptr(:,:) == 1) .and. (i_prs(:,k,:) >= 0.0))
        i_sat(:,k,:) = 1.0_ESMF_KIND_R4
      elsewhere ((pf_mask%ptr(:,:) == 1) .and. (i_prs(:,k,:) < 0.0))
        i_sat(:,k,:) = (1.0_ESMF_KIND_R4 + &
          ((pf_alpha%ptr(:,k,:) * abs(i_prs(:,k,:))) &
          ** pf_n%ptr(:,k,:))) ** (-i_m(:,k,:))
      elsewhere
        i_prs(:,k,:) = 0.0_ESMF_KIND_R4
        i_sat(:,k,:) = 0.0_ESMF_KIND_R4
      end where
    end do
    where (pf_mask%ptr(:,:) == 1)
      gws_est(:,:) = &
        sum( &
          ( &
            (pf_porosity%ptr * i_sat) + &
            (pf_ssat%ptr * i_sat * i_prs) &
          ) * pf_dz%ptr, dim=2 &
        ) * 1000.0
    elsewhere
      gws_est(:,:) = 0.0_ESMF_KIND_R4
    end where

  end subroutine

  !-----------------------------------------------------------------------------

  subroutine field_prep_export(exportState, rc)
    type(ESMF_State), intent(inout) :: exportState
    integer, intent(out)            :: rc

    ! local variables
    type(ESMF_Field) :: fld_export
    real(c_float), pointer :: ptr_export2d(:, :)
    real(c_float), pointer :: ptr_export3d(:, :, :)
    integer                               :: stat
    integer                               :: itemCount
    integer                               :: iIndex
    character(len=64),allocatable         :: itemNameList(:)
    type(ESMF_StateItem_Flag),allocatable :: itemTypeList(:)
    integer                               :: i, j
    integer                               :: totalLBound(2)
    integer                               :: totalUBound(2)
    character(ESMF_MAXSTR)                :: logMsg

    rc = ESMF_SUCCESS

    ! check internal fields
    if(.not.associated(pf_pressure%ptr)) then
      call ESMF_LogSetError(ESMF_RC_OBJ_INIT, msg="pf_pressure missing", &
        line=__LINE__,file=__FILE__,rcToReturn=rc);  return  ! bail out
    endif
    if(.not.associated(pf_porosity%ptr)) then
      call ESMF_LogSetError(ESMF_RC_OBJ_INIT, msg="pf_porosity missing", &
        line=__LINE__,file=__FILE__,rcToReturn=rc);  return  ! bail out
    endif
    if(.not.associated(pf_saturation%ptr)) then
      call ESMF_LogSetError(ESMF_RC_OBJ_INIT, msg="pf_saturation missing", &
        line=__LINE__,file=__FILE__,rcToReturn=rc);  return  ! bail out
    endif
    if(.not.associated(pf_specific%ptr)) then
      call ESMF_LogSetError(ESMF_RC_OBJ_INIT, msg="pf_specific missing", &
        line=__LINE__,file=__FILE__,rcToReturn=rc);  return  ! bail out
    endif
    if(.not.associated(pf_zmult%ptr)) then
      call ESMF_LogSetError(ESMF_RC_OBJ_INIT, msg="pf_zmult missing", &
        line=__LINE__,file=__FILE__,rcToReturn=rc);  return  ! bail out
    endif
    if(.not.associated(pf_dz%ptr)) then
      call ESMF_LogSetError(ESMF_RC_OBJ_INIT, msg="pf_dz missing", &
        line=__LINE__,file=__FILE__,rcToReturn=rc);  return  ! bail out
    endif

    call ESMF_StateGet(exportState, itemCount=itemCount, rc=rc)
    if (ESMF_STDERRORCHECK(rc)) return  ! bail out
    if (itemCount > 0 ) then

      allocate(itemNameList(itemCount), itemTypeList(itemCount), stat=stat)
      if (ESMF_LogFoundAllocError(statusToCheck=stat, &
        msg="Allocation of item list memory failed.", &
        CONTEXT, rcToReturn=rc)) return  ! bail out
      call ESMF_StateGet(exportState, itemNameList=itemNameList, &
        itemTypeList=itemTypeList, rc=rc)
      if (ESMF_STDERRORCHECK(rc)) return  ! bail out

      do iIndex=1, itemCount
        if (itemTypeList(iIndex) == ESMF_STATEITEM_FIELD) then
          call ESMF_StateGet(exportState, field=fld_export, &
            itemName=itemNameList(iIndex), rc=rc)
          if (ESMF_STDERRORCHECK(rc)) return  ! bail out
          select case (itemNameList(iIndex))
            case ('PRESSURE')
              call ESMF_FieldGet(fld_export, farrayPtr=ptr_export3d, rc=rc)
              if (ESMF_STDERRORCHECK(rc)) return  ! bail out
              do i=1, pf_cplnz
                where (pf_mask%ptr(:,:) == 1)
                  ptr_export3d(:,i,:)=pf_pressure%ptr(:,i,:)
                elsewhere
                  ptr_export3d(:,i,:)=ESMF_DEFAULT_VALUE
                endwhere
              enddo
            case ('POROSITY')
              call ESMF_FieldGet(fld_export, farrayPtr=ptr_export3d, rc=rc)
              if (ESMF_STDERRORCHECK(rc)) return  ! bail out
              do i=1, pf_cplnz
                where (pf_mask%ptr(:,:) == 1)
                  ptr_export3d(:,i,:)=pf_porosity%ptr(:,i,:)
                elsewhere
                  ptr_export3d(:,i,:)=ESMF_DEFAULT_VALUE
                endwhere
              enddo
            case ('SATURATION')
              call ESMF_FieldGet(fld_export, farrayPtr=ptr_export3d, rc=rc)
              if (ESMF_STDERRORCHECK(rc)) return  ! bail out
              do i=1, pf_cplnz
                where (pf_mask%ptr(:,:) == 1)
                  ptr_export3d(:,i,:)=pf_saturation%ptr(:,i,:)
                elsewhere
                  ptr_export3d(:,i,:)=ESMF_DEFAULT_VALUE
                endwhere
              enddo
            case ('GWS')
              call ESMF_FieldGet(fld_export, farrayPtr=ptr_export2d, &
                totalLBound=totalLBound, totalUBound=totalUBound, rc=rc)
              if (ESMF_STDERRORCHECK(rc)) return  ! bail out
              do j=totalLBound(2), totalUBound(2)
              do i=totalLBound(1), totalUBound(1)
                if (pf_mask%ptr(i,j) == 1) then
                  ptr_export2d(i,j)=sum(((pf_porosity%ptr(i,pf_cplnz+1:pf_nz,j) * &
                                          pf_saturation%ptr(i,pf_cplnz+1:pf_nz,j)) + &
                                         (pf_pressure%ptr(i,pf_cplnz+1:pf_nz,j) * &
                                          pf_saturation%ptr(i,pf_cplnz+1:pf_nz,j) * &
                                          pf_specific%ptr(i,pf_cplnz+1:pf_nz,j))) * &
                                        pf_dz%ptr(i,pf_cplnz+1:pf_nz,j)) * &
                                    real(1000,ESMF_KIND_R4)
                else
                  ptr_export2d(i,j)=ESMF_DEFAULT_VALUE
                endif
              enddo
              enddo
            case ('SMOIS','SH2O')
              call ESMF_FieldGet(fld_export, farrayPtr=ptr_export3d, rc=rc)
              if (ESMF_STDERRORCHECK(rc)) return  ! bail out
              do i=1, pf_cplnz
                where (pf_mask%ptr(:,:) == 1)
                  ptr_export3d(:,i,:)=pf_saturation%ptr(:,i,:) * &
                    pf_porosity%ptr(:,i,:)
                elsewhere
                  ptr_export3d(:,i,:)=ESMF_DEFAULT_VALUE
                endwhere
              enddo
            case ('SMOIS1','SH2O1')
              call ESMF_FieldGet(fld_export, farrayPtr=ptr_export2d, rc=rc)
              if (ESMF_STDERRORCHECK(rc)) return  ! bail out
              where (pf_mask%ptr(:,:) == 1)
                ptr_export2d=pf_saturation%ptr(:,1,:) * pf_porosity%ptr(:,1,:)
              elsewhere
                ptr_export2d(:,:)=ESMF_DEFAULT_VALUE
              endwhere
            case ('SMOIS2','SH2O2')
              call ESMF_FieldGet(fld_export, farrayPtr=ptr_export2d, rc=rc)
              if (ESMF_STDERRORCHECK(rc)) return  ! bail out
              where (pf_mask%ptr(:,:) == 1)
                ptr_export2d=pf_saturation%ptr(:,2,:) * pf_porosity%ptr(:,2,:)
              elsewhere
                ptr_export2d(:,:)=ESMF_DEFAULT_VALUE
              endwhere
            case ('SMOIS3','SH2O3')
              call ESMF_FieldGet(fld_export, farrayPtr=ptr_export2d, rc=rc)
              if (ESMF_STDERRORCHECK(rc)) return  ! bail out
              where (pf_mask%ptr(:,:) == 1)
                ptr_export2d=pf_saturation%ptr(:,3,:) * pf_porosity%ptr(:,3,:)
              elsewhere
                ptr_export2d(:,:)=ESMF_DEFAULT_VALUE
              endwhere
            case ('SMOIS4','SH2O4')
              call ESMF_FieldGet(fld_export, farrayPtr=ptr_export2d, rc=rc)
              if (ESMF_STDERRORCHECK(rc)) return  ! bail out
              where (pf_mask%ptr(:,:) == 1)
                ptr_export2d=pf_saturation%ptr(:,4,:) * pf_porosity%ptr(:,4,:)
              elsewhere
                ptr_export2d(:,:)=ESMF_DEFAULT_VALUE
              endwhere
            case default
              call ESMF_LogSetError(ESMF_RC_NOT_IMPL, &
                msg="Unsupported export field: "//trim(itemNameList(iIndex)), &
                line=__LINE__,file=__FILE__,rcToReturn=rc)
              return  ! bail out
          endselect
          call NUOPC_SetAttribute(fld_export, name="Updated", &
            value="true", rc=rc)
          if (ESMF_STDERRORCHECK(rc)) return  ! bail out
        endif
      enddo

      deallocate(itemNameList)
      deallocate(itemTypeList)

    endif

  end subroutine field_prep_export

  !-----------------------------------------------------------------------------

end module parflow_nuopc_fields
