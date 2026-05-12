 import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

export default function EatFirst() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Eat First</Text>

      <View style={styles.card}>
        <Text style={styles.bold}>Bread</Text>
        <Text style={{ color: 'red' }}>Expired</Text>
      </View>

      <View style={styles.card}>
        <Text style={styles.bold}>Milk</Text>
        <Text>2 days left</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20 },
  title: { fontSize: 24, fontWeight: 'bold', marginBottom: 20 },
  card: { backgroundColor: '#fff', padding: 15, borderRadius: 10, marginBottom: 10 },
  bold: { fontWeight: 'bold' }
});