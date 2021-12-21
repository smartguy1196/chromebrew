require 'package'

class Py3_snowballstemmer < Package
  description 'Snowball stemming library collection for Python'
  homepage 'https://snowballstem.org'
  @_ver = '2.1.0'
  version "#{@_ver}-1"
  license 'BSD'
  compatibility 'all'
  source_url 'https://pypi.python.org/packages/source/s/snowballstemmer/snowballstemmer-2.1.0.tar.gz'
  source_sha256 'e997baa4f2e9139951b6f4c631bad912dfd3c792467e2f03d7239464af90e914'

  binary_url({
    aarch64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/py3_snowballstemmer/2.1.0-1_armv7l/py3_snowballstemmer-2.1.0-1-chromeos-armv7l.tpxz',
     armv7l: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/py3_snowballstemmer/2.1.0-1_armv7l/py3_snowballstemmer-2.1.0-1-chromeos-armv7l.tpxz',
       i686: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/py3_snowballstemmer/2.1.0-1_i686/py3_snowballstemmer-2.1.0-1-chromeos-i686.tpxz',
     x86_64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/py3_snowballstemmer/2.1.0-1_x86_64/py3_snowballstemmer-2.1.0-1-chromeos-x86_64.tpxz'
  })
  binary_sha256({
    aarch64: '9d26f6cacccbf9716e4ef5f255971065c1ae7923376d4239a29282ac21b23ccc',
     armv7l: '9d26f6cacccbf9716e4ef5f255971065c1ae7923376d4239a29282ac21b23ccc',
       i686: 'bb4d132b6c655d80adbcf4023c0458d3934dd195eddcf2b670c65544c80e90ec',
     x86_64: 'fe32d3d5799f729258b7d85d5b1d149f7a5197933b215d7a1876b3e0cf2f4210'
  })

  depends_on 'py3_pystemmer'

  def self.build
    system "python3 setup.py build #{PY3_SETUP_BUILD_OPTIONS}"
  end

  def self.install
    system "python3 setup.py install #{PY_SETUP_INSTALL_OPTIONS}"
  end
end
