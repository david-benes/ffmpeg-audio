const path = require('path');
const os = require('os');

const getBinaryPath = () => {
  const platform = os.platform();
  const arch = os.arch();

  const binaries = {
    darwin: {
      arm64: 'bin/darwin/arm64'
    },
    linux: {
      x64: 'bin/linux/x64',
    }
  };
  if (platform === 'darwin' && arch === 'arm64') {
    return {
      ffmpeg: path.resolve(__dirname, `${binaries.darwin.arm64}/ffmpeg`),
      ffprobe: path.resolve(__dirname, `${binaries.darwin.arm64}/ffprobe`),
    };
  } else {
    return {
      ffmpeg: path.resolve(__dirname, `${binaries.linux.x64}/ffmpeg`),
      ffprobe: path.resolve(__dirname, `${binaries.linux.x64}/ffprobe`),
    };
  }

};

module.exports = getBinaryPath;
