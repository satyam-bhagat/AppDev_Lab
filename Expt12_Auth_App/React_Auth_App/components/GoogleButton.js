import React, { useState, useEffect } from 'react';
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  Alert,
} from 'react-native';
import { GoogleAuthProvider, signInWithCredential } from 'firebase/auth';
import * as WebBrowser from 'expo-web-browser';
import * as Google from 'expo-auth-session/providers/google';
import { auth } from '../config/firebaseconfig';

// Complete the authentication session for better UX
WebBrowser.maybeCompleteAuthSession();

export default function GoogleButton() {
  const [loading, setLoading] = useState(false);

  // Google OAuth configuration with web client ID
  const [request, response, promptAsync] = Google.useAuthRequest({
    webClientId: '1030068585541-e3ha1th3c15k9u2dr45v7ts14222sur7.apps.googleusercontent.com',
    iosClientId: '15205713327-1kp5p4hqpmtc60qufplnk2k122kfj9r8.apps.googleusercontent.com',
    androidClientId: '15205713327-v7ao2u47agg3dcusb1tagqlrrcnp7vvh.apps.googleusercontent.com',
  });

  useEffect(() => {
    if (response?.type === 'success') {
      handleGoogleSignIn(response.authentication.idToken);
    } else if (response?.type === 'error') {
      Alert.alert('Error', 'Google sign-in failed. Please configure Google OAuth credentials in Firebase and update the GoogleButton component.');
      setLoading(false);
    }
  }, [response]);

  const handleGoogleSignIn = async (idToken) => {
    try {
      const credential = GoogleAuthProvider.credential(idToken);
      await signInWithCredential(auth, credential);
      // Success handled by auth state listener
    } catch (error) {
      Alert.alert('Error', error.message);
      setLoading(false);
    }
  };

  const handlePress = async () => {
    if (!request) {
      Alert.alert(
        'Google Sign-In Not Configured',
        'Please configure Google OAuth credentials in Firebase and update the GoogleButton component with your client IDs.'
      );
      return;
    }

    setLoading(true);
    try {
      await promptAsync();
    } catch (error) {
      Alert.alert('Error', 'Unable to start Google sign-in. Please check your configuration.');
      setLoading(false);
    }
  };

  return (
    <TouchableOpacity
      style={[styles.button, loading && styles.buttonDisabled]}
      onPress={handlePress}
      disabled={loading}
    >
      <Text style={styles.buttonText}>
        {loading ? 'Signing in...' : 'Continue with Google'}
      </Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  button: {
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 15,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#ddd',
    marginTop: 10,
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  buttonText: {
    color: '#333',
    fontSize: 16,
    fontWeight: '600',
  },
});
