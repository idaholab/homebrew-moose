class MoosePetsc < Formula
  desc "Portable, Extensible Toolkit for Scientific Computation (real)"
  homepage "https://www.mcs.anl.gov/petsc/"
  url "http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-3.11.3.tar.gz"
  sha256 "199ad9650a9f58603b49e7fff7cd003ceb03aa231e5d37d0bf0496c6348eca81"
  version "3.11.3-5"

  bottle do
    root_url "https://mooseframework.org/source_packages"
    sha256 "4852ae56a1ae369e73a8da041962d54ac1e0e64c32f5ddd7327bf6d08b60c190" => :mojave
    sha256 "dba5681208b7b991b9f586f4413f6f9bba12dca773eaa91e4bbe2448569d4294" => :high_sierra
    sha256 "e42d26dec6cb3d91dd263c2631e53c2197de488eaa93bbb17ed101e73c0d437e" => :sierra
  end

  keg_only "we want to leverage moose_profile logic"
  depends_on "cmake" => :build
  depends_on "python" => :build
  depends_on "gcc@8"
  depends_on "llvm@7"
  depends_on "openmpi"

  def install
    ENV.prepend "PATH", "#{Formula["llvm@7"].opt_prefix}/bin:#{Formula["gcc@8"].opt_prefix}/bin", ":"
    ENV["LDFLAGS"] = "-L#{Formula["llvm@7"].opt_prefix}/lib -Wl,-rpath,#{Formula["llvm@7"].opt_prefix}/lib"
    ENV["CPPFLAGS"] = "-I#{Formula["llvm@7"].opt_prefix}/include"
    ENV["OMPI_FC"] = "gfortran-8"
    ENV["CC"] = "mpicc"
    ENV["CXX"] = "mpicxx"
    ENV["F77"] = "mpif77"
    ENV["FC"] = "mpif90"
    ENV["CFLAGS"] = "-fPIC -fopenmp"
    ENV["CXXFLAGS"] = "-fPIC -fopenmp"
    ENV["FFLAGS"] = "-fPIC -fopenmp"
    ENV["FCFLAGS"] = "-fPIC -fopenmp"
    ENV["F90FLAGS"] = "-fPIC -fopenmp"
    ENV["F77FLAGS"] = "-fPIC -fopenmp"

    system "./configure", "--prefix=#{prefix}",
           "--download-hypre=1",
           "--with-x=0",
           "--with-ssl=0",
           "--with-debugging=no",
           "--with-pic=1",
           "--with-shared-libraries=1",
           "--with-cc=mpicc",
           "--with-cxx=mpicxx",
           "--with-fc=mpif90",
           "--download-fblaslapack=1",
           "--download-metis=1",
           "--download-ptscotch=1",
           "--download-parmetis=1",
           "--download-superlu_dist=1",
           "--download-mumps=1",
           "--download-scalapack=1",
           "--download-slepc=1",
           "--with-cxx-dialect=C++11",
           "--with-fortran-bindings=0",
           "--with-sowing=0"
    system "make", "all"
    system "make", "install"
  end

  test do
    test_case = "#{pkgshare}/examples/src/ksp/ksp/examples/tutorials/ex1.c"
    system "mpicc", test_case, "-I#{include}", "-L#{lib}", "-lpetsc", "-o", "test"
    output = shell_output("./test")
    # This PETSc example prints several lines of output. The last line contains
    # an error norm, expected to be small.
    line = output.lines.last
    assert_match /^Norm of error .+, Iterations/, line, "Unexpected output format"
    error = line.split[3].to_f
    assert (error >= 0.0 && error < 1.0e-13), "Error norm too large"
  end
end
