class MooseLibmesh < Formula
  desc "The libMesh library provides a framework for the numerical simulation of partial differential equations."
  homepage "https://libmesh.github.io/"
  url "https://github.com/libmesh/libMesh.git", :revision => "19e96cb6ce080554cb10910c3b49a0b3c7142403"
  version "19e96cb-1"

  bottle do
    root_url "https://mooseframework.org/source_packages"
    sha256 "bc003f94b44c19ff7b29638f2479ea4d7701eb126732a7cf430fd3bb7d16f793" => :mojave
    sha256 "bbce6df3ac4a8847f445829e0fc14a3aa8d00abb060c7566cded2a3520d74ea8" => :high_sierra
    sha256 "fc516c872e0f5e6801f0d3e78548462ab7b00950d53e3f7178dd10a7266010a3" => :sierra
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
