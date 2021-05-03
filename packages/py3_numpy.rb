require 'package'

class Py3_numpy < Package
  description 'NumPy is the fundamental package for array computing with Python.'
  homepage 'https://numpy.org/'
  @_ver = '1.20.2'
  version @_ver
  license 'BSD'
  compatibility 'all'
  source_url 'https://github.com/numpy/numpy.git'
  git_hashtag "v#{@_ver}"

  binary_url({
    aarch64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/py3_numpy/1.20.2_armv7l/py3_numpy-1.20.2-chromeos-armv7l.tar.xz',
     armv7l: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/py3_numpy/1.20.2_armv7l/py3_numpy-1.20.2-chromeos-armv7l.tar.xz',
       i686: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/py3_numpy/1.20.2_i686/py3_numpy-1.20.2-chromeos-i686.tar.xz',
     x86_64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/py3_numpy/1.20.2_x86_64/py3_numpy-1.20.2-chromeos-x86_64.tar.xz'
  })
  binary_sha256({
    aarch64: '05050e3e26fe3b6d6aaa9c07e22df825dd8a4da4c19cca8ccbd63c74752a5827',
     armv7l: '05050e3e26fe3b6d6aaa9c07e22df825dd8a4da4c19cca8ccbd63c74752a5827',
       i686: '15358c391e68667f3ceb607a16720093806a7840c6da526d7078a52b195b63e3',
     x86_64: '2e1e34a8459e614e0e2819fa64fdbb15618cba48a21b96b08b8b8f9eeeed3f33'
  })

  depends_on 'lapack'
  depends_on 'py3_cython' => :build
  depends_on 'py3_setuptools' => :build

  def self.build
    system "python3 setup.py build #{PY3_SETUP_BUILD_OPTIONS}"
  end

  def self.install
    system "python3 setup.py install #{PY_SETUP_INSTALL_OPTIONS}"
  end
end
