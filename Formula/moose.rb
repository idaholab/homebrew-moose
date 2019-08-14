class Moose < Formula
  desc "MOOSE Framework"
  homepage "https://mooseframework.org"
  url "http://mooseframework.org/source_packages/moose-modules.tar.gz"
  sha256 "444cc515c75966135975ae439875c43001d9631a6c0c5ee2477d0eecf77e643b"
  revision 4

  keg_only "we want to leverage the module load command"
  depends_on "modules"
  depends_on "gcc"
  depends_on "llvm"
  depends_on "openmpi"
  depends_on "pkg-config"
  depends_on "moose-petsc"
  depends_on "moose-vtklite"
  depends_on "moose-libmesh"
  depends_on "moose-peacock"

  def install
    llvm_clang = File.join("#{Formula["llvm"].opt_prefix}", "bin")
    petsc_path = "#{Formula["moose-petsc"].opt_prefix}"
    libmesh_path = "#{Formula["moose-libmesh"].opt_prefix}"
    vtk_path = "#{Formula["moose-vtklite"].opt_prefix}"
    vtk_include = Dir["#{vtk_path}/include/vtk-*"].first
    vtk_lib = "#{vtk_path}/lib"
    # Append to moose-dev-clang module rather than create it from scratch. This way, we satisify the formula's need to having download something
    # (all formulas must have a URL or other resource to download)
    moose_dev_clang_module = """
prepend-path PATH #{llvm_clang}
prepend-path INCLUDE_PATH #{vtk_include}
setenv PETSC_DIR #{petsc_path}
setenv LIBMESH_DIR #{libmesh_path}
setenv VTKINCLUDE_DIR #{vtk_include}
setenv VTKLIB_DIR #{vtk_lib}
setenv OMPI_MCA_rmaps_base_oversubscribe 1
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

    # Create Peacock module
    python_path = "#{Formula["moose-vtk"].opt_prefix}/lib/python2.7/site-packages"
    peacock_module = """#%Module1.0#####################################################################
proc ModulesHelp { } {
  puts stderr \"Enables libraries needed for Peacock functionality.\"
}
if { ! [ info exists ::env(MOOSEPEACOCK) ] && [ module-info command load ] } {
  puts stderr \"You must first run: `pip install numpy scipy matplotlib pandas`\"
  puts stderr \"(and then reload your terminal) before using this feature\"
  exit 0
}
conflicts peacock3
prepend-path PYTHONPATH #{python_path}
"""
    open("#{prefix}/peacock", 'w') { |f|
      f << peacock_module
    }

    # Create Peacock3 module
    python3_path = "#{Formula["vtk"].opt_prefix}/lib/python3.7/site-packages"
    peacock_module = """#%Module1.0#####################################################################
proc ModulesHelp { } {
  puts stderr \"Enables libraries needed for Peacock functionality.\"
}
if { ! [ info exists ::env(MOOSEPEACOCK3) ] && [ module-info command load ] } {
  puts stderr \"You must first run: `pip3 install numpy scipy matplotlib pandas`\"
  puts stderr \"(and then reload your terminal) before using this feature\"
  exit 0
}
conflicts peacock
prepend-path PYTHONPATH #{python3_path}
"""
    open("#{prefix}/peacock3", 'w') { |f|
      f << peacock_module
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

# check if user applied the additional commands necessary to run peacock
if [ -d #{Formula["moose-peacock"].opt_prefix} ] && [ `pip list 2>/dev/null | grep -c \"matplotlib\\|scipy\\|numpy\\|pandas\"` -ge 4 ]; then
  export MOOSEPEACOCK=true
  module load peacock
fi

# check if user applied the additional commands necessary to run peacock3
if [ -d #{Formula["moose-peacock"].opt_prefix} ] && [ `pip list 2>/dev/null | grep -c \"matplotlib\\|scipy\\|numpy\\|pandas\"` -ge 4 ]; then
  export MOOSEPEACOCK3=true
fi

"""
    open("#{prefix}/moose_profile.sh", 'w') { |f|
      f << moose_profile
    }
  end

  test do
    File.file?("#{prefix}/moose-dev-clang")
    File.file?("#{prefix}/moose_profile.sh")
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
end
