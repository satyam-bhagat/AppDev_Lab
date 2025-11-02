import React from 'react';
import LoginScreen from '../screens/LoginScreen';
import { useRouter } from 'expo-router';

export default function Login() {
  const router = useRouter();
  
  return <LoginScreen navigation={{ 
    navigate: (route: string) => router.push(route as any),
    goBack: () => router.back()
  }} />;
}




