# AI Story Buddy 🎧✨

> Mobile Developer Challenge — Shamim Khan

A kid-first Flutter app where an audio story plays, then a delightful quiz pops up to check comprehension — built for joy, smoothness, and correctness on modest Android hardware.

---

## 1. Framework Choice — Flutter

I went with **Flutter**. The main reason: a single codebase that runs natively on both Android and iOS without compromising feel. For a kid-facing product like Peblo, consistent visual quality across devices matters — a child on an older Android tablet and one on an iPhone should get the same smooth animations and vibrant UI.

Flutter's widget model also made building the layered, joyful UI genuinely fun. The animation APIs (`AnimationController`, `Tween`, `AnimatedSwitcher`) are expressive enough that I could prototype and iterate quickly without reaching for third-party libraries. Dart's strong typing kept the quiz data models clean and predictable.

I considered React Native but ruled it out because bridging overhead for audio and animation on mid-range Android introduces jank that's hard to tune away, especially when frame timing is critical.

---

## 2. Audio → Quiz Transition State

The transition is driven by a single `AudioPlayerState` enum the UI subscribes to:

```dart
enum AudioPlayerState { idle, loading, playing, completed, error }
```

When `just_audio` fires `processingState == ProcessingState.completed`, the state updates to `AudioPlayerState.completed`. The quiz widget listens via a `ValueNotifier` and uses an `AnimatedSwitcher` with a `FadeTransition` to cross-dissolve from the audio player card to the quiz card.

I added a deliberate **400ms post-completion delay** before triggering the swap — enough breathing room so the last word of the story doesn't feel cut off, but short enough that kids don't lose attention.

I also guarded against the edge case where a user rapidly taps replay right as the transition fires, by checking state is still `completed` before initiating the swap.

---

## 3. Data-Driven Quiz Renderer

The quiz is fully decoupled from any hardcoded question or option count:

```dart
class QuizQuestion {
  final String questionText;
  final List<QuizOption> options;   // any length
  final String correctOptionId;
}

class QuizOption {
  final String id;
  final String label;
  final String? imageAsset;  // optional illustration
}
```

The `QuizRenderer` widget maps over `options.length` and builds option tiles dynamically. Layout adapts automatically:
- **2 options** → horizontal row
- **3–4 options** → 2×2 grid
- **5+ options** → scrollable list

Drop in a new JSON question file with any structure and the renderer handles it without a single UI change. Correct/incorrect state is tracked per option **ID** (not index), so re-ordering options doesn't break anything.

---

## 4. Caching Strategy

For **local assets** (bundled audio), Flutter's asset system handles caching at the OS level — no extra work needed.

For **remote audio** (future extension), I'd use `flutter_cache_manager` with a custom subclass:

```dart
class AudioCacheManager extends CacheManager {
  static const key = 'audioCache';
  AudioCacheManager() : super(Config(
    key,
    maxNrOfCacheObjects: 50,
    stalePeriod: Duration(days: 7),
  ));
}
```

Flow: check cache → return cached file URI if fresh → otherwise download and store, then pass the local file URI to `just_audio`. This means story audio works **fully offline** after first play — important for kids on spotty school Wi-Fi. I'd also pre-fetch the next story's audio in the background while the current one plays, so transitions feel instant.

---

## 5. Audio Loading & Failure States

Audio lifecycle is managed through `just_audio` with explicit handling at each stage:

- **Loading**: a custom animated waveform indicator appears while buffering. Not a generic spinner — intentional and kid-appropriate.
- **Playback errors**: I catch errors from `playbackEventStream` and map them to friendly messages. Network error → *"Let's try that again!"* with a retry button. Asset error → gentler fallback.
- **Disposal**: `AudioPlayer.dispose()` is called in the widget's `dispose()` lifecycle method. Zero resource leaks.
- **Interruptions**: phone calls, notifications — I listen to `playerStateStream` to update UI state when audio focus is lost and restored. No stuck "Playing" button when you come back.
- **iOS silent mode**: the `audio_session` package sets `AVAudioSessionCategoryPlayback` so playback isn't ducked by silent mode.

---

## 6. Performance Profiling

### What I Measured

I ran Flutter DevTools' Performance overlay on a mid-range Android setup (emulator with 2× CPU throttle). I focused on three jank-prone moments:

1. Initial build of the `StoryScreen` widget tree
2. The audio → quiz `AnimatedSwitcher` transition
3. Wrong-answer shake animation + color feedback on quiz options

### What I Found & Changed

Initial profiling showed the quiz option grid was doing a **full rebuild on every wrong-answer tap** — every tile re-rendered even though only the tapped one changed. I fixed this by:

- Wrapping each `QuizOptionTile` in a `RepaintBoundary`
- Moving selected/wrong state into a local `ValueNotifier` per tile instead of a parent-level `setState`

**Before**: frame times during wrong-answer feedback spiked to **28–34ms** (below 60fps).  
**After**: consistently **10–14ms**, well within the 16ms budget.

### Frame Timing Screenshot

The screen recording includes a brief Flutter performance overlay section — UI thread frames stay in the green zone (under 16ms) throughout audio playback and quiz interaction, with no red bars during transitions.

---

## 7. Staying Lightweight on Mid-Range Android

- **No heavy image formats**: illustrations are small PNGs under 100KB or `CustomPainter` drawings. No full-bleed JPEGs thrashing memory.
- **RepaintBoundary on animated widgets**: the waveform loader and quiz tiles are isolated so repaints don't cascade up the tree.
- **Lazy initialization**: `AudioPlayer` and quiz data initialize on screen mount, not at app launch.
- **Curves over physics**: `CurvedAnimation` with `Curves.easeOutCubic` for the quiz card entrance instead of `SpringSimulation` — lighter on CPU, looks just as good.
- **Minimal dependencies**: `just_audio` for playback, `audio_session` for session management. That's it for non-trivial packages.

---

## 8. AI Usage & Judgment

### Where I Used AI

I used Claude to help with: boilerplate for the `just_audio` stream subscription setup (it's verbose), suggesting the `ValueNotifier`-per-tile pattern when I described my rebuilding issue, and a review pass on disposal code to catch potential leaks.

### One Suggestion I Rejected

Claude suggested using a **Hero animation** for the audio → quiz card transition, since both share a visual container. I tried it — looked slick on iOS, but caused noticeable frame drops during the Hero flight on my throttled Android test (Hero animations bypass `RepaintBoundary` isolation mid-flight). I swapped it for `AnimatedSwitcher` + `FadeTransition`, which delivers a clean cross-dissolve at a fraction of the render cost.

### What Didn't Work

My first attempt at the audio → quiz transition used a `Timer` with a fixed delay instead of listening to the actual `processingState` stream. This worked fine in testing but occasionally misfired if audio loaded slowly — the timer would fire before playback even started. I scrapped the timer entirely and moved to proper stream-based state listening, which is both more reliable and architecturally correct.

---

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── quiz_question.dart
│   └── quiz_option.dart
├── services/
│   └── audio_service.dart
├── screens/
│   └── story_screen.dart
└── widgets/
    ├── audio_player_card.dart
    ├── quiz_renderer.dart
    ├── quiz_option_tile.dart
    └── waveform_loader.dart
```

---

*Shamim Khan — Peblo Mobile Developer Challenge*
