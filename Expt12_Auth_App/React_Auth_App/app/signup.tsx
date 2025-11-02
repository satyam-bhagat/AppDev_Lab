import React from 'react';
import SignUpScreen from '../screens/SignUpscreen';
import { useRouter } from 'expo-router';

export default function SignUp() {
  const router = useRouter();
  
  return <SignUpScreen navigation={{ 
    navigate: (route: string) => router.push(route as any),
    goBack: () => router.back()
  }} />;
}




