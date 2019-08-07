class MoosePeacock < Formula
  desc "MOOSE Framework"
  homepage "https://mooseframework.org"
  url "http://mooseframework.org/source_packages/moose-peacock.tar.gz"
  sha256 "3849cb25f486b811b965ef6661bbd9b0c4f5017a6696fcf8c7601a2fa4ca62cf"
  revision 1

  keg_only "we want to leverage the module load command"
  depends_on "modules"
  depends_on "moose-vtk"

  def install
    cp "moose-peacock", "#{prefix}/moose-peacock"
  end

  test do
    File.file?("#{prefix}/moose-peacock")
  end
end
