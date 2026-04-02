import React from 'react';
import {AppRegistry, View, Text, StyleSheet} from 'react-native';

function ShareExtensionApp() {
  return (
    <View style={styles.container}>
      <Text style={styles.heading}>Share Extension Font Test</Text>

      <View style={styles.row}>
        <Text style={styles.label}>System font (default):</Text>
        <Text style={styles.systemFont}>Hello World</Text>
      </View>

      <View style={styles.row}>
        <Text style={styles.label}>Custom font (Inter-Regular):</Text>
        <Text style={styles.customFont}>Hello World</Text>
      </View>

      <View style={styles.row}>
        <Text style={styles.label}>Custom font + fontSize 24:</Text>
        <Text style={[styles.customFont, {fontSize: 24}]}>Hello World</Text>
      </View>

      <View style={styles.row}>
        <Text style={styles.label}>Custom font + allowFontScaling=false:</Text>
        <Text style={styles.customFont} allowFontScaling={false}>
          Hello World
        </Text>
      </View>

      <View style={styles.row}>
        <Text style={styles.label}>System font + fontSize 24:</Text>
        <Text style={{fontSize: 24}}>Hello World</Text>
      </View>

      <View style={styles.row}>
        <Text style={styles.label}>
          System font + fontSize 24 + allowFontScaling=false:
        </Text>
        <Text style={{fontSize: 24}} allowFontScaling={false}>
          Hello World
        </Text>
      </View>

      <View style={styles.row}>
        <Text style={styles.label}>Custom bold (Inter-Bold):</Text>
        <Text style={styles.customBold}>Hello World</Text>
      </View>

      <View style={styles.row}>
        <Text style={styles.label}>Custom bold + allowFontScaling=false:</Text>
        <Text style={styles.customBold} allowFontScaling={false}>
          Hello World
        </Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#ffffff',
    padding: 20,
    paddingTop: 60,
  },
  heading: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 20,
    textAlign: 'center',
  },
  row: {
    marginBottom: 12,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#ccc',
    paddingBottom: 8,
  },
  label: {
    fontSize: 11,
    color: '#888',
    marginBottom: 2,
  },
  systemFont: {
    fontSize: 16,
  },
  customFont: {
    fontSize: 16,
    fontFamily: 'Inter-Regular',
  },
  customBold: {
    fontSize: 16,
    fontFamily: 'Inter-Bold',
  },
});

AppRegistry.registerComponent('FontScalingReproShare', () => ShareExtensionApp);
