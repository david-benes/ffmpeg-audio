const path = require('path');
const os = require('os');

const getBinaryPath = () => {
  const platform = os.platform();
  const arch = os.arch();

  const binaries = {
    darwin: {
      arm64: 'bin/darwin/aarch64/ffmpeg'
    },
    linux: {
      x64: 'bin/linux/x64/ffmpeg',
    }
  };

  if (platform === 'darwin' && arch === 'arm64') {
    return path.resolve(__dirname, binaries.darwin.arm64);
  } else {
    return path.resolve(__dirname, binaries.linux.x64);
  }
};

module.exports = getBinaryPath;
