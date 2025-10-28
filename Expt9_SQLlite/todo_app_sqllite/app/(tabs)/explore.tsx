import TodoItem from '@/components/TodoItem';
import { Button } from '@/components/ui/button';
import { useTodos } from '@/contexts/TodoContext';
import React from 'react';
import { FlatList, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

export default function ExploreScreen() {
  const { completedTodos, toggleTodo, deleteTodo, clearCompletedTodos } = useTodos();

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.container}>
        <Text style={styles.title}>Completed Todos ✅</Text>

        <FlatList
          data={completedTodos}
          keyExtractor={(item) => item.id.toString()}
          renderItem={({ item }) => (
            <View style={styles.todoCard}>
              <TodoItem
                todo={item}
                onToggle={() => toggleTodo(item.id, !item.completed)}
                onDelete={() => deleteTodo(item.id)}
              />
            </View>
          )}
          ItemSeparatorComponent={() => <View style={{ height: 12 }} />} // space between todos
          ListEmptyComponent={
            <Text style={styles.emptyText}>No completed todos yet 🎯</Text>
          }
          contentContainerStyle={{ paddingBottom: 100 }}
          showsVerticalScrollIndicator={false}
        />

        {completedTodos.length > 0 && (
          <View style={styles.clearContainer}>
            <Button
              onPress={clearCompletedTodos}
              className="rounded-full bg-blue-600 py-4 px-8 shadow-lg"
            >
              Clear Completed
            </Button>
          </View>
        )}
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#f8fafc',
  },
  container: {
    flex: 1,
    paddingHorizontal: 16,
    paddingTop: 20,
  },
  title: {
    fontSize: 22,
    fontWeight: '700',
    color: '#1e3a8a', // deep blue
    textAlign: 'center',
    marginBottom: 16,
  },
  todoCard: {
    backgroundColor: '#ffffff',
    borderRadius: 16,
    padding: 12,
    shadowColor: '#000',
    shadowOpacity: 0.08,
    shadowRadius: 6,
    elevation: 3,
  },
  emptyText: {
    textAlign: 'center',
    color: '#64748b',
    marginTop: 20,
    fontSize: 16,
  },
  clearContainer: {
    alignItems: 'center',
    marginTop: 20,
  },
});
