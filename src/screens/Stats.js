 import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

export default function Stats() {
  return (
    <View style={styles.container}>

      <Text style={styles.title}>Statistics</Text>

      <View style={styles.card}>
        <Text>Items Tracked</Text>
        <Text style={styles.big}>5</Text>
      </View>

      <View style={styles.card}>
        <Text>Waste Prevented</Text>
        <Text style={styles.big}>3kg</Text>
      </View>

    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20 },
  title: { fontSize: 24, fontWeight: 'bold', marginBottom: 20 },
  card: { backgroundColor: '#fff', padding: 20, borderRadius: 12, marginBottom: 10 },
  big: { fontSize: 22, fontWeight: 'bold', color: '#4CAF50' }
});