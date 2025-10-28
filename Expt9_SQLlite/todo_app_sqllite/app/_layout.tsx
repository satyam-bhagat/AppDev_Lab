import { DefaultTheme, ThemeProvider } from '@react-navigation/native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import 'react-native-reanimated';
import { TodoProvider } from '@/contexts/TodoContext';
import { useColorScheme } from '@/hooks/use-color-scheme';

const AppTheme = {
  ...DefaultTheme,
  colors: {
    ...DefaultTheme.colors,
    background: '#f9fafb',
  },
};

export default function RootLayout() {
  const colorScheme = useColorScheme();

  return (
    <TodoProvider>
      <ThemeProvider value={AppTheme}>
        <Stack>
          <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
          <Stack.Screen name="modal" options={{ presentation: 'modal', title: 'Add Todo' }} />
        </Stack>
        <StatusBar style="dark" />
      </ThemeProvider>
    </TodoProvider>
  );
}
