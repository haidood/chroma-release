# ChromaCore & ChromaCorePro (`v2.8.5`)

> **32-Voice Hybrid Analog / Wavetable / FM Workstation Synth**  
> Our flagship 3-oscillator synthesizer combining warm hardware-modeled analog drift, 4-point cubic wavetables, dual Moog/Oberheim filters, 8-style FM/Mod oscillator, 16-step Performer & Miami Sequencer, 3-band multiband distortion, 12-band studio EQ, OTT dynamics, Magic Fattener, BBD Delay, and Studio Reverb.

![ChromaCore & ChromaCorePro v2.8.5 Release Card](../../assets/ChromaCore_v2.8.5_Release_Card.png)

---

## 📚 Tech-to-Music Translator (How It Actually Works in Plain English)

### 🔹 4-Point Catmull-Rom Cubic Wavetable Interpolation
Think of a digital waveform like a connect-the-dots drawing. Basic synths draw straight lines between the dots, which creates sharp corners that sound like harsh, metallic 'digital fizz' on high notes. Cubic interpolation bends a smooth, natural curve through 4 dots at a time—making digital wavetables sound as smooth and liquid as analog tape.

### 🔹 Spectral-Adaptive 'MAGIC' Drive & OTT Piggyback
Traditional distortion boosts every frequency equally, turning chords into muddy fuzz. The MAGIC knob listens to your sound split into 3 frequency zones (Sub Bass, Musical Mids, and High Air). It gives your sub bass a tight 'Pultec-style' punch, focuses warm tube saturation right where the human ear loves it (the midrange), and gently tames harsh treble above 6 kHz—while sneaking in upward multiband compression (OTT) so quiet details jump forward.

### 🔹 Prophet-6 / OB-6 Polyphonic Stereo Spread & VCO Drift
On vintage analog polysynths, every voice lives on its own physical circuit board with slightly different capacitors and resistors. In STEREO mode, ChromaCore places each note of your chord at a slightly different stereo pan position and gives the left and right speakers microscopic phase differences—so a dry chord immediately sounds wide and 3D even with zero reverb or chorus.

### 🔹 Biquad Filter Poles & The 'Unit Circle' (EQ Stability)
Digital EQ filters work by feeding a tiny bit of the output sound back into the input to boost or cut specific frequencies. Mathematically, if the feedback number crosses '1.0' (leaving the 'unit circle'), the filter acts like a microphone held right up to a speaker—instantly screaming to infinity and muting your DAW. In v2.8.5, we locked every EQ shelf inside a mathematical safety cage so it can never overload.

### 🔹 Inter-Stage Moog Ladder & SEM Tube Saturation
A classic 24dB Moog filter is built like a ladder with 4 rungs (stages). Instead of just distorting the sound before or after the filter, ChromaCore gently saturates the signal between every single rung of the ladder—giving you that thick, creamy, non-whistling analog resonance.

---

## 🗂️ Version & Patch History

- **[`v2.8.5` (2026-11-05) — Studio EQ Shelf Fix, Live 60 FPS MIDI Keybed, [KEYS] Stealth Mode & Clipboard Feedback](./v2.8.5_2026-11-05.md)**
  - **Fixed 12-Band Parametric EQ (`L-SH`, `H-SH`, and `NOTCH`)**: Fixed a coefficient sign bug in Low-Shelf (`L-SH`) and High-Shelf (`H-SH`) filters where deep cuts or switching a band from `NOTCH` to `H-SH` could push filter feedback past 100% and mute Ableton Live's audio engine.
  - **Vertical Notch Width Dragging**: Dragging a `NOTCH` node up or down on the EQ display now smoothly widens or narrows the notch `Q` (just like `HP` and `LP` cut filters) instead of storing hidden gain values.
  - **Self-Healing Audio Engine Protection**: Added automatic `NaN` / `Infinity` circuit-breakers inside every EQ biquad and the Master Analog Console output stage so extreme settings can never drop audio.
  - **Real-Time 60 FPS MIDI Keybed Highlighting**: Incoming MIDI notes played from your DAW or MIDI controller now light up the bottom 81-key keyboard in real time at 60 FPS.
  - **New `[ KEYS: ON / OFF ]` Stealth Switch**: Added a toggle button right next to `[ STEREO ]` in the top display. Turning `KEYS: OFF` collapses the bright white piano keys into a dark carbon-black **Live MIDI Monitor** bar.
  - **1-Click `[ FEEDBACK ]` Clipboard Bug Reporter**: Clicking `[ FEEDBACK ]` in the top-right bar captures your exact synth patch, EQ curve, and UI screenshot, and **copies a formatted diagnostic block straight to your Windows Clipboard** so you can press `Ctrl+V` directly in Discord or open a pre-filled GitHub report.

