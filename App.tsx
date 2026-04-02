import React from 'react';
import {View, Text, StyleSheet} from 'react-native';

function App(): React.JSX.Element {
  return (
    <View style={styles.container}>
      <Text style={styles.heading}>Font Scaling Bug Repro</Text>
      <Text style={styles.body}>
        This app demonstrates a bug where custom fonts are invisible in iOS App
        Extensions when using React Native 0.84+ with the New Architecture
        (Fabric).
      </Text>
      <Text style={styles.custom}>Custom font (Inter-Regular)</Text>
      <Text style={styles.customBold}>Custom font (Inter-Bold)</Text>
      <Text style={styles.instructions}>
        To test: Open Safari → Share → select "FontScalingReproShareExtension"
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 30,
    backgroundColor: '#fff',
  },
  heading: {
    fontSize: 22,
    fontWeight: 'bold',
    marginBottom: 16,
  },
  body: {
    fontSize: 15,
    textAlign: 'center',
    color: '#555',
    marginBottom: 20,
  },
  custom: {
    fontSize: 18,
    fontFamily: 'Inter-Regular',
    marginBottom: 8,
  },
  customBold: {
    fontSize: 18,
    fontFamily: 'Inter-Bold',
    marginBottom: 20,
  },
  instructions: {
    fontSize: 13,
    color: '#888',
    textAlign: 'center',
  },
});

export default App;
