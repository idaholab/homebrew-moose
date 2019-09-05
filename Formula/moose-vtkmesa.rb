class MooseVtkmesa < Formula
  desc "Toolkit for 3D computer graphics, image processing, and visualization"
  homepage "https://www.vtk.org/"
  url "https://www.vtk.org/files/release/8.2/VTK-8.2.0.tar.gz"
  sha256 "34c3dc775261be5e45a8049155f7228b6bd668106c72a3c435d95730d17d57bb"
  revision 1

  bottle do
    root_url "https://mooseframework.org/source_packages"
    sha256 "0bdc85633977270940bfb8c1d535271b4e42f42389981aa260128d9169a9ede7" => :mojave
    sha256 "2c7f39e7f9cc8d507ece125572ecfe4e6d554619ea9a797d234fd7c683ee62ab" => :high_sierra
    sha256 "e7d14231326d7acff5940d9800a3b920f185be13d8101b47f3c594c70004e4e9" => :sierra
  end

  # encoding hint patch: https://gitlab.kitware.com/vtk/vtk/issues/17642
  patch do
    url "https://mooseframework.org/source_packages/VTK-8.2.0.diff"
    sha256 "a0a99f242e4bd577270339c80415d3c9825b1894bca90c57645dc1bce7d3f4b8"
  end

  keg_only "we want to leverage moose_profile logic"
  depends_on "cmake" => :build
  depends_on "python"
  depends_on "moose-mesa"

  def install
    pyver = Language::Python.major_minor_version "python3"
    py_prefix = Formula["python3"].opt_frameworks/"Python.framework/Versions/#{pyver}"
    args = std_cmake_args + %W[
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_INSTALL_RPATH:STRING=#{lib}
      -DCMAKE_INSTALL_NAME_DIR:STRING=#{lib}
      -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=ON
      -DCMAKE_BUILD_TYPE=Release
      -DBUILD_TESTING=OFF
      -DVTK_USE_X=OFF
      -DVTK_OPENGL_HAS_OSMESA=ON
      -DVTK_DEFAULT_RENDER_WINDOW_OFFSCREEN=ON
      -DVTK_DEFAULT_RENDER_WINDOW_HEADLESS=ON
      -DOSMESA_INCLUDE_DIR=#{Formula["moose-mesa"].opt_prefix}/include
      -DOSMESA_LIBRARY=#{Formula["moose-mesa"].opt_prefix}/lib/libOSMesa.dylib
      -DVTK_WRAP_PYTHON=ON
      -DVTK_PYTHON_VERSION=#{pyver}
      -DPYTHON_EXECUTABLE=#{Formula["python"].opt_bin}/python3
      -DPYTHON_INCLUDE_DIR=#{py_prefix}/include/python#{pyver}m
      -DPYTHON_LIBRARY=#{py_prefix}/lib/libpython#{pyver}.dylib
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
