class MooseLibmesh < Formula
  desc "The libMesh library provides a framework for the numerical simulation of partial differential equations."
  homepage "https://libmesh.github.io/"
  url "https://github.com/libmesh/libMesh.git", :revision => "19e96cb6ce080554cb10910c3b49a0b3c7142403"
  version "19e96cb-1"

  bottle do
    root_url "https://mooseframework.org/source_packages"
    sha256 "596f2cc9b0fc6e0241c79bbff2bc640fbadfa6cd0d20377c735d08bdfc7f9ba7" => :mojave
    sha256 "9eafb12ad7f9553bab469b5d0d6810d48fd1db3068cdcf579fb996a0cb09663f" => :high_sierra
    sha256 "ebe0411e1b61f5bd14411bcd735ef2efb3ce72cb1cf477f83c02ac5e81358e3d" => :sierra
  end

  keg_only "we want to leverage moose_profile logic"
  depends_on "gcc@8"
  depends_on "llvm@7"
  depends_on "openmpi"
  depends_on "moose-petsc"
  depends_on "moose-vtklite"

  def install
    vtk_path = "#{Formula["moose-vtklite"].opt_prefix}"
    vtk_include = Dir["#{vtk_path}/include/vtk-*"].first
    vtk_lib = "#{vtk_path}/lib"
    methods = "opt dbg devel oprof"
    ENV["PETSC_DIR"] = "#{Formula["moose-petsc"].opt_prefix}"
    ENV["LDFLAGS"] = "-L#{Formula["llvm@7"].opt_prefix}/lib -Wl,-rpath,#{Formula["llvm@7"].opt_prefix}/lib"
    ENV["CPPFLAGS"] = "-I#{Formula["llvm@7"].opt_prefix}/include"
    ENV["OMPI_FC"] = "gfortran-8"
    ENV.prepend "PATH", "#{Formula["llvm@7"].opt_prefix}/bin:#{Formula["gcc@8"].opt_prefix}/bin", ":"
    ENV.prepend "VTKINCLUDE_DIR", "#{vtk_include}"
    ENV.prepend "VTKLIB_DIR", "#{vtk_lib}"
    ENV.prepend "INCLUDE_DIR", "#{vtk_include}"
    ENV["CC"] = "mpicc"
    ENV["CXX"] = "mpicxx"
    ENV["F77"] = "mpif77"
    ENV["FC"] = "mpif90"
    args = %W[
    --prefix=#{prefix}
    --with-methods=#{methods}
    --enable-silent-rules
    --enable-unique-id
    --disable-warnings
    --enable-glibcxx-debugging
    --with-thread-model=openmp
    --disable-maintainer-mode
    --enable-petsc-hypre-required
    --enable-metaphysicl-required
    --with-vtk-lib=#{vtk_lib}
    --with-vtk-include=#{vtk_include}
    ]
    system "./configure", *args
    system "make", "all"
    system "make", "install"

    # Fix libmesh-config to return a path to llvm's libs
    inreplace "#{prefix}/bin/libmesh-config", "return_val=\" $return_val\"", "return_val=\"-L#{Formula["llvm@7"].opt_prefix}/lib $return_val\""
  end

  test do
    system "make", "check"
  end
end
