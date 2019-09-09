class MooseVtk < Formula
  desc "Toolkit for 3D computer graphics, image processing, and visualization"
  homepage "https://www.vtk.org/"
  url "https://www.vtk.org/files/release/8.2/VTK-8.2.0.tar.gz"
  sha256 "34c3dc775261be5e45a8049155f7228b6bd668106c72a3c435d95730d17d57bb"
  head "https://github.com/Kitware/VTK.git"
  revision 6

  bottle do
    root_url "https://mooseframework.org/source_packages"
    sha256 "5301ec36dd95b2febf972c8e0f6ba6e030054a722c7c9b7c76f84792eabee901" => :mojave
    sha256 "2c036a9abb1970f0e4a0e19936c65e02490fbfdf9c5b63aa8151cef3430c4cb3" => :high_sierra
    sha256 "0ed87c60a8c55d9a505024edc6c1456956876da237f96b01c8c04bbd43d458e2" => :sierra
  end

  # encoding hint patch: https://gitlab.kitware.com/vtk/vtk/issues/17642
  patch do
    url "https://mooseframework.org/source_packages/VTK-8.2.0.diff"
    sha256 "a0a99f242e4bd577270339c80415d3c9825b1894bca90c57645dc1bce7d3f4b8"
  end

  keg_only "we want to leverage modules"
  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "fontconfig"
  depends_on "hdf5"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "netcdf"
  depends_on "pyqt"
  depends_on "python@2"
  depends_on "qt"

  def install
    pyver = Language::Python.major_minor_version "python2"
    py_prefix = Formula["python@2"].opt_frameworks/"Python.framework/Versions/#{pyver}"
    args = std_cmake_args + %W[
      -DBUILD_SHARED_LIBS=ON
      -DBUILD_TESTING=OFF
      -DCMAKE_INSTALL_NAME_DIR:STRING=#{lib}
      -DCMAKE_INSTALL_RPATH:STRING=#{lib}
      -DModule_vtkInfovisBoost=ON
      -DModule_vtkInfovisBoostGraphAlgorithms=ON
      -DModule_vtkRenderingFreeTypeFontConfig=ON
      -DVTK_REQUIRED_OBJCXX_FLAGS=''
      -DVTK_USE_COCOA=ON
      -DVTK_USE_SYSTEM_EXPAT=ON
      -DVTK_USE_SYSTEM_HDF5=ON
      -DVTK_USE_SYSTEM_JPEG=ON
      -DVTK_USE_SYSTEM_LIBXML2=ON
      -DVTK_USE_SYSTEM_NETCDF=ON
      -DVTK_USE_SYSTEM_PNG=ON
      -DVTK_USE_SYSTEM_TIFF=ON
      -DVTK_USE_SYSTEM_ZLIB=ON
      -DVTK_WRAP_PYTHON=ON
      -DVTK_PYTHON_VERSION=#{pyver}
      -DPYTHON_EXECUTABLE=#{Formula["python@2"].opt_bin}/python2
      -DPYTHON_INCLUDE_DIR=#{py_prefix}/include/python#{pyver}
      -DPYTHON_LIBRARY=#{py_prefix}/lib/libpython#{pyver}.dylib
      -DVTK_QT_VERSION:STRING=5
      -DVTK_Group_Qt=ON
      -DVTK_WRAP_PYTHON_SIP=ON
      -DSIP_PYQT_DIR='#{Formula["pyqt5"].opt_share}/sip'
    ]

    # CMake picks up the system's python dylib, even if we have a brewed one.
    if File.exist? "#{py_prefix}/Python"
      args << "-DPYTHON_LIBRARY='#{py_prefix}/Python'"
    elsif File.exist? "#{py_prefix}/lib/libpython#{pyver}.a"
      args << "-DPYTHON_LIBRARY='#{py_prefix}/lib/libpython#{pyver}.a'"
    elsif File.exist? "#{py_prefix}/lib/libpython#{pyver}.dylib"
      args << "-DPYTHON_LIBRARY='#{py_prefix}/lib/libpython#{pyver}.dylib'"
    else
      odie "No libpythonX.Y.{dylib|a} file found!"
    end

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
