# -----------------------------------------------------------------------------
# Adding test files
# -----------------------------------------------------------------------------

add_subdirectory(tcl)

if (${PARFLOW_ENABLE_ESMX})
  add_subdirectory(esmx)
endif()
