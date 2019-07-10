class MooseCcache < Formula
  desc "testing bottles"
  homepage "https://mooseframework.org"
  url "http://mooseframework.org/source_packages/ccache-3.2.1.tar.gz"
  sha256 "f8709a83daaeb9be22fe35c42e7862a8699b50de181ba3e28c89c092014ccb55"
  version "3.2.1-1"

  bottle do
    root_url "https://mooseframework.org/source_packages"
    sha256 "abb290414f02a6d0e973cc3cbe56481f802c0a61cc33e101e0fd6ea3e31e3a75" => :mojave
    sha256 "25c60155f41af7cd9f29ce706d860a8b8db89ad99582ecd5289dd780a78bb259" => :high_sierra
    sha256 "4cdf67b660013064acb76557706869d5d62d01a6ea3072c0b9422f69eeb1a550" => :sierra
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
