class Moose < Formula
  desc "MOOSE Framework"
  homepage "https://mooseframework.org"
  url "http://mooseframework.org/source_packages/moose-modules.tar.gz"
  sha256 "444cc515c75966135975ae439875c43001d9631a6c0c5ee2477d0eecf77e643b"
  revision 1

  keg_only "we want to leverage the module load command"
  depends_on "modules"
  depends_on "gcc"
  depends_on "llvm"
  depends_on "openmpi"
  depends_on "moose-ccache"

  def install
    llvm_clang = File.join("#{Formula["llvm"].opt_prefix}", "bin")
    # Append to moose-dev-clang module rather than create it from scratch. This way, we satisify the formula's need to having download something
    # (all formulas must have a URL or other resource to download)
    moose_dev_clang_module = """
prepend-path PATH #{llvm_clang}
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

    # Create moose_profile script
    moose_profile = """# MOOSE Framework sourcing script
source #{Formula["modules"].opt_prefix}/init/bash
source #{Formula["modules"].opt_prefix}/init/bash_completion
export MODULEPATH=$MODULEPATH:#{prefix}

# if moose environment is available, load the module
if [ -d #{Formula["moose"].opt_prefix} ]; then
  module load moose-dev-clang
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
