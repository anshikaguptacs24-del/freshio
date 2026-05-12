 import React, { useEffect } from 'react';
import { View, Text, StyleSheet } from 'react-native';

export default function Splash({ navigation }) {

  // Auto move to Home after 2 sec (optional)
  useEffect(() => {
    setTimeout(() => {
      navigation.replace('Home');
    }, 2000);
  }, []);

  return (
    <View style={styles.container}>

      {/* Logo */}
      <Text style={styles.logo}>🍃</Text>

      {/* App Name */}
      <Text style={styles.title}>Freshio</Text>

      {/* Tagline */}
      <Text style={styles.subtitle}>Every Bite Matters</Text>

      {/* Dots */}
      <View style={styles.dots}>
        <View style={styles.dot} />
        <View style={styles.dot} />
        <View style={styles.dot} />
      </View>

    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',

    // Gradient-like color (simple version)
    backgroundColor: '#66BB6A',
  },

  logo: {
    fontSize: 60,
    marginBottom: 10,
  },

  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#fff',
  },

  subtitle: {
    color: '#E8F5E9',
    marginTop: 5,
  },

  dots: {
    flexDirection: 'row',
    marginTop: 20,
  },

  dot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#fff',
    marginHorizontal: 4,
  },
});
