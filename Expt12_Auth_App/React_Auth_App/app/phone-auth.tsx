import React from 'react';
import PhoneAuthScreen from '../screens/PhoneAuthScreen';
import { useRouter } from 'expo-router';

export default function PhoneAuth() {
  const router = useRouter();
  
  return <PhoneAuthScreen navigation={{ 
    navigate: (route: string) => router.push(route as any),
    goBack: () => router.back()
  }} />;
}




