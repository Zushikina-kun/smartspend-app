---

## ⚠️ DEPRECATED — April 15, 2026

**This entire document describes a method that no longer works.**

Alibaba shut down the Qwen free OAuth tier on **April 15, 2026**. The token extraction method described here (extracting a `localStorage` token from `chat.qwen.ai` and routing it through `qwen.aikit.club`) now returns **401 Unauthorized** errors. Multiple GitHub repositories that hosted this proxy have been archived or marked as deprecated confirming the shutdown.

**Do NOT follow these instructions.** They will not work.

### What works instead (September 2026)

| Method | How | Free limit |
|---|---|---|
| **Groq free tier** | `qwen/qwen3.6-27b` or `qwen/qwen3.8-27b` via `api.groq.com` | 1,000 req/day each |
| **NVIDIA NIM** | `qwen/qwen3.8-27b` via `integrate.api.nvidia.com/v1` | Free allocation on signup |
| **OpenRouter** | Check `openrouter.ai/models?max_price=0` for current `:free` Qwen models | Varies |

The correct free way to use Qwen models is through **Groq** — which also happens to be in SmartSpend's multi-provider failover chain at Tiers 4 and 5 (`qwen/qwen3.6-27b` and `qwen/qwen3.8-27b`). No token extraction, no third-party proxy, no ToS violation.

See `docs/archive/LLM_Engineering_Cheatsheet_v6.md` Appendix A for the full, current free provider directory.

---

## Original Document (Archived for Reference Only)

> The steps below are kept for historical reference. They describe the method as it existed before April 2026. **Do not attempt to follow them.**

---

### **1\. Installing OpenCode Terminal**

Choose your preferred terminal installation method:  
**macOS / Linux Script (Recommended)**

Bash  
curl \-fsSL https://opencode.ai/install | bash

**npm Global Installation**

Bash  
npm install \-g opencode-ai

**Homebrew (macOS)**

Bash  
brew install anomalyco/tap/opencode

Confirm the installation:

Bash  
opencode \--version

### **2\. Extracting the Qwen API Access Token**

> 1. Open [chat.qwen.ai](https://chat.qwen.ai) in your web browser and ensure you are logged in.  
> 2. Open the Developer Tools console (**F12** or **Cmd \+ Option \+ I** on macOS $\\rightarrow$ **Console** tab).  
> 3. Paste the following JavaScript snippet and press **Enter**:

JavaScript  
javascript: (function () {  
  if (window.location.hostname \!== "chat.qwen.ai") {  
    alert("🚀 This code is for chat.qwen.ai");  
    window.open("https://chat.qwen.ai", "\_blank");  
    return;  
  }  
  function getApiKeyData() {  
    const token \= localStorage.getItem("token");  
    if (\!token) {  
      alert("❌ qwen access\_token not found \!\!\!");  
      return null;  
    }  
    return token;  
  }  
  async function copyToClipboard(text) {  
    try {  
      await navigator.clipboard.writeText(text);  
      return true;  
    } catch (err) {  
      console.error("❌ Failed to copy to clipboard:", err);  
      const textarea \= document.createElement("textarea");  
      textarea.value \= text;  
      textarea.style.position \= "fixed";  
      textarea.style.opacity \= "0";  
      document.body.appendChild(textarea);  
      textarea.focus();  
      textarea.select();  
      const success \= document.execCommand("copy");  
      document.body.removeChild(textarea);  
      return success;  
    }  
  }  
  const apiKeyData \= getApiKeyData();  
  if (\!apiKeyData) return;  
  copyToClipboard(apiKeyData).then((success) \=\> {  
    if (success) {  
      alert("🔑 Qwen access\_token copied to clipboard \!\!\! 🎉");  
    } else {  
      prompt("🔰 Qwen access\_token:", apiKeyData);  
    }  
  });  
})();

The script extracts your authorization token from localStorage and copies it to your clipboard.

### **3\. Configuring OpenCode for Qwen Proxy**

Create or edit your global configuration file at \~/.config/opencode/opencode.json (or opencode.json in your project root):

JSON  
{  
  "provider": {  
    "qwen": {  
      "npm": "@ai-sdk/openai-compatible",  
      "name": "Qwen API Proxy",  
      "options": {  
        "baseURL": "https://qwen.aikit.club/v1",  
        "apiKey": "YOUR\_COPIED\_QWEN\_ACCESS\_TOKEN"  
      },  
      "models": {  
        "qwen3-coder-plus": {  
          "name": "Qwen 3 Coder Plus"  
        },  
        "qwen3.8-max": {  
          "name": "Qwen 3.8 Max"  
        }  
      }  
    }  
  }  
}

*Replace "YOUR\_COPIED\_QWEN\_ACCESS\_TOKEN" with the token obtained from Step 2\.*

### **4\. Running and Managing OpenCode Sessions**

Launch OpenCode directly with your target model:

Bash  
\# General coding and fast refactoring:  
opencode \--model qwen/qwen3-coder-plus

\# High-level architecture, deep reasoning, or web search:  
opencode \--model qwen/qwen3.8-max

**Mid-Session Navigation:**

> * **Switch Models:** Press **Ctrl \+ X** then **M**, or type /models inside the chat prompt.  
> * **Toggle Reasoning:** Press **Ctrl \+ T** to cycle thinking/reasoning modes.

### **5\. Proxy Reference & Other Implementations**

> * **Repository:** [encryptarun/qwen-api](https://github.com/encryptarun/qwen-api)  
> * **API Documentation:** [qwen-api.readme.io](https://qwen-api.readme.io/)

**Additional Proxy Features & Tool Integrations:**

> * **Claude Code Integration:** Claude Code expects Anthropic API endpoints (/v1/messages). To use Qwen with Claude Code, run a local middleware proxy (such as claude-code-proxy or LiteLLM) to convert Anthropic requests to OpenAI format before pointing your ANTHROPIC\_BASE\_URL to it.  
> * **Specialized Endpoints:** The proxy also exposes endpoints for image generation (/v1/images/generations), image editing (/v1/images/edits), video creation (/v1/videos/generations), and specialized workflows (qwen-deep-research, qwen-web-dev, qwen-slides).