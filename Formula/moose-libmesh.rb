class MooseLibmesh < Formula
  desc "The libMesh library provides a framework for the numerical simulation of partial differential equations."
  homepage "https://libmesh.github.io/"
  url "https://github.com/libmesh/libMesh.git", :revision => "f3dd9fee71b1f4636bc3ac8348aab6595984a223"
  version "f3dd9fe-3"

  bottle do
    root_url "https://mooseframework.org/source_packages"
    sha256 "65e2971bd0480ef3eb36d443a0106d514aa864e0362af68f272d19348c106524" => :mojave
    sha256 "43492444645328bdcbdec922de63e95d8f4cf3a05439a23e4b520dcc6da17c56" => :high_sierra
    sha256 "16ee7a14a99b229c156be0d529c3d65703e9023fb807d9836f6259fc275556e4" => :sierra
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
           "--with-methods=opt",
           "--enable-silent-rules",
           "--enable-unique-id",
           "--disable-warnings",
           "--with-thread-model=openmp",
           "--disable-maintainer-mode",
           "--enable-petsc-hypre-required",
           "--enable-metaphysicl-required"
    system "make", "all"
    system "make", "install"

    # Fix libmesh-config to return a path to llvm's libs
    inreplace "#{prefix}/bin/libmesh-config", "return_val=\" $return_val\"", "return_val=\"-L#{Formula["llvm"].opt_prefix}/lib $return_val\""
  end

  test do
    system "make", "check"
  end
end

