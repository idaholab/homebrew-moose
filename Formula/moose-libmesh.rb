class MooseLibmesh < Formula
  desc "The libMesh library provides a framework for the numerical simulation of partial differential equations."
  homepage "https://libmesh.github.io/"
  url "https://github.com/libmesh/libMesh.git", :revision => "da98c0178b4d03f222d6b02c1a701eea8a38af5e"
  version "da98c01-2"

  bottle do
    root_url "https://mooseframework.org/source_packages"
    sha256 "ab23e17c58818d151a9c6b8e63b5013618c223d8f4225f3c4447fafdd78e7c52" => :mojave
    sha256 "ff8f3a5e679c1ea889aa520a1c3fc9c739d217c42846af5f3153d27dd09fd733" => :high_sierra
    sha256 "b51501dadf16959bc0bd7c6f136589723d9c1c9478dc21950f9879480900f536" => :sierra
  end

  keg_only "we want to leverage moose_profile logic"
  depends_on "gcc"
  depends_on "llvm"
  depends_on "openmpi"
  depends_on "moose-petsc"
  depends_on "moose-vtklite"

  def install
    vtk_path = "#{Formula["moose-vtklite"].opt_prefix}"
    vtk_include = Dir["#{vtk_path}/include/vtk-*"].first
    vtk_lib = "#{vtk_path}/lib"
    methods = "opt dbg devel oprof"
    ENV["PETSC_DIR"] = "#{Formula["moose-petsc"].opt_prefix}"
    ENV["LDFLAGS"] = "-L#{Formula["llvm"].opt_prefix}/lib -Wl,-rpath,#{Formula["llvm"].opt_prefix}/lib"
    ENV["CPPFLAGS"] = "-I#{Formula["llvm"].opt_prefix}/include"
    ENV.prepend "PATH", "#{Formula["llvm"].opt_prefix}/bin", ":"
    ENV.prepend "VTKINCLUDE_DIR", "#{vtk_include}"
    ENV.prepend "VTKLIB_DIR", "#{vtk_lib}"
    ENV.prepend "INCLUDE_DIR", "#{vtk_include}"
    ENV["CC"] = "mpicc"
    ENV["CXX"] = "mpicxx"
    ENV["F77"] = "mpif77"
    ENV["FC"] = "mpif90"
    system "./configure", "--prefix=#{prefix}",
           "--with-methods=#{methods}",
           "--enable-silent-rules",
           "--enable-unique-id",
           "--disable-warnings",
           "--with-thread-model=openmp",
           "--disable-maintainer-mode",
           "--enable-petsc-hypre-required",
           "--enable-metaphysicl-required",
           "--with-vtk-lib=#{vtk_lib}",
           "--with-vtk-include=#{vtk_include}"
    system "make", "all"
    system "make", "install"

    # Fix libmesh-config to return a path to llvm's libs
    inreplace "#{prefix}/bin/libmesh-config", "return_val=\" $return_val\"", "return_val=\"-L#{Formula["llvm"].opt_prefix}/lib $return_val\""
  end

  test do
    system "make", "check"
  end
end
