// src/navigation/AppNavigator.js
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import ForgotPasswordScreen from '../screens/ForgotPasswordScreen';
import HomeScreen from '../screens/HomeScreen';
import PhoneAuthScreen from '../screens/PhoneAuthScreen';
import SignInScreen from '../screens/SignInScreen';
import SignUpScreen from '../screens/SignUpscreen';

const Stack = createNativeStackNavigator();

export default function AppNavigator({ user }) {
  return (
    <Stack.Navigator>
      {user ? (
        <Stack.Screen name="Home" component={HomeScreen} options={{ headerShown: false }} />
      ) : (
        <>
          <Stack.Screen name="SignIn" component={SignInScreen} options={{ title: 'Sign In' }} />
          <Stack.Screen name="SignUp" component={SignUpScreen} options={{ title: 'Create Account' }} />
          <Stack.Screen name="ForgotPassword" component={ForgotPasswordScreen} options={{ title: 'Forgot Password' }} />
          <Stack.Screen name="PhoneAuth" component={PhoneAuthScreen} options={{ title: 'Phone Login' }} />
        </>
      )}
    </Stack.Navigator>
  );
}
