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

### 1. Smart History
- **Interactive Mini-History:** The history items below the display will be tappable, allowing users to load a previous calculation back into the display.
- **Searchable Full History:** A full-screen history panel will be implemented with a search bar to quickly find past calculations.

### 2. Automatic Scientific Mode
- **Landscape Layout:** When the device is rotated to landscape, the calculator will automatically expand to include scientific buttons (e.g., `sin`, `cos`, `tan`, `log`, `√`, `x²`).
- **Portrait Layout:** The portrait mode will remain a simple, standard calculator to avoid clutter for everyday users.

### 3. Currency & Unit Converter
- **Dedicated Tab/Screen:** A new section will be added to the app, accessible via a tab or button, for conversions.
- **Conversion Types:**
  - **Currency:** IDR ⇆ USD / EUR (using mock/fixed rates initially).
  - **Length:** cm ⇆ m ⇆ inch.
  - **Weight:** kg ⇆ lb.

### 4. Quick Copy / Share
- **Copy on Long-Press:** Users will be able to long-press the result display to instantly copy the value to the clipboard.
- **Share Button:** An option will be provided to share the result directly to other apps like WhatsApp, Telegram, etc.

### 5. Dynamic Theming
- **System Theme Sync:** The app will automatically sync with the device’s system-wide light or dark mode.
- **Custom Accent Colors:** Users will be able to personalize the app by choosing from a predefined set of accent colors (e.g., blue, green, red) to replace the default orange.

## Technical Implementation Plan

1.  **Add Dependencies:** Add `share_plus` for the sharing feature.
2.  **Scientific Mode:** Use `OrientationBuilder` to create a responsive layout that changes based on device orientation.
3.  **Converter UI:** Create a new screen/widget for the unit converter and add a `TabBar` or similar navigation.
4.  **Copy/Share Logic:** Implement `Clipboard` services for copy functionality and integrate the `share_plus` package.
5.  **History Enhancement:** Add `onTap` handlers to history items and build a new searchable history view.
6.  **Theming Logic:** Use `provider` to manage the currently selected theme and accent color, allowing it to be changed dynamically.
