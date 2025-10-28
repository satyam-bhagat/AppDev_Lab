import React, { useState } from 'react';
import { Alert, StyleSheet, TextInput, TouchableOpacity } from 'react-native';
import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { useTodos } from '@/contexts/TodoContext';

interface AddTodoFormProps {
  onClose?: () => void;
}

export const AddTodoForm: React.FC<AddTodoFormProps> = ({ onClose }) => {
  const { addTodo } = useTodos();
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = async () => {
    if (!title.trim()) {
      Alert.alert('Validation', 'Please enter a title');
      return;
    }
    try {
      setSubmitting(true);
      await addTodo({ title: title.trim(), description: description.trim() || undefined });
      setTitle('');
      setDescription('');
      onClose?.();
    } catch (e) {
      Alert.alert('Error', 'Failed to add todo');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <ThemedView style={styles.container}>
      <ThemedText type="subtitle" style={styles.heading}>Add Todo</ThemedText>
      <TextInput
        placeholder="Title"
        value={title}
        onChangeText={setTitle}
        style={styles.input}
      />
      <TextInput
        placeholder="Description (optional)"
        value={description}
        onChangeText={setDescription}
        style={[styles.input, styles.multiline]}
        multiline
        numberOfLines={3}
      />
      <TouchableOpacity disabled={submitting} onPress={handleSubmit} style={styles.button}>
        <ThemedText style={styles.buttonText}>{submitting ? 'Adding...' : 'Add Todo'}</ThemedText>
      </TouchableOpacity>
    </ThemedView>
  );
};

const styles = StyleSheet.create({
  container: {
    gap: 12,
  },
  heading: {
    textAlign: 'center',
    marginBottom: 8,
  },
  input: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#e5e7eb',
    borderRadius: 10,
    paddingHorizontal: 12,
    paddingVertical: 10,
  },
  multiline: {
    textAlignVertical: 'top',
  },
  button: {
    backgroundColor: '#22c55e',
    paddingVertical: 12,
    borderRadius: 10,
    alignItems: 'center',
  },
  buttonText: {
    color: '#fff',
    fontWeight: '600',
  },
});

export default AddTodoForm;
