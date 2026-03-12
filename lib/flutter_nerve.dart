// flutter_nerve — Sensory-Reactive UI Engine for Flutter.
//
// Make your app feel the real world: react to battery level, network quality,
// device motion, ambient light, and sound through a clean, composable API.

// Core model
export 'src/models/nerve_state.dart';

// Controller & provider
export 'src/nerve_controller.dart';
export 'src/nerve_provider.dart';

// Sense adapters (for advanced custom use)
export 'src/senses/battery_sense.dart';
export 'src/senses/network_sense.dart';
export 'src/senses/motion_sense.dart';
export 'src/senses/light_sense.dart';
export 'src/senses/sound_sense.dart';

// Reactive widgets
export 'src/widgets/nerve_builder.dart';
export 'src/widgets/reactive_container.dart';
export 'src/widgets/nerve_scaffold.dart';
export 'src/widgets/nerve_pulse.dart';
export 'src/widgets/nerve_glow.dart';
export 'src/widgets/nerve_battery_icon.dart';
export 'src/widgets/nerve_monitor.dart';
export 'src/widgets/nerve_shake.dart';
export 'src/widgets/nerve_spring.dart';
export 'src/widgets/nerve_connectivity.dart';

// Adaptive theme
export 'src/nerve_theme.dart';

// Testing utilities
export 'src/testing/nerve_fakes.dart';
