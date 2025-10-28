import { addDoc, collection, deleteDoc, doc, onSnapshot, orderBy, query, serverTimestamp, updateDoc } from 'firebase/firestore';
import React, { useEffect, useState } from 'react';
import { Alert, FlatList, Platform, StyleSheet, Text, TextInput, TouchableOpacity, View } from 'react-native';
import { db } from '../../FirebaseConfig';

type Task = { id: string; task: string; completed?: boolean };

export default function App() {
  const [task, setTask] = useState<string>('');
  const [tasks, setTasks] = useState<Task[]>([]);

  useEffect(() => {
    const q = query(collection(db, 'tasks'), orderBy('createdAt', 'desc'));
    const unsub = onSnapshot(q, (snap) => {
      const next = snap.docs.map(d => ({ id: d.id, ...(d.data() as any) })) as Task[];
      setTasks(next);
    });
    return () => unsub();
  }, []);

  const loadTasks = (): void => {};

  const addTask = async (): Promise<void> => {
    if (!task.trim()) return;
    await addDoc(collection(db, 'tasks'), {
      task: task.trim(),
      completed: false,
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    });
    setTask('');
  };

  const deleteTask = async (id: string): Promise<void> => {
    await deleteDoc(doc(db, 'tasks', id));
  };

  const toggleTask = async (id: string, completed: boolean | undefined): Promise<void> => {
    await updateDoc(doc(db, 'tasks', id), { completed: !completed, updatedAt: serverTimestamp() });
  };

  const renderItem = ({ item }: { item: Task }) => (
    <View style={styles.item}>
      <Text style={{ flex: 1 }} onPress={() => toggleTask(item.id, item.completed)}>
        {item.completed ? '✅ ' : ''}{item.task}
      </Text>
      <TouchableOpacity
        onPress={() =>
          Alert.alert('Delete', 'Delete this task?', [
            { text: 'Cancel', style: 'cancel' },
            { text: 'Delete', onPress: () => void deleteTask(item.id) },
          ])
        }
        style={styles.deleteBtn}>
        <Text style={{ color: '#fff' }}>Delete</Text>
      </TouchableOpacity>
    </View>
  );

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Firestore To-Do List</Text>

      <View style={styles.row}>
        <TextInput
          style={styles.input}
          placeholder="Enter a task"
          value={task}
          onChangeText={setTask}
        />
        <TouchableOpacity style={styles.addBtn} onPress={() => void addTask()}>
          <Text style={{ color: '#fff' }}>Add</Text>
        </TouchableOpacity>
      </View>

      <FlatList
        data={tasks}
        keyExtractor={item => String(item.id)}
        renderItem={renderItem}
        ListEmptyComponent={<Text style={{ textAlign: 'center', marginTop: 20 }}>No tasks yet</Text>}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, 
  backgroundColor: '#fff', 
  padding: 30
   ,paddingTop: Platform.OS === 'android' ? 80 : 30},
  title: { fontSize: 26, fontWeight: '700', marginBottom: 10 },
  row: { flexDirection: 'row', marginBottom: 12 },
  input: { flex: 1, borderWidth: 1, borderColor: '#ccc', borderRadius: 8, paddingHorizontal: 10 },
  addBtn: { marginLeft: 8, backgroundColor: '#4CAF50', paddingHorizontal: 16, justifyContent: 'center', borderRadius: 8 },
  item: { flexDirection: 'row', alignItems: 'center', padding: 10, borderWidth: 1, borderColor: '#eee', borderRadius: 8, marginBottom: 8 },
  deleteBtn: { backgroundColor: '#ff5252', paddingHorizontal: 12, paddingVertical: 6, borderRadius: 6 },
});
