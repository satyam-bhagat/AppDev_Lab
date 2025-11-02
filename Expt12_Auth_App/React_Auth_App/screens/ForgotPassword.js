import { sendPasswordResetEmail } from 'firebase/auth';
import React, { useState } from 'react';
import { Button, TextInput, View } from 'react-native';
import { auth } from '../config/firebaseconfig';

export default function ForgotPasswordScreen({ navigation }) {
  const [email, setEmail] = useState('');

  const sendReset = async () => {
    try {
      await sendPasswordResetEmail(auth, email.trim());
      alert('Reset email sent. Check your inbox.');
      navigation.goBack();
    } catch (err) {
      alert(err.message);
    }
  };

  return (
    <View style={{ padding: 20 }}>
      <TextInput placeholder="Your email" value={email} onChangeText={setEmail} autoCapitalize="none" keyboardType="email-address" style={{borderBottomWidth:1, marginBottom:12}} />
      <Button title="Send reset email" onPress={sendReset} />
    </View>
  );
}

