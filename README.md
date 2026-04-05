# ⏱ FPGA Stopwatch

A hardware stopwatch implemented in VHDL for an FPGA board, featuring a 4-digit 7-segment display, button debouncing, and automatic time-range display switching.

---

## ✨ Features

- ▶️ **Start / Pause / Resume** with a single button
- 🔄 **Reset** to zero from any state
- 🔢 **Automatic display mode switching** — shows `SS.ms`, `MM:SS`, or `HH:MM` depending on elapsed time
- 🛡️ **Hardware debouncing** for clean, glitch-free button input
- 💡 **Multiplexed 4-digit 7-segment display** with ~2.6 ms per-digit refresh

---

## 🔧 Hardware Requirements

| Component | Details |
|-----------|---------|
| FPGA board | Any Xilinx board with a 100 MHz clock (e.g. Basys 3, Nexys A7) |
| Display | 4-digit common-anode 7-segment display |
| Buttons | 2 push buttons (active high) |

> **Pin mapping:** Adjust the XDC constraints file to match your specific board's button and display pin assignments.

---

## 📁 Project Structure

```
stopwatch/
├── stop_watch.vhd          # Top-level entity — state machine & time counters
├── seven_seg_driver.vhd    # Multiplexed 7-segment display driver
├── debouncer.vhd           # Generic N-channel button debouncer
└── README.md
```

---

## 🏗️ Architecture Overview

### 🔀 State Machine (`stop_watch.vhd`)

The stopwatch operates as a 3-state FSM:

```
        playBtn (rising edge)          playBtn (rising edge)
IDLE ────────────────────────► RUNNING ◄────────────────────── PAUSE
 ▲                                 │                               │
 └─────────── resetBtn ────────────┘                               │
 └─────────────────────────────── resetBtn ─────────────────────────┘
```

| State | Description |
|-------|-------------|
| `IDLE` | Counters held at zero |
| `RUNNING` | Counters incrementing each clock cycle |
| `PAUSE` | Counters frozen, display held |

### ⏲️ Time Counters

The 100 MHz system clock is divided down through a chain of counters:

```
100 MHz clock
    └─► tick_counter  (0 → 999 999, i.e. every 10 ms)
            └─► tens_ms   (0 → 99)
                    └─► seconds  (0 → 59)
                            └─► minutes  (0 → 59)
                                    └─► hours    (0 → 23)
```

### 🖥️ Display Mode

The display automatically switches content based on elapsed time:

| Mode | Condition | Display format |
|------|-----------|----------------|
| `SEC` | hours = 0, minutes = 0 | `SS.cs` (seconds + centiseconds) |
| `MIN` | minutes > 0 | `MM:SS` |
| `H` | hours > 0 | `HH:MM` |

### 🧹 Debouncer (`debouncer.vhd`)

A generic, N-channel synchronous debouncer. The input must remain stable for 2²⁰ clock cycles (~10.5 ms at 100 MHz) before the output is updated.

```vhdl
DBOUNCER : entity work.debouncer generic map(n => 2) port map(
    clk => clk,
    raw => playBtn & resetBtn,
    clean => cleanBtns
);
```

### 📟 7-Segment Driver (`seven_seg_driver.vhd`)

Drives a 4-digit multiplexed display. The 20-bit `refreshCount` counter's top 2 bits select the active digit (~2.6 ms per digit, ~105 Hz full refresh rate). The `digits` input is a 16-bit vector of four packed 4-bit BCD values.

---

## 🕹️ Button Mapping

| Button | Role |
|--------|------|
| `playBtn` | Start (from IDLE) → Pause (from RUNNING) → Resume (from PAUSE) |
| `resetBtn` | Return to IDLE from RUNNING or PAUSE |

> Edge detection is used on `playBtn` so that holding the button does not cause repeated transitions.

---

## 🚀 Building & Flashing

1. Open Vivado and create a new RTL project.
2. Add all `.vhd` source files.
3. Add your board's XDC constraints file and map the ports:
   - `clk` → system clock
   - `playBtn`, `resetBtn` → two push buttons
   - `seg[6:0]` → 7-segment cathodes
   - `an[3:0]` → 7-segment anodes
4. Run **Synthesis → Implementation → Generate Bitstream**.
5. Flash to the board via Vivado Hardware Manager.

---

## ⚠️ Known Limitations & Possible Improvements

- 🔒 The display mode can only advance (never revert to `SEC` once minutes have counted past 0).
- 🏁 No lap/split time functionality.
- ➖ No decimal point or colon segment control (display segments are not lit to show separators).
- 🔁 Rollover is graceful (hours wrap 23 → 0) but there is no overflow indicator.

---

## 📄 License

This project is released for educational purposes. No warranty is provided.
