import React from 'react';
import ForgotPasswordScreen from '../screens/ForgotPassword';
import { useRouter } from 'expo-router';

export default function ForgotPassword() {
  const router = useRouter();
  
  return <ForgotPasswordScreen navigation={{ 
    navigate: (route: string) => router.push(route as any),
    goBack: () => router.back()
  }} />;
}




