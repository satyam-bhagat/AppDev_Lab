import React from 'react';
import HomeScreen from '@/screens/HomeScreen';
import { useRouter } from 'expo-router';

export default function Home() {
  const router = useRouter();
  
  return <HomeScreen navigation={{ 
    navigate: (route: string) => router.push(route as any),
    goBack: () => router.back()
  }} />;
}
