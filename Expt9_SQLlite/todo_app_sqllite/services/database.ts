import * as SQLite from 'expo-sqlite';
import { Todo, CreateTodoData, UpdateTodoData } from '@/types/todo';

const DATABASE_NAME = 'todos.db';

class DatabaseService {
  private db: SQLite.SQLiteDatabase | null = null;

  async init(): Promise<void> {
    try {
      this.db = await SQLite.openDatabaseAsync(DATABASE_NAME);
      await this.createTables();
    } catch (error) {
      console.error('Error initializing database:', error);
      throw error;
    }
  }

  private async createTables(): Promise<void> {
    if (!this.db) throw new Error('Database not initialized');

    await this.db.execAsync(`
      CREATE TABLE IF NOT EXISTS todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        completed BOOLEAN NOT NULL DEFAULT 0,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
      );
    `);
  }

  async getAllTodos(): Promise<Todo[]> {
    if (!this.db) throw new Error('Database not initialized');

    const result = await this.db.getAllAsync(`
      SELECT * FROM todos 
      ORDER BY createdAt DESC
    `);

    return result as Todo[];
  }

  async getActiveTodos(): Promise<Todo[]> {
    if (!this.db) throw new Error('Database not initialized');

    const result = await this.db.getAllAsync(`
      SELECT * FROM todos 
      WHERE completed = 0 
      ORDER BY createdAt DESC
    `);

    return result as Todo[];
  }

  async getCompletedTodos(): Promise<Todo[]> {
    if (!this.db) throw new Error('Database not initialized');

    const result = await this.db.getAllAsync(`
      SELECT * FROM todos 
      WHERE completed = 1 
      ORDER BY updatedAt DESC
    `);

    return result as Todo[];
  }

  async createTodo(data: CreateTodoData): Promise<Todo> {
    if (!this.db) throw new Error('Database not initialized');

    const result = await this.db.runAsync(
      `INSERT INTO todos (title, description) VALUES (?, ?)`,
      [data.title, data.description || null]
    );

    const newTodo = await this.db.getFirstAsync(
      `SELECT * FROM todos WHERE id = ?`,
      [result.lastInsertRowId]
    );

    return newTodo as Todo;
  }

  async updateTodo(id: number, data: UpdateTodoData): Promise<Todo> {
    if (!this.db) throw new Error('Database not initialized');

    const updateFields = [];
    const values = [];

    if (data.title !== undefined) {
      updateFields.push('title = ?');
      values.push(data.title);
    }
    if (data.description !== undefined) {
      updateFields.push('description = ?');
      values.push(data.description);
    }
    if (data.completed !== undefined) {
      updateFields.push('completed = ?');
      values.push(data.completed ? 1 : 0);
    }

    updateFields.push('updatedAt = CURRENT_TIMESTAMP');
    values.push(id);

    await this.db.runAsync(
      `UPDATE todos SET ${updateFields.join(', ')} WHERE id = ?`,
      values
    );

    const updatedTodo = await this.db.getFirstAsync(
      `SELECT * FROM todos WHERE id = ?`,
      [id]
    );

    return updatedTodo as Todo;
  }

  async deleteTodo(id: number): Promise<void> {
    if (!this.db) throw new Error('Database not initialized');

    await this.db.runAsync(`DELETE FROM todos WHERE id = ?`, [id]);
  }

  async toggleTodo(id: number): Promise<Todo> {
    if (!this.db) throw new Error('Database not initialized');

    const todo = await this.db.getFirstAsync(
      `SELECT * FROM todos WHERE id = ?`,
      [id]
    ) as Todo;

    if (!todo) throw new Error('Todo not found');

    return this.updateTodo(id, { completed: !todo.completed });
  }

  async clearCompletedTodos(): Promise<void> {
    if (!this.db) throw new Error('Database not initialized');

    await this.db.runAsync(`DELETE FROM todos WHERE completed = 1`);
  }
}

export const databaseService = new DatabaseService();

