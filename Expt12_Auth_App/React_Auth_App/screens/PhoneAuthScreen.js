import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Alert,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import {
  signInWithPhoneNumber,
  PhoneAuthProvider,
  signInWithCredential,
  RecaptchaVerifier,
} from 'firebase/auth';
import { auth } from '../config/firebaseconfig';

let recaptchaVerifier;

export default function PhoneAuthScreen({ navigation }) {
  const [phoneNumber, setPhoneNumber] = useState('');
  const [verificationCode, setVerificationCode] = useState('');
  const [verificationId, setVerificationId] = useState(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    // Initialize reCAPTCHA verifier for web
    if (Platform.OS === 'web') {
      try {
        recaptchaVerifier = new RecaptchaVerifier(auth, 'recaptcha-container', {
          size: 'invisible',
          callback: () => {
            console.log('reCAPTCHA solved');
          },
          'expired-callback': () => {
            Alert.alert('Error', 'reCAPTCHA expired. Please try again.');
          },
        });
      } catch (error) {
        console.error('Error initializing reCAPTCHA:', error);
      }
    }

    return () => {
      if (recaptchaVerifier) {
        try {
          recaptchaVerifier.clear();
        } catch (error) {
          console.error('Error clearing reCAPTCHA:', error);
        }
      }
    };
  }, []);

  const handleSendCode = async () => {
    if (!phoneNumber) {
      Alert.alert('Error', 'Please enter your phone number');
      return;
    }

    setLoading(true);
    try {
      // Format phone number (add country code if needed)
      const formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : `+1${phoneNumber}`;
      
      if (Platform.OS === 'web') {
        const confirmationResult = await signInWithPhoneNumber(auth, formattedPhone, recaptchaVerifier);
        setVerificationId(confirmationResult.verificationId);
        Alert.alert('Success', 'Verification code sent to your phone');
      } else {
        // For mobile platforms, use Firebase's test phone numbers or implement proper phone auth
        // Note: In production, you'll need to implement native phone auth or use a backend
        Alert.alert(
          'Info',
          'Phone authentication on mobile requires additional setup. For testing, please:\n\n1. Go to Firebase Console\n2. Navigate to Authentication → Settings → Phone\n3. Add test phone numbers\n\nAlternatively, use web version or email authentication for now.'
        );
      }
    } catch (error) {
      console.error('Phone auth error:', error);
      Alert.alert('Error', error.message || 'Failed to send verification code');
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyCode = async () => {
    if (!verificationCode || !verificationId) {
      Alert.alert('Error', 'Please enter the verification code');
      return;
    }

    setLoading(true);
    try {
      const credential = PhoneAuthProvider.credential(verificationId, verificationCode);
      await signInWithCredential(auth, credential);
      Alert.alert('Success', 'Phone number verified successfully!');
      // Navigation will be handled by auth state listener
    } catch (error) {
      console.error('Verification error:', error);
      Alert.alert('Error', error.message || 'Failed to verify code');
    } finally {
      setLoading(false);
    }
  };

  const handleTestPhoneNumber = async () => {
    Alert.alert(
      'Test Phone Numbers',
      'To test phone authentication in development:\n\n1. Open Firebase Console\n2. Go to Authentication → Sign-in method → Phone\n3. Add test phone numbers with verification codes\n\nExample:\nPhone: +1 650-555-3434\nCode: 123456',
      [{ text: 'OK' }]
    );
  };

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      style={styles.container}
    >
      <View style={styles.content}>
        <Text style={styles.title}>Phone Authentication</Text>
        
        {Platform.OS === 'web' && (
          <View id="recaptcha-container" style={styles.recaptcha} />
        )}

        {Platform.OS !== 'web' && (
          <TouchableOpacity
            onPress={handleTestPhoneNumber}
            style={styles.testButton}
          >
            <Text style={styles.testButtonText}>ℹ️ How to test phone auth</Text>
          </TouchableOpacity>
        )}

        {!verificationId ? (
          <>
            <Text style={styles.infoText}>
              Enter your phone number to receive a verification code
            </Text>
            <TextInput
              style={styles.input}
              placeholder="Phone Number (e.g., +1234567890)"
              value={phoneNumber}
              onChangeText={setPhoneNumber}
              keyboardType="phone-pad"
              placeholderTextColor="#999"
              autoComplete="tel"
            />
            
            <TouchableOpacity
              style={[styles.button, loading && styles.buttonDisabled]}
              onPress={handleSendCode}
              disabled={loading}
            >
              <Text style={styles.buttonText}>
                {loading ? 'Sending...' : 'Send Verification Code'}
              </Text>
            </TouchableOpacity>
          </>
        ) : (
          <>
            <Text style={styles.infoText}>
              Enter the verification code sent to {phoneNumber}
            </Text>
            
            <TextInput
              style={styles.input}
              placeholder="Verification Code"
              value={verificationCode}
              onChangeText={setVerificationCode}
              keyboardType="number-pad"
              placeholderTextColor="#999"
              autoComplete="sms-otp"
            />
            
            <TouchableOpacity
              style={[styles.button, loading && styles.buttonDisabled]}
              onPress={handleVerifyCode}
              disabled={loading}
            >
              <Text style={styles.buttonText}>
                {loading ? 'Verifying...' : 'Verify Code'}
              </Text>
            </TouchableOpacity>

            <TouchableOpacity
              onPress={() => {
                setVerificationId(null);
                setVerificationCode('');
              }}
              style={styles.changeNumberButton}
            >
              <Text style={styles.changeNumberText}>Change Phone Number</Text>
            </TouchableOpacity>
          </>
        )}

        <TouchableOpacity
          onPress={() => navigation?.goBack()}
          style={styles.backButton}
        >
          <Text style={styles.backButtonText}>Back</Text>
        </TouchableOpacity>
      </View>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    padding: 20,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    marginBottom: 30,
    textAlign: 'center',
    color: '#333',
  },
  recaptcha: {
    marginBottom: 20,
    alignItems: 'center',
  },
  infoText: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
    marginBottom: 20,
  },
  input: {
    backgroundColor: '#f5f5f5',
    borderRadius: 10,
    padding: 15,
    marginBottom: 15,
    fontSize: 16,
    borderWidth: 1,
    borderColor: '#ddd',
  },
  button: {
    backgroundColor: '#007AFF',
    borderRadius: 10,
    padding: 15,
    alignItems: 'center',
    marginTop: 10,
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  testButton: {
    backgroundColor: '#f0f0f0',
    borderRadius: 10,
    padding: 15,
    alignItems: 'center',
    marginBottom: 20,
    borderWidth: 1,
    borderColor: '#ddd',
  },
  testButtonText: {
    color: '#007AFF',
    fontSize: 14,
    fontWeight: '500',
  },
  changeNumberButton: {
    marginTop: 15,
    alignItems: 'center',
  },
  changeNumberText: {
    color: '#007AFF',
    fontSize: 14,
  },
  backButton: {
    marginTop: 20,
    alignItems: 'center',
  },
  backButtonText: {
    color: '#666',
    fontSize: 14,
  },
});
