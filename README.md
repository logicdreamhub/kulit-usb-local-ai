# 🤖 User Guide

Welcome to **Kulit Server**! This tool allows you to run a powerful AI assistant directly on your computer. It is private, works offline, and doesn't require any subscriptions.

---

## ⚡ Quick Setup (Recommended)
If you just downloaded this from GitHub, you are missing the AI engine and models.
1.  **[Download the Full Package Assets here](https://github.com/logicdreamhub/kulit-usb-local-ai/releases/latest)**
2.  Place the `kulit.llamafile` file inside the **`bin/`** folder.
3.  Place the `.gguf` model files inside the **`models/`** folder.
4.  You are now ready to start!

### ⚠️ Hardware Compatibility (If the Server Crashes)
If your server crashes immediately upon starting with a **"Hardware Incompatibility Detected"** error, your computer's processor does not support the advanced math required by some models (like those ending in `Q4_K_M`).
*   **The Fix:** You must use models ending in **`Q4_0`** or **`Q8_0`**. These use standard math that works on almost any computer.
*   **Recommended Model (Great for 8GB RAM):** [Download Llama-3.2-3B-Instruct-Q4_0.gguf](https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_0.gguf) (~1.9 GB). Place this file in your `models/` folder and select it when you start the server.

---

## 🚀 How to Start

The simplest way to start is to use the **Kulit AI Desktop** application for your system:

### **Linux Users**
1.  Double-click the **`Kulit-App`** file in this folder.
2.  *(Note: If it doesn't open, run `chmod +x Kulit-App` in your terminal).*

### **Windows & Mac Users**
*Once compiled, you will see a `Kulit-App.exe` (Windows) or `Kulit-App.app` (Mac) here.*

---

## 🛠️ Legacy Launchers (Alternative)
If you prefer using terminal-based scripts or if the main application is missing, you can find the older launchers in the **`scripts/legacy/`** folder:
*   **Linux/Mac:** `scripts/legacy/Start_Linux.sh` or `scripts/legacy/Start_Mac.command`
*   **Windows:** `scripts/legacy/Start_Windows.bat`

---


## ⚙️ Performance Modes

When you start the engine in the app, you can choose a "Performance Mode":

*   **1️⃣ Lightweight Mode (Recommended):**
    *   **Best for:** Most users and everyday chat.
    *   **Benefit:** Uses very little of your computer's memory (RAM). Your computer will stay fast while the AI is running.
*   **2️⃣ Maximum Mode:**
    *   **Best for:** Summarizing long documents or complex logic.
    *   **Benefit:** Allows the AI to "remember" much longer conversations, but uses more of your computer's power.

---

## 🌍 How to Use the AI
The app contains its own chat interface. Once the engine is started, you can begin chatting immediately!
*   No need to open a separate web browser.
*   Type your message in the chat box at the bottom and press Enter!

---

## 🛑 How to Stop
When you are finished using the AI:
1.  Simply close the **Kulit AI Desktop** app window.
2.  The engine will automatically stop using your computer's memory.

---

## 📂 Folders Explained
*   **models/**: This is where the "brains" of the AI live. You can add more `.gguf` files here to use different models.
*   **bin/**: Contains the engine and GUI components. Do not delete this!
*   **server.log**: Contains technical details for troubleshooting.
*   **scripts/legacy/**: Contains old terminal-based launchers for advanced users.


### 💡 Quick Tips
*   **Keep the window open:** If you close the black "Kulit Server" window, the AI will stop working.
*   **Privacy:** Since this runs on **your** computer, none of your chats are sent to the internet. It is 100% private.
