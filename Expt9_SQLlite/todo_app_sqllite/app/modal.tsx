import React from 'react';
import { View, Text } from 'react-native';
import AddTodoForm from '@/components/AddTodoForm';

export default function ModalScreen() {
  return (
    <View className="flex-1 bg-white p-6">
      <Text className="text-xl font-semibold mb-4 text-center">Add a New Todo ✏️</Text>
      <AddTodoForm />
    </View>
  );
}
