-- setup.m2
run "make"
if not fileExists "bin/full_pipeline" then error "Compilation failed."
print "full_pipeline successfully compiled."
