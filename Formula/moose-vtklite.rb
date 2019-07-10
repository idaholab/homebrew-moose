class MooseVtklite < Formula
  desc "Toolkit for 3D computer graphics, image processing, and visualization"
  homepage "https://www.vtk.org/"
  url "https://www.vtk.org/files/release/8.2/VTK-8.2.0.tar.gz"
  sha256 "34c3dc775261be5e45a8049155f7228b6bd668106c72a3c435d95730d17d57bb"
  head "https://github.com/Kitware/VTK.git"

  bottle do
    root_url "https://mooseframework.org/source_packages"
  end

  # encoding hint patch: https://gitlab.kitware.com/vtk/vtk/issues/17642
  patch do
    url "https://mooseframework.org/source_packages/VTK-8.2.0.diff"
    sha256 "a0a99f242e4bd577270339c80415d3c9825b1894bca90c57645dc1bce7d3f4b8"
  end

  keg_only "we want to leverage moose_profile logic"
  depends_on "cmake" => :build
  depends_on "openmpi" => :build

  def install
    args = std_cmake_args + %W[
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_INSTALL_RPATH:STRING=#{lib}
      -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=ON
      -DCMAKE_INSTALL_NAME_DIR:STRING=#{lib}
      -DCMAKE_MACOSX_RPATH:BOOL=ON
      -DVTK_WRAP_PYTHON=ON
      -DVTK_Group_MPI:BOOL=ON
      -DBUILD_TESTING=OFF
      -Wno-dev
    ]
    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    vtk_include = Dir[opt_include/"vtk-*"].first
    major, minor = vtk_include.match(/.*-(.*)$/)[1].split(".")

    (testpath/"version.cpp").write <<~EOS
      #include <vtkVersion.h>
      #include <assert.h>
      int main(int, char *[]) {
        assert (vtkVersion::GetVTKMajorVersion()==#{major});
        assert (vtkVersion::GetVTKMinorVersion()==#{minor});
        return EXIT_SUCCESS;
      }
    EOS

    system ENV.cxx, "-std=c++11", "version.cpp", "-I#{vtk_include}"
    system "./a.out"
    system "#{bin}/vtkpython", "-c", "exit()"
  end
end
