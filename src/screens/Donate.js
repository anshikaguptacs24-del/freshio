 import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';

export default function Donate() {
  return (
    <View style={styles.container}>

      <Text style={styles.title}>Donate</Text>

      <View style={styles.card}>
        <Text style={styles.big}>3 items</Text>
        <Text>Available to donate</Text>
      </View>

      <View style={styles.center}>
        <Text>Community Food Bank</Text>
        <TouchableOpacity style={styles.button}>
          <Text style={{ color: '#fff' }}>Get Directions</Text>
        </TouchableOpacity>
      </View>

    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20 },
  title: { fontSize: 24, fontWeight: 'bold', marginBottom: 20 },
  card: { backgroundColor: '#fff', padding: 20, borderRadius: 12, marginBottom: 20 },
  big: { fontSize: 24, fontWeight: 'bold', color: '#4CAF50' },
  center: { backgroundColor: '#fff', padding: 20, borderRadius: 12 },
  button: { backgroundColor: '#4CAF50', padding: 10, marginTop: 10, borderRadius: 8, alignItems: 'center' }
});
