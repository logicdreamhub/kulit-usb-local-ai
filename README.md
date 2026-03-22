# 🤖 User Guide

Welcome to **Kulit Server**! This tool allows you to run a powerful AI assistant directly on your computer. It is private, works offline, and doesn't require any subscriptions.

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
1.  **Right-click** the file named **`Start_Linux.desktop`**.
2.  Select **"Allow Launching"** or **"Trust this executable"**.
3.  The icon will change. You can now **double-click** it to launch.

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
