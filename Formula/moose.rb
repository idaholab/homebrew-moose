class Moose < Formula
  desc "MOOSE Framework"
  homepage "https://mooseframework.org"
  url "http://mooseframework.org/source_packages/moose-modules.tar.gz"
  sha256 "444cc515c75966135975ae439875c43001d9631a6c0c5ee2477d0eecf77e643b"
  revision 15

  keg_only "we want to leverage the module load command"
  depends_on "modules"
  depends_on "gcc@8"
  depends_on "llvm@7"
  depends_on "openmpi"
  depends_on "python"
  depends_on "pkg-config"
  depends_on "moose-libmesh"
  depends_on "moose-peacock"

  def install
    llvm_clang = File.join("#{Formula["llvm@7"].opt_prefix}", "bin")
    gcc_gfortran = File.join("#{Formula["gcc@8"].opt_prefix}", "bin")
    petsc_path = "#{Formula["moose-petsc"].opt_prefix}"
    libmesh_path = "#{Formula["moose-libmesh"].opt_prefix}"
    vtk_path = "#{Formula["moose-vtklite"].opt_prefix}"
    vtk_include = Dir["#{vtk_path}/include/vtk-*"].first
    vtk_lib = "#{vtk_path}/lib"
    # Append to moose-dev-clang module rather than create it from scratch. This way, we satisify the formula's need to having download something
    # (all formulas must have a URL or other resource to download)
    moose_dev_clang_module = """
prepend-path PATH #{llvm_clang}:#{gcc_gfortran}
prepend-path INCLUDE_PATH #{vtk_include}
set-alias    python python3
setenv PETSC_DIR #{petsc_path}
setenv LIBMESH_DIR #{libmesh_path}
setenv VTKINCLUDE_DIR #{vtk_include}
setenv VTKLIB_DIR #{vtk_lib}
setenv OMPI_MCA_rmaps_base_oversubscribe 1
setenv OMPI_FC gfortran-8
setenv CC mpicc
setenv CXX mpicxx
setenv FC mpif90
setenv F90 mpif90
setenv F77 mpif77
"""
    open('moose-dev-clang', 'a') { |f|
      f << moose_dev_clang_module
    }
    cp "moose-dev-clang", "#{prefix}/moose-dev-clang"

    # Get Major/Minor python version for VTK/lib python directory
    pyver = Language::Python.major_minor_version "python3"
    py_prefix = Formula["python3"].opt_frameworks/"Python.framework/Versions/#{pyver}"

    # Create Peacock module
    python_path = "#{Formula["vtk"].opt_prefix}/lib/python#{pyver}/site-packages"
    peacock_module = """#%Module1.0#####################################################################
proc ModulesHelp { } {
  puts stderr \"Enables libraries needed for Peacock functionality.\"
}
if { ! [ info exists ::env(MOOSEPEACOCK) ] && [ module-info command load ] } {
  puts stderr \"In order to use Peacock (python3), perform the following:\"
  puts stderr \"\n\t`brew install moose-peacock`\"
  puts stderr \"\t`pip3 install scikit-image pandas`\n\"
  puts stderr \"Once complete, reload your terminals and verify this module\"
  puts stderr \"is loaded using `module list`.\"
  exit 0
}
prepend-path PYTHONPATH #{python_path}
"""
    open("#{prefix}/peacock", 'w') { |f|
      f << peacock_module
    }

    # Create vtk-mesa (off screen rendering) module
    vtkmesa_path = "#{Formula["moose-vtkmesa"].opt_prefix}/lib/python#{pyver}/site-packages"
    vtkmesa_module = """#%Module1.0#####################################################################
proc ModulesHelp { } {
  puts stderr \"Enables libraries needed for off-screen ImageDiff functionality.\"
  puts stderr \"Only useful to MOOSE GUI developers.\"
}
if { ! [ info exists ::env(MESA_OFFSCREEN) ] && [ module-info command load ] } {
  puts stderr \"In order to use off-screen rendering, perform the following:\"
  puts stderr \"\n\t`brew install moose-vtkmesa`\"
  puts stderr \"\t`pip3 install scikit-image pandas`\n\"
  puts stderr \"Once complete, reload your terminals and load this module again.\"
  puts stderr \"It may also first be necessary to unload the peacock module.\"
  exit 0
}
conflict peacock
prepend-path PYTHONPATH #{vtkmesa_path}
"""
    open("#{prefix}/mesa-offscreen", 'w') { |f|
      f << vtkmesa_module
    }

    # Create moose_profile script
    moose_profile = """# MOOSE Framework sourcing script
source #{Formula["modules"].opt_prefix}/init/bash
source #{Formula["modules"].opt_prefix}/init/bash_completion
export MODULEPATH=$MODULEPATH:#{prefix}

# if moose environment is available, load the module
if [ -d #{Formula["moose"].opt_prefix} ]; then
  module load moose-dev-clang
fi

# Determine if VTK/Peacock, can load or can be loaded
if [ -d #{Formula["moose-peacock"].opt_prefix} ] || [ -d #{Formula["moose-vtkmesa"].opt_prefix} ]; then
  PIP='pip3'
fi

# The third-party packages required for Peacock/ImageDIFF
if [ -n \"$PIP\" ]; then
  GUI=`$PIP list 2>/dev/null | grep -c \"matplotlib\\|scipy\\|numpy\\|pandas\"`
else
  GUI=0
fi

# check if user applied the additional commands necessary to run Peacock
if [ -d #{Formula["moose-peacock"].opt_prefix} ] && [ $GUI -ge 4 ]; then
  export MOOSEPEACOCK=true
  module load peacock
fi

# check if user applied the additional commands necessary to run mesa-offscreen
if [ -d #{Formula["moose-vtkmesa"].opt_prefix} ] && [ $GUI -ge 4 ]; then
  export MESA_OFFSCREEN=true
fi
"""
    open("#{prefix}/moose_profile.sh", 'w') { |f|
      f << moose_profile
    }
  end
  def caveats
    <<~EOS
      You must now source the moose_profile.sh script to activate the environment:

         source #{prefix}/moose_profile.sh

      Or you can add the following to your ~/.bash_profile to have the above performed
      automatically (if you have not done so already):

         echo "if [ -f #{prefix}/moose_profile.sh ]; then source #{prefix}/moose_profile.sh; fi" >> ~/.bash_profile

    EOS
  end
  test do
    File.file?("#{prefix}/moose-dev-clang")
    File.file?("#{prefix}/moose_profile.sh")
  end
end
