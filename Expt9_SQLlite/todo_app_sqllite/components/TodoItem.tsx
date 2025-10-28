import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { IconSymbol } from '@/components/ui/icon-symbol';
import { useTodos } from '@/contexts/TodoContext';
import { Todo } from '@/types/todo';
import React from 'react';
import { Alert, StyleSheet, TouchableOpacity } from 'react-native';

interface TodoItemProps {
  todo: Todo;
  onEdit?: (todo: Todo) => void;
  onToggle?: () => void;
  onDelete?: () => void;
}

export const TodoItem: React.FC<TodoItemProps> = ({ todo, onEdit, onToggle, onDelete }) => {
  const { toggleTodo, deleteTodo } = useTodos();

  const handleToggle = async () => {
    if (onToggle) return onToggle();
    try {
      await toggleTodo(todo.id);
    } catch (error) {
      Alert.alert('Error', 'Failed to toggle todo');
    }
  };

  const handleDelete = () => {
    if (onDelete) return onDelete();
    Alert.alert(
      'Delete Todo',
      'Are you sure you want to delete this todo?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            try {
              await deleteTodo(todo.id);
            } catch (error) {
              Alert.alert('Error', 'Failed to delete todo');
            }
          },
        },
      ]
    );
  };

  const handleEdit = () => {
    if (onEdit) {
      onEdit(todo);
    }
  };

  return (
    <ThemedView style={styles.container} card>
      <TouchableOpacity style={styles.content} onPress={handleToggle}>
        <TouchableOpacity style={styles.checkbox} onPress={handleToggle}>
          <IconSymbol
            name={todo.completed ? 'checkmark.circle.fill' : 'circle'}
            size={26}
            color={todo.completed ? '#22c55e' : '#64748b'}
          />
        </TouchableOpacity>

        <ThemedView style={styles.textContainer}>
          <ThemedText
            style={[
              styles.title,
              todo.completed && styles.completedTitle,
              { color: todo.completed ? '#a3a3a3' : '#22223b' }
            ]}
          >
            {todo.title}
          </ThemedText>
          {todo.description && (
            <ThemedText
              style={[
                styles.description,
                todo.completed && styles.completedDescription,
                { color: todo.completed ? '#d1d5db' : '#64748b' }
              ]}
            >
              {todo.description}
            </ThemedText>
          )}
        </ThemedView>
      </TouchableOpacity>

      <ThemedView style={styles.actions}>
        <TouchableOpacity onPress={handleEdit} style={styles.actionButton}>
          <IconSymbol name="pencil" size={20} color="#3b82f6" />
        </TouchableOpacity>
        <TouchableOpacity onPress={handleDelete} style={styles.actionButton}>
          <IconSymbol name="trash" size={20} color="#e11d48" />
        </TouchableOpacity>
      </ThemedView>
    </ThemedView>
  );
};

export default TodoItem;

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 16,
    paddingHorizontal: 20,
    marginVertical: 8,
    borderRadius: 14,
    backgroundColor: undefined, // Now set by ThemedView card
    shadowColor: '#22c55e33',
    shadowOpacity: 0.08,
    shadowRadius: 7,
    shadowOffset: { width: 0, height: 2 },
  },
  content: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  checkbox: {
    marginRight: 12,
  },
  textContainer: {
    flex: 1,
  },
  title: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 2,
  },
  description: {
    fontSize: 14,
    opacity: 0.7,
  },
  completedTitle: {
    textDecorationLine: 'line-through',
    opacity: 0.6,
  },
  completedDescription: {
    opacity: 0.4,
  },
  actions: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  actionButton: {
    padding: 8,
    marginLeft: 4,
  },
});

