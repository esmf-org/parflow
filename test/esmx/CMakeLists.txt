# -----------------------------------------------------------------------------
# Adding ESMX tests
# -----------------------------------------------------------------------------

include(ParflowTest)

pf_add_esmx_test(
  NAME washita_dlnd CONFIG "esmxRunLW.yml" RANK 1
  FILES "Little_Washita.py" "esmxRunLW.yml" "washita_inputs" "fd.yml"
)
