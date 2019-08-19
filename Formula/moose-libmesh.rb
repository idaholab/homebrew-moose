class MooseLibmesh < Formula
  desc "The libMesh library provides a framework for the numerical simulation of partial differential equations."
  homepage "https://libmesh.github.io/"
  url "https://github.com/libmesh/libMesh.git", :revision => "da98c0178b4d03f222d6b02c1a701eea8a38af5e"
  version "da98c01-5"

  bottle do
    root_url "https://mooseframework.org/source_packages"
    sha256 "abd92fac07d55cd018d74e371455b0f3d1311024b4bc92a79e231e927ac45cfd" => :mojave
    sha256 "699db953d7b902f210b5fc04c31e83ee4e79035e78255eb3c3672c8b12bd4f81" => :high_sierra
    sha256 "4568c6529e9303be9766114a092d411b10046af65c0204e2e7d1c29ac288eccb" => :sierra
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
    ENV.prepend "PATH", "#{Formula["llvm@7"].opt_prefix}/bin", ":"
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
    inreplace "#{prefix}/bin/libmesh-config", "return_val=\" $return_val\"", "return_val=\"-L#{Formula["llvm@7"].opt_prefix}/lib $return_val\""
  end

  test do
    system "make", "check"
  end
end
