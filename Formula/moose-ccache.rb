class MooseCcache < Formula
  desc "testing bottles"
  homepage "https://mooseframework.org"
  url "http://mooseframework.org/source_packages/ccache-3.2.1.tar.gz"
  sha256 "f8709a83daaeb9be22fe35c42e7862a8699b50de181ba3e28c89c092014ccb55"
  version "3.2.1-1"

  bottle do
    root_url "https://mooseframework.org/source_packages"
    sha256 "af52861d25e6b584b5663748c1e68991de7d65e95fb220ffef8de8bc0a80c865" => :mojave
    sha256 "af52861d25e6b584b5663748c1e68991de7d65e95fb220ffef8de8bc0a80c865" => :high_sierra
    sha256 "af52861d25e6b584b5663748c1e68991de7d65e95fb220ffef8de8bc0a80c865" => :sierra
  end

  keg_only "we want to leverage moose_profile logic"
  depends_on "cmake" => :build
  depends_on "gcc"

  def install
    ENV.prepend "PATH", "#{Formula["gcc"].opt_prefix}/bin", ":"
    ENV["CC"] = "gcc"
    ENV["CXX"] = "g++"
    ENV["F77"] = "gfortran"
    ENV["FC"] = "gfortran"

    system "./configure", "--prefix=#{prefix}"
    system "make", "all"
    system "make", "install"
  end

  test do
    system "true"
  end
end