- **[`v2.8.4` (2026-11-04) — 'MAGIC' Spectral Fattener Knob, True Stereo/Mono Mode, Cubic Wavetables & Tube Filters](./v2.8.4_2026-11-04.md)**
  - **New `MAGIC` (Fatten) Knob**: Added next to `REVERB` in the `OUTPUT // SPACE` deck (`0%` by default). Combines 3-band spectral-adaptive saturation (Pultec sub weight, dynamic midrange warmth, silk air de-harsher) with automatic 3-Band OTT upward/downward density.
  - **New `[ STEREO ]` / `[ MONO ]` Header Switch**: Added right next to `32-POLY / LEGATO`. `STEREO` enables Prophet-6 style polyphonic voice pan spread and analog twin-VCO phase dispersion; `MONO` forces 100% phase-locked dual-mono output.
  - **4-Point Cubic Wavetable Interpolation**: Upgraded wavetable lookup from linear to 4-point Catmull-Rom cubic splines, eliminating high-note digital harshness.
  - **Unity-Gain `INTENSITY` Brightness Tilt**: Turning `INTENSITY` down now darkens harmonics like a warm analog lowpass roll-off without losing volume; turning it up adds subtle triode tube bloom.
  - **Inter-Stage Analog Filter Saturation**: Upgraded Filter 1 & Filter 2 with zero-DC asymmetric tube warmth and inter-stage ladder saturation.

- **[`v2.8.3` (2026-11-03) — Scream/Acid Filter Self-Oscillation Fix & 8 New Flagship Presets](./v2.8.3_2026-11-03.md)**
  - **Fixed Filter 1 'Scream Overdrive' & 'Acid 303' Whistle**: Added dynamic input-envelope damping to the filter resonance feedback loop (`ChromaDualFilter`) so high-resonance patches (`Chroma Vowel II Vocal`, `Acid 303 Squelch`) decay to dead silence the moment you release a key instead of ringing at 1038 Hz.
  - **8 New Production Presets (Presets 56–63)**: Added * Silk Tape Keys*, *Sub Zero 808*, *CyberpunkReese*, *Velvet Chords*, *Pluck Horizon*, *Neuro Bassline*, *Glass Bell Pad*, and *Analog Brass CS80*.

- **[`v2.8.2` (2026-10-23) — 8-Style Universal Modulation Oscillator Overhaul & Dual Filter Routing Fix](./v2.8.2_2026-10-23.md)**
  - **8 Modulation Oscillator Styles**: Upgraded the `MOD OSC // SHAPER & FM` deck with 8 distinct synthesis modes: *RingMod*, *PhaseFM*, *WTMorph*, *ExpoFM*, *HardSync*, *Wavefolder*, *DriveScream*, and *Tremolo*.
  - **10 Modulation Targets**: Route the Mod Osc to *Osc 1*, *Osc 2*, *Osc 1+2*, *Osc 3*, *Filter 1*, *Filter 2*, *Filter 1+2*, *Volume*, *Pan*, or *Pitch*.
  - **Filter 2 Parallel Routing Fix**: Fixed a bug where oscillators routed to Filter 2 (`F2`) were attenuated when `FilterMix` was at default.

- **[`v2.8.0` (2026-10-10) — 12-Band Studio EQ, Persistent Double-Buffering & Zero-CPU Idle Throttling](./v2.8.0_2026-10-10.md)**
  - **12-Band Dynamic Studio EQ**: Full parametric EQ with 7 acoustic mixing zone backdrops, mousewheel `Q` control, and real-time spectrum analyzer.
  - **Zero-Allocation 60 FPS GUI**: Persistent GDI+ backbuffer cache and intelligent idle repaint throttling (`0.0%` CPU when stopped in Ableton Live / FL Studio).
  - **Universal Update Shield & Crash Vault**: Built-in 1-click updater and automatic session crash recovery.

---

## 🛠️ Known Issues & Bug Reporting

- None currently open in v2.8.5! (Previous v2.8.4 EQ Low-Shelf / High-Shelf / Notch transition audio drop and v2.8.2 Scream Filter 1038 Hz whistle are 100% resolved).

**Found a bug or weird preset behavior?**  
Click the **`[ FEEDBACK ]`** button in the top-right header of the plugin! It automatically snapshots your patch, EQ curve, and screenshot, copies a diagnostic summary to your Clipboard (`Ctrl+V` ready for Discord), or opens a pre-filled [GitHub Bug Report](https://github.com/haidood/chroma-release/issues/new).
