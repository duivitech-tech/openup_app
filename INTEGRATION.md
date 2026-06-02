# Integration Guide - AI Chat Healer

## Quick Integration

### 1. WebSocket Connection

```javascript
const socket = io('http://localhost:5000');

socket.on('connect', () => {
  console.log('Connected');
});
```

### 2. Start Session

```javascript
socket.emit('start_session', {
  mood: 'lonely',      // optional, default: 'lonely'
  user_name: 'John'    // optional
});

socket.on('session_started', (data) => {
  console.log('Session ID:', data.session_id);
  console.log('Message:', data.message);
});
```

### 3. Send Messages

```javascript
socket.emit('chat', {
  message: 'Hey, I feel lonely today',
  auto_detect_mood: true  // optional, default: true
});

// Receive streaming response
socket.on('chat_chunk', (data) => {
  console.log(data.chunk);  // Real-time chunks
});

// Complete response
socket.on('chat_response', (data) => {
  console.log('Full message:', data.message);
});
```

### 4. Change Mood

```javascript
socket.emit('change_mood', {
  mood: 'anxious'
});
```

### 5. End Session

```javascript
socket.emit('end_session');

socket.on('session_ended', (data) => {
  console.log(data.message);
});
```

---

## Complete React Example

```jsx
import { useEffect, useState } from 'react';
import io from 'socket.io-client';

function ChatHealer() {
  const [socket, setSocket] = useState(null);
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [sessionId, setSessionId] = useState(null);
  const [currentMood, setCurrentMood] = useState('lonely');

  useEffect(() => {
    const newSocket = io('http://localhost:5000');
    
    newSocket.on('connect', () => {
      newSocket.emit('start_session', {
        mood: 'lonely',
        user_name: 'User'
      });
    });

    newSocket.on('session_started', (data) => {
      setSessionId(data.session_id);
      setCurrentMood(data.mood);
      setMessages([{ role: 'assistant', content: data.message }]);
    });

    newSocket.on('chat_response', (data) => {
      setMessages(prev => [...prev, { role: 'assistant', content: data.message }]);
    });

    newSocket.on('mood_changed', (data) => {
      setCurrentMood(data.mood);
      console.log('Mood changed to:', data.mood);
    });

    setSocket(newSocket);

    return () => newSocket.close();
  }, []);

  const sendMessage = () => {
    if (!input.trim()) return;
    
    setMessages(prev => [...prev, { role: 'user', content: input }]);
    socket.emit('chat', { message: input });
    setInput('');
  };

  const changeMood = (newMood) => {
    socket.emit('change_mood', { mood: newMood });
  };

  return (
    <div>
      <div className="mood-selector">
        Current Mood: <strong>{currentMood}</strong>
        <select onChange={(e) => changeMood(e.target.value)} value={currentMood}>
          <option value="lonely">Lonely</option>
          <option value="anxious">Anxious</option>
          <option value="bored">Bored</option>
          <option value="overthinking">Overthinking</option>
          <option value="breakup">Breakup</option>
          <option value="burnt out">Burnt Out</option>
        </select>
      </div>
      <div className="messages">
        {messages.map((msg, i) => (
          <div key={i} className={msg.role}>
            {msg.content}
          </div>
        ))}
      </div>
      <input 
        value={input} 
        onChange={(e) => setInput(e.target.value)}
        onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
        placeholder="Type your message..."
      />
      <button onClick={sendMessage}>Send</button>
    </div>
  );
}
```

---

## REST API Integration

### Create Session

```javascript
const response = await fetch('http://localhost:5000/api/session/create', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    mood: 'anxious',
    user_name: 'Sarah'
  })
});

const data = await response.json();
console.log('Session ID:', data.session.session_id);
```

### Get Session Info

```javascript
const response = await fetch(`http://localhost:5000/api/session/${sessionId}`);
const data = await response.json();
console.log('Session:', data);
```

### Get Conversation History

```javascript
const response = await fetch(`http://localhost:5000/api/session/${sessionId}/history?limit=20`);
const data = await response.json();
console.log('History:', data.messages);
```

### Delete Session

```javascript
const response = await fetch(`http://localhost:5000/api/session/${sessionId}`, {
  method: 'DELETE'
});
const data = await response.json();
console.log('Deleted:', data.success);
```

---

## Available Moods

- **`lonely`** - Need companionship and emotional connection
- **`anxious`** - Need calming support and reassurance
- **`bored`** - Need entertainment and engaging conversation
- **`overthinking`** - Need mental clarity and perspective
- **`breakup`** - Need healing support after relationship issues
- **`burnt out`** - Need rest and low-pressure comfort

---

## WebSocket Events Reference

### Client → Server Events

| Event | Data | Description |
|-------|------|-------------|
| `start_session` | `{mood?, user_name?}` | Start new chat session |
| `chat` | `{message, auto_detect_mood?}` | Send message |
| `change_mood` | `{mood}` | Change current mood |
| `end_session` | `{}` | End current session |

### Server → Client Events

| Event | Data | Description |
|-------|------|-------------|
| `session_started` | `{session_id, mood, message}` | Session created |
| `message_received` | `{message}` | Message acknowledged |
| `mood_changed` | `{mood, message?}` | Mood updated |
| `chat_chunk` | `{chunk}` | Streaming response chunk |
| `chat_response` | `{message, mood}` | Complete response |
| `session_ended` | `{message}` | Session terminated |
| `error` | `{message}` | Error occurred |

---

## Error Handling

```javascript
socket.on('error', (data) => {
  console.error('Error:', data.message);
  // Handle specific errors
  if (data.message.includes('Invalid mood')) {
    // Show mood selection UI
  }
});

socket.on('disconnect', () => {
  console.log('Disconnected from server');
  // Show reconnection UI
});
```

---

## Environment Setup

```bash
# .env file
OPENAI_API_KEY=your-openai-key-here
MONGODB_URI=mongodb://localhost:27017/
REDIS_URL=redis://localhost:6379
AUTO_DETECT_MOOD=true
FLASK_PORT=5000
```

---

## Production Deployment

### Docker
```bash
# Start services
docker-compose up -d --build

# Check logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Manual
```bash
# Install dependencies
pip install -r requirements.txt

# Set environment variables
export OPENAI_API_KEY="your-key"
export MONGODB_URI="mongodb://localhost:27017/"

# Run server
python app.py
```

---

## Health Check

```javascript
const response = await fetch('http://localhost:5000/api/health');
const data = await response.json();
console.log('Service status:', data.status);
console.log('Available moods:', data.moods);
```

Response:
```json
{
  "status": "ok",
  "service": "AI Chat Healer",
  "websocket": "enabled",
  "caching": "enabled",
  "redis": "✓ Connected",
  "mongodb": "✓ Connected",
  "moods": ["lonely", "anxious", "bored", "overthinking", "breakup", "burnt out"]
}
```