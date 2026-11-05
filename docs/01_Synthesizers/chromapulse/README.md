# ChromaPulse (`v2.9.0`)

> **Step-Sequenced Ratchet Rhythm Synthesizer**  
> Precision rhythmic drum & bassline synthesizer built for modern electronic production, ratcheting arpeggios, and tempo-synced filter movement.

---

## 📚 Tech-to-Music Translator (How It Actually Works in Plain English)

### 🔹 Class-A Drum Bus Transformer Saturation
Drums have super fast spikes (transients) that can clip digital converters before they even sound loud. Passing the master drum bus through a modeled Class-A analog transformer gently hugs those microsecond drum spikes and adds warm low-end weight—giving kicks and snares instant record-ready punch.

### 🔹 Sub-Step Ratcheting
Instead of playing just one note per 16th-note step, ratcheting rapidly subdivides a single step into 2, 3, or 4 mini-strikes—creating those signature rolling Tangerine Dream / modern techno synth fills.

---

## 🗂️ Version & Patch History

- **[`v2.9.0` (2026-11-05) — Class-A Transformer Drum Bus Stage, Jury-Stabilized 24-Band EQ & Clipboard [FEEDBACK]](./v2.9.0_2026-11-05.md)**
  - **Class-A AnalogConsoleStage Drum Bus Output**: Replaced hard tanh clipping on the master bus with discrete transformer saturation, 5 Hz sub-rumble DC blocking, and automatic `NaN`/`Inf` self-healing.
  - **Jury-Stabilized 24-Band Master EQ & SVF Protection**: Added pole-stability clamping across all 24 Master EQ bands and per-pad State-Variable Filters.
  - **Upgraded 1-Click Clipboard [FEEDBACK] Shield**: Automatically copies diagnostic reports to your Windows Clipboard (`Ctrl+V` ready for Discord).

- **[`v2.8.0` (2026-10-21) — 7-Zone Acoustic EQ Backdrop, Stack-Allocated Spectrum & 0.002f Fine Stepping](./v2.8.0_2026-10-21.md)**
  - **Pro-Q 3 Style 7-Zone Mixing Backdrop**: Visual frequency guide (Sub, Bass, Low-Mid, Mid, Upper-Mid, Presence, Air).
  - **Zero-Lag Spectrum & EQ Rendering**: Stack-allocated `DrawLines` curve rendering with cut-filter vertical `Q` dragging.
  - **Universal Auto-Updater Shield**: 1-click in-plugin updates.

---

## 🛠️ Known Issues & Bug Reporting

- None currently open in v2.9.0.

**Found a bug or weird preset behavior?**  
Click the **`[ FEEDBACK ]`** button in the top-right header of the plugin! It automatically snapshots your patch, EQ curve, and screenshot, copies a diagnostic summary to your Clipboard (`Ctrl+V` ready for Discord), or opens a pre-filled [GitHub Bug Report](https://github.com/haidood/chroma-release/issues/new).
