class MooseLibmesh < Formula
  desc "The libMesh library provides a framework for the numerical simulation of partial differential equations."
  homepage "https://libmesh.github.io/"
  url "https://github.com/libmesh/libMesh.git", :revision => "ca543b0a6d9af487d4b7d1e64b890aa777a3bb9c"
  version "ca543b0-1"

  bottle do
    root_url "https://mooseframework.org/source_packages"
    sha256 "f64ff66160d731e5784bebd81a50ea7858ed0ccc7faf9fd917faebbfcb06724c" => :mojave
    sha256 "07a4b33b2581454e49d3d683196cac8243a62d6eb287e28881574ba40d853c8c" => :high_sierra
    sha256 "6ac604a6ab0c2097793795dc96e81aefba7bb4679230cf79ab4a56d496cfa255" => :sierra
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
