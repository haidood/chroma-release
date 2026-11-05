# ChromaVerb (`v2.9.1`)

> **Studio Algorithmic Multi-Room FDN Reverb & Shimmer**  
> Lush, zero-metallic algorithmic studio reverb powered by an 8x8 unitary Feedback Delay Network, orthogonal stereo taps, and forward octave-up shimmer.

---

## 📚 Tech-to-Music Translator (How It Actually Works in Plain English)

### 🔹 8x8 Fast Walsh-Hadamard Unitary Matrix (FDN)
In a real concert hall, sound bounces off thousands of walls and blends into a smooth wash. Cheap digital reverbs only use a few echoes that sound like a ringing metal pipe. An 8x8 Hadamard Matrix takes 8 separate delay lines and cross-mixes every single echo into all 8 rooms simultaneously without losing or gaining a single decibel of energy—creating an endlessly dense, silky reverb tail.

### 🔹 C1 Continuous Polynomial Hann Shimmer Window
Shimmer reverb pitches your reverb tail up by +12 semitones (one octave) by slicing the audio into tiny overlapping grains. Using a smooth polynomial 'Hann window' fades the edges of every grain in and out seamlessly so the octave-up halo sounds like an angelic choir instead of a glitchy pitch-shifter.

---

## 🗂️ Version & Patch History

- **[`v2.9.1` (2026-11-05) — Jury-Stabilized Post-EQ Biquads, NaN Self-Healing & 1-Click Clipboard [FEEDBACK]](./v2.9.1_2026-11-05.md)**
  - **Jury Stability Triangle Pole Clamping**: Guaranteed z-plane pole stability across all 12 Post-EQ and Decay Rate EQ bands even under extreme `Q` and shelf sweeps.
  - **Automatic NaN/Inf Self-Healing**: Real-time biquad state protection ensures long shimmer/freeze tails never drop audio.
  - **Upgraded 1-Click Clipboard [FEEDBACK]**: Instant `Ctrl+V` diagnostic report copy for Discord and GitHub.

- **[`v2.9.0` (2026-10-22) — 8x8 Fast Walsh-Hadamard Unitary Matrix & Forward 2x Octave-Up Shimmer](./v2.9.0_2026-10-22.md)**
  - **8x8 Fast Walsh-Hadamard (FWHT_8) Unitary Matrix**: Replaced basic delay feedback with a true 8-channel unitary diffusion network with alternating sign injection and orthogonal stereo taps.
  - **Forward 2x Octave-Up Shimmer Loop**: Dual-grain pitch shifter with zero-transcendental C1 polynomial Hann windowing inside the tank.
  - **24-Band Parametric Post-EQ**: Sculpt the exact frequency curve of your reverb tail.

---

## 🛠️ Known Issues & Bug Reporting

- None currently open in v2.9.1.

**Found a bug or weird preset behavior?**  
Click the **`[ FEEDBACK ]`** button in the top-right header of the plugin! It automatically snapshots your patch, EQ curve, and screenshot, copies a diagnostic summary to your Clipboard (`Ctrl+V` ready for Discord), or opens a pre-filled [GitHub Bug Report](https://github.com/haidood/chroma-release/issues/new).
