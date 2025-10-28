import React, { createContext, useContext, useEffect, useState, ReactNode } from 'react';
import { databaseService } from '@/services/database';
import { Todo, CreateTodoData, UpdateTodoData } from '@/types/todo';

interface TodoContextType {
  todos: Todo[];
  activeTodos: Todo[];
  completedTodos: Todo[];
  loading: boolean;
  error: string | null;
  addTodo: (data: CreateTodoData) => Promise<void>;
  updateTodo: (id: number, data: UpdateTodoData) => Promise<void>;
  deleteTodo: (id: number) => Promise<void>;
  toggleTodo: (id: number, completed?: boolean) => Promise<void>;
  clearCompletedTodos: () => Promise<void>;
  refreshTodos: () => Promise<void>;
}

const TodoContext = createContext<TodoContextType | undefined>(undefined);

export const useTodos = () => {
  const context = useContext(TodoContext);
  if (context === undefined) {
    throw new Error('useTodos must be used within a TodoProvider');
  }
  return context;
};

interface TodoProviderProps {
  children: ReactNode;
}

export const TodoProvider: React.FC<TodoProviderProps> = ({ children }) => {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [activeTodos, setActiveTodos] = useState<Todo[]>([]);
  const [completedTodos, setCompletedTodos] = useState<Todo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadTodos = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const [allTodos, active, completed] = await Promise.all([
        databaseService.getAllTodos(),
        databaseService.getActiveTodos(),
        databaseService.getCompletedTodos(),
      ]);

      setTodos(allTodos);
      setActiveTodos(active);
      setCompletedTodos(completed);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load todos');
      console.error('Error loading todos:', err);
    } finally {
      setLoading(false);
    }
  };

  const addTodo = async (data: CreateTodoData) => {
    try {
      setError(null);
      await databaseService.createTodo(data);
      await loadTodos();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to add todo');
      console.error('Error adding todo:', err);
      throw err;
    }
  };

  const updateTodo = async (id: number, data: UpdateTodoData) => {
    try {
      setError(null);
      await databaseService.updateTodo(id, data);
      await loadTodos();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to update todo');
      console.error('Error updating todo:', err);
      throw err;
    }
  };

  const deleteTodo = async (id: number) => {
    try {
      setError(null);
      await databaseService.deleteTodo(id);
      await loadTodos();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to delete todo');
      console.error('Error deleting todo:', err);
      throw err;
    }
  };

  const toggleTodo = async (id: number, completed?: boolean) => {
    try {
      setError(null);
      if (typeof completed === 'boolean') {
        await databaseService.updateTodo(id, { completed });
      } else {
        await databaseService.toggleTodo(id);
      }
      await loadTodos();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to toggle todo');
      console.error('Error toggling todo:', err);
      throw err;
    }
  };

  const clearCompletedTodos = async () => {
    try {
      setError(null);
      await databaseService.clearCompletedTodos();
      await loadTodos();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to clear completed todos');
      console.error('Error clearing completed todos:', err);
      throw err;
    }
  };

  const refreshTodos = async () => {
    await loadTodos();
  };

  useEffect(() => {
    const initializeDatabase = async () => {
      try {
        await databaseService.init();
        await loadTodos();
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to initialize database');
        setLoading(false);
        console.error('Error initializing database:', err);
      }
    };

    initializeDatabase();
  }, []);

  const value: TodoContextType = {
    todos,
    activeTodos,
    completedTodos,
    loading,
    error,
    addTodo,
    updateTodo,
    deleteTodo,
    toggleTodo,
    clearCompletedTodos,
    refreshTodos,
  };

  return <TodoContext.Provider value={value}>{children}</TodoContext.Provider>;
};