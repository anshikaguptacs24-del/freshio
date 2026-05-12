 import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { AnimatedCircularProgress } from 'react-native-circular-progress';

export default function Dashboard() {
  return (
    <ScrollView style={styles.container}>

      {/* Header */}
      <Text style={styles.title}>🍃 Freshio</Text>
      <Text style={styles.subtitle}>Every Bite Matters.</Text>

      {/* Circle */}
      <View style={styles.circleContainer}>
        <AnimatedCircularProgress
          size={160}
          width={12}
          fill={82}
          tintColor="#4CAF50"
          backgroundColor="#E0E0E0">

          {(fill) => (
            <Text style={styles.percent}>{`${Math.round(fill)}%`}</Text>
          )}

        </AnimatedCircularProgress>

        <Text style={styles.label}>Freshness</Text>
      </View>

      {/* Expiring Card */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>Expiring Today</Text>
        <Text style={styles.orange}>0 items</Text>
      </View>

      {/* Eat First */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>Eat First</Text>
        <Text style={styles.bold}>Milk, Bread</Text>
      </View>

      {/* Total */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>Total Items</Text>
        <Text style={styles.green}>5</Text>
      </View>

      {/* Floating Button */}
      <TouchableOpacity style={styles.fab}>
        <Text style={{ color: '#fff', fontSize: 24 }}>+</Text>
      </TouchableOpacity>

    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F7F6',
    padding: 20,
  },

  title: {
    fontSize: 26,
    fontWeight: 'bold',
    color: '#2E7D32',
  },

  subtitle: {
    color: '#777',
    marginBottom: 20,
  },

  circleContainer: {
    alignItems: 'center',
    marginBottom: 30,
  },

  percent: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#2E7D32',
  },

  label: {
    marginTop: 10,
    color: '#666',
  },

  card: {
    backgroundColor: '#fff',
    padding: 18,
    borderRadius: 15,
    marginBottom: 15,

    // shadow (Android + iOS)
    elevation: 3,
  },

  cardTitle: {
    color: '#777',
    marginBottom: 5,
  },

  bold: {
    fontWeight: 'bold',
    fontSize: 16,
  },

  orange: {
    color: '#FF9800',
    fontWeight: 'bold',
  },

  green: {
    color: '#4CAF50',
    fontWeight: 'bold',
  },

  fab: {
    position: 'absolute',
    bottom: 30,
    right: 20,
    backgroundColor: '#4CAF50',
    width: 60,
    height: 60,
    borderRadius: 30,
    alignItems: 'center',
    justifyContent: 'center',
    elevation: 5,
  },
});