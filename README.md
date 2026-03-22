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

Depending on your computer, follow the simple steps below:

### **Windows Users**
1.  Open the folder where you saved Kulit.
2.  Double-click the file named **`Start_Windows.bat`**.
3.  A window will appear. Follow the on-screen instructions to select your model and performance mode.

### **Mac Users** (First-time setup)
Apple has high security for new apps. To start the first time:
1.  **Right-click** (or hold Control + Click) the file named **`Start_Mac.command`**.
2.  Select **Open With** -> **Terminal**.
3.  A popup will ask if you are sure; click **Open**.
4.  *Note: After doing this once, you can simply double-click the file normally in the future.*

### **Linux Users**
1.  Open your **Terminal**.
2.  Navigate to the folder where you saved Kulit.
3.  Run the script by typing: `./Start_Linux.sh`
    *(Note: If it says permission denied, run `chmod +x Start_Linux.sh` first).*

---

## ⚙️ Choosing the Right Mode

When you start the server, you will be asked to choose a "Performance Mode." Here is what they mean:

*   **1️⃣ Lightweight Mode (Recommended):**
    *   **Best for:** Most users and everyday chat.
    *   **Benefit:** Uses very little of your computer's memory (RAM). Your computer will stay fast while the AI is running.
*   **2️⃣ Maximum Mode:**
    *   **Best for:** Summarizing long documents or complex logic.
    *   **Benefit:** Allows the AI to "remember" much longer conversations, but uses more of your computer's power.

---

## 🌍 How to Use the AI
Once the loading bar reaches **100%**, your web browser will automatically open to the AI interface. 
*   If it doesn't open automatically, go to this address in your browser: `http://127.0.0.1:3690`
*   Type your message in the chat box at the bottom and press Enter!

---

## 🛑 How to Stop
When you are finished using the AI:
1.  Go back to the black "Kulit Server" window.
2.  Press the **[S]** key on your keyboard.
3.  The window will close, and the AI will stop using your computer's memory.

---

## 📂 Folders Explained
*   **models/**: This is where the "brains" of the AI live. You can add more `.gguf` files here to use different models.
*   **bin/**: Contains the engine that powers the AI. Do not delete this!
*   **server.log**: If the AI fails to start, this file contains technical details that can help a professional fix the issue.

---

### 💡 Quick Tips
*   **Keep the window open:** If you close the black "Kulit Server" window, the AI will stop working.
*   **Privacy:** Since this runs on **your** computer, none of your chats are sent to the internet. It is 100% private.
