 import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TextInput, Switch } from 'react-native';

export default function Inventory() {
  const [colorMode, setColorMode] = useState(false);

  const items = [
    { name: "Milk", days: 2, color: "white" },
    { name: "Strawberries", days: 4, color: "red" },
    { name: "Bread", days: 0, color: "yellow" },
    { name: "Chicken", days: 8, color: "green" },
    { name: "Yogurt", days: 3, color: "white" },
  ];

  const grouped = items.reduce((acc, item) => {
    acc[item.color] = acc[item.color] || [];
    acc[item.color].push(item);
    return acc;
  }, {});

  return (
    <ScrollView style={styles.container}>

      <Text style={styles.title}>Inventory</Text>

      <TextInput placeholder="Search groceries..." style={styles.search} />

      <View style={styles.toggle}>
        <Text>Color Mode 🌈</Text>
        <Switch value={colorMode} onValueChange={setColorMode} />
      </View>

      {
        colorMode ? (
          Object.keys(grouped).map(color => (
            <View key={color} style={styles.section}>
              <Text style={styles.sectionTitle}>{color.toUpperCase()}</Text>
              {grouped[color].map(item => (
                <Text key={item.name}>{item.name}</Text>
              ))}
            </View>
          ))
        ) : (
          items.map(item => (
            <View key={item.name} style={styles.card}>
              <Text style={styles.bold}>{item.name}</Text>
              <Text>{item.days === 0 ? "Expired" : `${item.days} days`}</Text>
            </View>
          ))
        )
      }

    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, backgroundColor: '#F5F7F6' },
  title: { fontSize: 24, fontWeight: 'bold', marginBottom: 10 },
  search: { backgroundColor: '#fff', padding: 10, borderRadius: 10, marginBottom: 10 },
  toggle: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 10 },
  card: { backgroundColor: '#fff', padding: 15, borderRadius: 12, marginBottom: 10, elevation: 2 },
  bold: { fontWeight: 'bold' },
  section: { backgroundColor: '#eee', padding: 10, borderRadius: 10, marginBottom: 10 },
  sectionTitle: { fontWeight: 'bold', marginBottom: 5 }
});
