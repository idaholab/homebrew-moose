class MooseMesa < Formula
  include Language::Python::Virtualenv
  desc "Graphics Library. Custom built for off-screen rendinging by the MOOSE group."
  homepage "https://www.mesa3d.org/"
  url "https://mesa.freedesktop.org/archive/mesa-18.2.8.tar.xz"
  sha256 "1d2ed9fd435d86d95b7215b287258d3e6b1180293a36f688e5a2efc18298d863"
  version "18.2.8-2"

  bottle do
    root_url "https://mooseframework.org/source_packages"
    sha256 "6df764b6da8c866bdbee05f13837b1f27f794623af497dbab997768c83432a88" => :mojave
    sha256 "66dd4d987b985d8647169d98e30cbc03a55b2b1b83479ccce313a8577a1328b9" => :high_sierra
    sha256 "5832efface174697c4638206f559be86e91fa96adb5925e14b50c10fcc2b42c2" => :sierra
  end

  depends_on "pkg-config" => :build
  depends_on "zlib" => :build
  depends_on "expat" => :build
  depends_on :x11

  def install
    args = %W[
    --prefix=#{prefix}
    --enable-opengl
    --disable-gles1
    --disable-gles2
    --disable-va
    --disable-xvmc
    --disable-vdpau
    --enable-shared-glapi
    --disable-texture-float
    --with-gallium-drivers=swrast
    --disable-dri
    --disable-egl
    --disable-gbm
    --disable-glx
    --disable-osmesa
    --enable-gallium-osmesa
    --with-platforms=,
    ]
    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    # For now, do not test (I have no idea how to test this before VTK becomes available).
    # If moose-vtklite passes, then so did this.
    system "true"
  end
end
