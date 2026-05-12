import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import Dashboard from '../screens/Dashboard';
import Inventory from '../screens/Inventory';
import AddItem from '../screens/AddItem';
import Donate from '../screens/Donate';
import Stats from '../screens/Stats';

const Tab = createBottomTabNavigator();

export default function BottomTabs() {
  return (
    <Tab.Navigator screenOptions={{ headerShown: false }}>
      <Tab.Screen name="Home" component={Dashboard} />
      <Tab.Screen name="Inventory" component={Inventory} />
      <Tab.Screen name="Add" component={AddItem} />
      <Tab.Screen name="Donate" component={Donate} />
      <Tab.Screen name="Stats" component={Stats} />
    </Tab.Navigator>
  );
} 
