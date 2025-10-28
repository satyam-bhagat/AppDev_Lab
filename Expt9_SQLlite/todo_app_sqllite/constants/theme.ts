/**
 * Below are the colors that are used in the app. The colors are defined in the light and dark mode.
 * There are many other ways to style your app. For example, [Nativewind](https://www.nativewind.dev/), [Tamagui](https://tamagui.dev/), [unistyles](https://reactnativeunistyles.vercel.app), etc.
 */

import { Platform } from 'react-native';

const tintColorLight = '#22c55e'; // A fresh modern green
const tintColorDark = '#10b981'; // Emerald accent for dark mode
const backgroundLight = '#f8fafc'; // Subtle very light gray
const backgroundDark = '#1e293b'; // Slate dark
const cardLight = '#ffffffee'; // UI card (slightly translucent)
const cardDark = '#334155cc'; // UI card, for contrast
const accentRed = '#e11d48'; // For delete, error
const accentYellow = '#facc15'; // For highlight
const accentBlue = '#3b82f6'; // For info

export const Colors = {
  light: {
    text: '#22223b',
    background: backgroundLight,
    tint: tintColorLight,
    card: cardLight,
    icon: '#64748b',
    tabIconDefault: '#64748b',
    tabIconSelected: tintColorLight,
    accent: accentBlue,
    error: accentRed,
    warning: accentYellow,
    shadow: '#0002',
  },
  dark: {
    text: '#f8fafc',
    background: backgroundDark,
    tint: tintColorDark,
    card: cardDark,
    icon: '#cbd5e1',
    tabIconDefault: '#cbd5e1',
    tabIconSelected: tintColorDark,
    accent: accentBlue,
    error: accentRed,
    warning: accentYellow,
    shadow: '#000a',
  },
};

export const Fonts = Platform.select({
  ios: {
    sans: 'Poppins', // Modern, clean Google Font (add to project if needed)
    serif: 'Georgia',
    rounded: 'Poppins',
    mono: 'Menlo',
  },
  android: {
    sans: 'Roboto',
    serif: 'serif',
    rounded: 'Roboto',
    mono: 'monospace',
  },
  default: {
    sans: 'Roboto',
    serif: 'serif',
    rounded: 'Roboto',
    mono: 'monospace',
  },
  web: {
    sans: "'Poppins', 'Roboto', system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif",
    serif: "Georgia, 'Times New Roman', serif",
    rounded: "'Poppins', 'Roboto', Arial, sans-serif",
    mono: "Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New', monospace",
  },
});
