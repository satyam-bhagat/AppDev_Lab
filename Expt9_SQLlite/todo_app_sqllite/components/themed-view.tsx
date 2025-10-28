import { View, type ViewProps } from 'react-native';

import { Colors } from '@/constants/theme';
import { useThemeColor } from '@/hooks/use-theme-color';

export type ThemedViewProps = ViewProps & {
  lightColor?: string;
  darkColor?: string;
};

export function ThemedView({ style, lightColor, darkColor, card = false, ...otherProps }: any) {
  const backgroundColor = card
    ? useThemeColor({ light: Colors.light.card, dark: Colors.dark.card }, 'card')
    : useThemeColor({ light: lightColor, dark: darkColor }, 'background');

  return (
    <View
      style={[{
        backgroundColor,
        borderRadius: card ? 14 : 0,
        shadowColor: card ? useThemeColor({}, 'shadow') : undefined,
        shadowOpacity: card ? 0.09 : 0,
        shadowRadius: card ? 8 : 0,
        shadowOffset: card ? { width: 0, height: 2 } : undefined,
      }, style]}
      {...otherProps}
    />
  );
}
