# ChromaPulse (`v2.8.0`)

> **Step-Sequenced Ratchet Rhythm Synthesizer**  
> Precision rhythmic synthesizer built for modern electronic basslines, ratcheting arpeggios, and tempo-synced filter movement.

---

## 📚 Tech-to-Music Translator (How It Actually Works in Plain English)

### 🔹 Sub-Step Ratcheting
Instead of playing just one note per 16th-note step, ratcheting rapidly subdivides a single step into 2, 3, or 4 mini-strikes—creating those signature rolling Tangerine Dream / modern techno synth fills.

---

## 🗂️ Version & Patch History

- **[`v2.8.0` (2026-10-21) — 7-Zone Acoustic EQ Backdrop, Stack-Allocated Spectrum & 0.002f Fine Stepping](./v2.8.0_2026-10-21.md)**
  - **Pro-Q 3 Style 7-Zone Mixing Backdrop**: Visual frequency guide (Sub, Bass, Low-Mid, Mid, Upper-Mid, Presence, Air).
  - **Zero-Lag Spectrum & EQ Rendering**: Stack-allocated `DrawLines` curve rendering with cut-filter vertical `Q` dragging.
  - **Universal Auto-Updater Shield**: 1-click in-plugin updates.

---

## 🛠️ Known Issues & Bug Reporting

- None currently open in v2.8.0.

**Found a bug or weird preset behavior?**  
Click the **`[ FEEDBACK ]`** button in the top-right header of the plugin! It automatically snapshots your patch, EQ curve, and screenshot, copies a diagnostic summary to your Clipboard (`Ctrl+V` ready for Discord), or opens a pre-filled [GitHub Bug Report](https://github.com/haidood/chroma-release/issues/new).
