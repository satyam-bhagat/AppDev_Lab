import { signOut } from 'firebase/auth';
import React from 'react';
import { Button, Text, View } from 'react-native';
import { auth } from '../config/firebaseconfig';

export default function HomeScreen() {
  const user = auth.currentUser;

  return (
    <View style={{ padding: 20 }}>
      <Text style={{ fontSize: 18, marginBottom: 12 }}>Welcome, {user?.email ?? user?.phoneNumber ?? 'User'}</Text>
      <Button title="Logout" onPress={() => signOut(auth)} />
    </View>
  );
}

