# Project Blueprint

## Overview

This document outlines the plan for redesigning a calculator application with a modern, neumorphic user interface. The goal is to create a visually appealing, intuitive, and feature-rich calculator that provides an exceptional user experience.

## Implemented Features

- **Neumorphic Design:** A modern, soft UI with a tactile feel.
- **Responsive Layout:** Adapts to portrait and landscape modes.
- **Color-Coded Buttons:** Intuitive colors for operators, actions, and the equals button.
- **Interactive Feedback:** Ripple effect and haptic feedback on button presses.
- **Basic History:** An inline, scrollable view of recent calculations.
- **Dynamic Sizing:** Expression and result fields that resize to prevent overflow.

## New Feature Plan

Here is a detailed plan for the new features to be implemented:

### 1. UI Redesign

- **Display Area:**
    - Large, bold numbers for the result, right-aligned.
    - Smaller, lighter gray text for the calculation expression above the result.
    - Smooth animation transitions when numbers change.
- **Buttons:**
    - Rounded rectangles with subtle depth shadows.
    - **Numbers:** Neutral (white or black, depending on theme).
    - **Operators (+, −, ×, ÷, %):** Accent color (orange).
    - **Clear/AC and delete:** Red.
    - **Equal (=):** Highlighted dominant color (blue).
- **Spacing & Layout:**
    - Equal padding and margin between buttons.
    - Consistent alignment and a balanced grid layout.
- **Dark/Light Mode:**
    - Both themes will be updated with the new color scheme and higher contrast for better readability.
- **Interaction:**
    - Ripple effect or soft shadow on button press.
- **Mini-History Panel:**
    - A panel below the display showing the last 2–3 results.
    - Swiping up on the panel will reveal the full history.
- **Typography:**
    - Use of Roboto or Inter for a minimal and elegant look.

### 2. Smart History
- **Interactive Mini-History:** The history items below the display will be tappable, allowing users to load a previous calculation back into the display.
- **Searchable Full History:** A full-screen history panel will be implemented with a search bar to quickly find past calculations.

### 3. Automatic Scientific Mode
- **Landscape Layout:** When the device is rotated to landscape, the calculator will automatically expand to include scientific buttons (e.g., `sin`, `cos`, `tan`, `log`, `√`, `x²`).
- **Portrait Layout:** The portrait mode will remain a simple, standard calculator to avoid clutter for everyday users.

### 4. Currency & Unit Converter
- **Dedicated Tab/Screen:** A new section will be added to the app, accessible via a tab or button, for conversions.
- **Conversion Types:**
    - **Currency:** IDR ⇆ USD / EUR (using mock/fixed rates initially).
    - **Length:** cm ⇆ m ⇆ inch.
    - **Weight:** kg ⇆ lb.
