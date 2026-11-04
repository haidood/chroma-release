# ChromaX (`v2.8.0`)

> **Flagship Synthesizer with 3D Keycaps & LED Jewels**  
> High-headroom polyphonic synthesizer featuring tactile 3D hardware keycaps, zero-noise clean oscillators, and studio multi-effects.

---

## 📚 Tech-to-Music Translator (How It Actually Works in Plain English)

### 🔹 Polyphonic Headroom Scaling
When you play a 6-note chord, 6 oscillators add together and can easily clip your master bus. ChromaX automatically balances per-voice gain so single-note leads and big 8-note chords sit at the same clean studio level.

---

## 🗂️ Version & Patch History

- **[`v2.8.0` (2026-10-21) — Zero Background Noise on Clean Presets, Polyphonic Headroom Scaling & Dirty-Rect UI](./v2.8.0_2026-10-21.md)**
  - **Silent Noise Floor on Clean Patches**: Defaulted `kParamNoise1Level = 0.0f` on clean factory presets so pure keys and pads have zero background hiss.
  - **Polyphonic Headroom Scaling**: Smooth multi-voice gain compensation prevents chord clipping.
  - **60 FPS Dirty-Rect Invalidation & Shift Fine-Tune**: `0.002f` Shift-drag precision and Universal Auto-Updater Shield.

---

## 🛠️ Known Issues & Bug Reporting

- None currently open in v2.8.0.

**Found a bug or weird preset behavior?**  
Click the **`[ FEEDBACK ]`** button in the top-right header of the plugin! It automatically snapshots your patch, EQ curve, and screenshot, copies a diagnostic summary to your Clipboard (`Ctrl+V` ready for Discord), or opens a pre-filled [GitHub Bug Report](https://github.com/haidood/chroma-release/issues/new).
