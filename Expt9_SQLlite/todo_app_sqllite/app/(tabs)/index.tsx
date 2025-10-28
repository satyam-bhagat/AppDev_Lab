import { Link } from 'expo-router';
import React from 'react';
import { ActivityIndicator, FlatList, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import TodoItem from '@/components/TodoItem';
import { Button } from '@/components/ui/button';
import { useTodos } from '@/contexts/TodoContext';

export default function IndexScreen() {
  const { activeTodos, loading, toggleTodo, deleteTodo } = useTodos();

  if (loading) {
    return (
      <SafeAreaView className="flex-1 items-center justify-center bg-white">
        <ActivityIndicator size="large" />
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView className="flex-1 bg-white pt-6 px-4">
      <FlatList
        data={activeTodos}
        keyExtractor={(item) => item.id.toString()}
        renderItem={({ item }) => (
          <TodoItem
            todo={item}
            onToggle={() => toggleTodo(item.id, !item.completed)}
            onDelete={() => deleteTodo(item.id)}
          />
        )}
        contentContainerStyle={{ paddingBottom: 100 }} // extra space at bottom
        ListEmptyComponent={
          <Text className="text-center text-gray-400 mt-10 mb-16">No active todos 🎯</Text>
        }
        showsVerticalScrollIndicator={false}
      />

      {/* + Add Todo Button with Safe Spacing */}
      <View className="mt-16 mb-10 items-center">
        <Link href="/modal" asChild>
          <Button className="py-4 px-8 rounded-3xl shadow-lg bg-blue-600">
            + Add Todo
          </Button>
        </Link>
      </View>
    </SafeAreaView>
  );
}
