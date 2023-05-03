# react-native-pinch-zoom

## About the project
Replicate easily the Instagram zooming feature for React Native


![](./preview.gif)

[Example](https://github.com/sergeymild/react-native-pinch-zoom/blob/main/example/src/App.tsx)

## Installation

```sh
"react-native-pinch-zoom": "sergeymild/react-native-pinch-zoom#0.2.0"
```

## Usage

```js
import { PinchZoomView } from "react-native-pinch-zoom";

// ...
// disableScrollViewOnPinch - prevent scrollView handle scroll events on pinch zoom (only on IOS)
// doubleTapEnabled - toggle double tap handle event
// onDoubleTap - callback which will be called on double tap
// tapEnabled - toggle tap handle event
// onTap - callback which will be called on tap

<PinchZoomView disableScrollViewOnPinch>
  <Video
    resizeMode={'cover'}
    muted
    source={{
      uri: 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    }}
    style={{ width: '100%', height: '100%' }}
  />
</PinchZoomView>
```

## Contributing]

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
