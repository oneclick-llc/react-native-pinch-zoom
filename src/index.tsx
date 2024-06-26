import {
  requireNativeComponent,
  UIManager,
  Platform,
  ViewStyle,
  StyleProp,
} from 'react-native';
import type { PropsWithChildren } from 'react';

const LINKING_ERROR =
  `The package 'react-native-pinch-zoom' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

interface PinchZoomProps extends PropsWithChildren<any> {
  style?: StyleProp<ViewStyle>;
  disableScrollViewOnPinch?: boolean;
  onDoubleTap?: () => void;
  onTap?: () => void;
  onPinchStart?(): void;
  onPinchEnd?(): void;
  disabledPinchZoom?: boolean;
  /**
   * @platform Android
   *
   * @defaults true
   */
  shouldAdjustSystemUi?: boolean;
}

const ComponentName = 'PinchZoomView';

export const PinchZoomView =
  UIManager.getViewManagerConfig(ComponentName) != null
    ? requireNativeComponent<PinchZoomProps>(ComponentName)
    : () => {
        throw new Error(LINKING_ERROR);
      };
