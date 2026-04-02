const path = require('path');
const {getDefaultConfig, mergeConfig} = require('@react-native/metro-config');

/**
 * Metro configuration
 * https://reactnative.dev/docs/metro
 *
 * @type {import('@react-native/metro-config').MetroConfig}
 */
const config = {
  // Lock Metro to this project directory only — prevent it from
  // walking up to parent node_modules (this repro lives inside
  // another RN project's tree).
  projectRoot: __dirname,
  watchFolders: [],
  resolver: {
    nodeModulesPaths: [path.resolve(__dirname, 'node_modules')],
    // Block parent directories from being resolved
    blockList: [
      new RegExp(path.resolve(__dirname, '..', '..', '..', 'ShopMy') + '/.*'),
    ],
  },
};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
