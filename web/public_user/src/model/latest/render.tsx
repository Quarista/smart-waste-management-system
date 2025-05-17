import React, { useState, useRef } from "react";
import styled from "styled-components";
import { BsFillSendArrowUpFill } from "react-icons/bs";
import axios from "axios";
import { Toaster } from "react-hot-toast";
import { ModeToggle } from "@/components/theme/mode-toggle";
import { collection, doc, setDoc } from "firebase/firestore";
import { db } from "@/backend/firebase";

// Instructions for the AI model at the start
const instructions = `
${import.meta.env.VITE_AI_INSTRUCTIONS}
`;

// Array of loading phrases
const loadingPhrases = [
  "Loading...",
  "Please wait a moment...",
  "Generating response...",
  "Hang tight...",
  "Fetching data...",
  "Just a second...",
  "Almost there...",
  "Preparing your answer...",
  "Loading your response...",
  "Thinking...",
  "Processing your request...",
  "Getting things ready...",
  "Hold on...",
  "Loading your query...",
];

// Get a random loading phrase
const getRandomLoadingPhrase = () => {
  return loadingPhrases[Math.floor(Math.random() * loadingPhrases.length)];
};

const Model = () => {
  const [input, setInput] = useState("");
  const [messages, setMessages] = useState<{ text: string; sender: string }[]>(
    []
  );
  const [loading, setLoading] = useState(false);
  const [loadingMessage, setLoadingMessage] = useState("");
  const messagesEndRef = useRef<HTMLDivElement>(null);

  // Convert asterisks (*) to <b> tags for bold text
  const formatMessage = (text: string) => {
    return text.replace(/\*(.*?)\*/g, "<b>$1</b>");
  };

  
  const saveInputToFirestore = async (input: string) => {
    try {
      const timestamp = new Date().toISOString();
      const docId = `user-${new Date()
        .toLocaleString()
        .replace(/[/,: ]/g, "-")}`;
      const docRef = doc(collection(db, "chatInputs"), docId);
      await setDoc(docRef, {
        timestamp,
        input,
      });
      console.log("Fetched User Input");
    } catch (error) {
      console.error("Error: ", error);
    }
  };

  
  const saveResponseToFirestore = async (response: string) => {
    try {
      const timestamp = new Date().toISOString();
      const docId = `ai-${new Date().toLocaleString().replace(/[/,: ]/g, "-")}`;
      const docRef = doc(collection(db, "FetchResponses"), docId);
      await setDoc(docRef, {
        timestamp,
        response,
      });
      console.log("Data Fetched");
    } catch (error) {
      console.error("Error: ", error);
    }
  };

  
  const handleMessageSend = async (retryCount = 0) => {
    if (input.trim()) {
      const newMessages = [...messages, { text: input, sender: "user" }];
      setMessages(newMessages);
      setInput("");
      setLoading(true);
      setLoadingMessage(getRandomLoadingPhrase());

      // Save user's input to Firestore
      await saveInputToFirestore(input);

      try {
        const response = await axios.post(
          `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=${
            import.meta.env.VITE_GEMINI_API_ID
          }`,
          {
            contents: [
              {
                parts: [
                  {
                    text:
                      instructions +
                      " Conversation history: " +
                      newMessages
                        .map((m) => `${m.sender}: ${m.text}`)
                        .join(" ") +
                      " User: " +
                      input,
                  },
                ],
              },
            ],
          },
          {
            headers: { "Content-Type": "application/json" },
          }
        );

        let aiMessage =
          response.data &&
          response.data.candidates &&
          response.data.candidates[0] &&
          response.data.candidates[0].content &&
          response.data.candidates[0].content.parts &&
          response.data.candidates[0].content.parts[0]
            ? response.data.candidates[0].content.parts[0].text
            : "No response generated. Something went wrong. Please try again later.";

        aiMessage = formatMessage(aiMessage);

        setMessages([...newMessages, { text: aiMessage, sender: "ai" }]);

        
        await saveResponseToFirestore(aiMessage);
      } catch (error: any) {
        if (error.response && error.response.status === 503 && retryCount < 3) {
          setTimeout(() => handleMessageSend(retryCount + 1), 2000);
        } else {
          console.error("Error fetching AI response:", error);
          let errorMessage =
            "Sorry, something went wrong. Please try again later.";
          if (error.response && error.response.status === 400) {
            errorMessage = "Responses Restricted on Production";
          } else if (error.response && error.response.status === 401) {
            errorMessage = "Unauthorized. Check your API key.";
          }
          setMessages([...newMessages, { text: errorMessage, sender: "ai" }]);

          
          await saveResponseToFirestore(errorMessage);
        }
      } finally {
        setLoading(false);
      }
    }
  };

  // Handle Enter key press to send message
  const handleKeyPress = (event: React.KeyboardEvent<HTMLInputElement>) => {
    if (event.key === "Enter") {
      handleMessageSend();
    }
  };

  return (
    <div className="bg-[url('https://images.unsplash.com/photo-1743046813915-94cf6d5e6942?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8YWJzdHJhY3QlMjBnbGFzc3xlbnwwfHwwfHx8MA%3D%3D')] dark:bg-[url('https://mir-s3-cdn-cf.behance.net/project_modules/max_1200/936a1d167362109.64275ee4a8a8a.jpg')] bg-no-repeat bg-cover min-h-screen pt-28 p-[20px]">
      {" "}
      <div>
        <Toaster />
      </div>
      <ChatContainer>
        <MessagesContainer>
          <div className="absolute top-0 right-0 p-4">
            <ModeToggle />
          </div>
          <MessageBubble>
            <h4>
              <b>
                Hi, I'm Duster🤖. Your AI Powered Assistant to suit your needs
                in our service!
              </b>
            </h4>

            <span>
              Get efficient, AI-powered help that's customized to enhance your
              service experience.
            </span>
            <br />

            <b>Here's what I can do for you:</b>
            <ul>
              <li>Provide you information regarding this project🧠</li>
              <li>Provide Technical Assistance✨</li>
              <li>Tips & Tricks💡</li>
            </ul>

            <span>Feel free to ask me anything.</span>
          </MessageBubble>
          {messages.map((msg, index) => (
            <MessageBubble
              key={index}
              $isUser={msg.sender === "user"}
              dangerouslySetInnerHTML={{ __html: msg.text }} // Render message with HTML tags (bold)
            />
          ))}
          {loading && <LoadingIndicator>{loadingMessage}</LoadingIndicator>}
          <div ref={messagesEndRef} /> {/* Auto-scroll target */}
        </MessagesContainer>
        <InputContainer>
          <ChatInput
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyPress={handleKeyPress}
            placeholder="Type here..."
            className="text-black dark:text-white"
          />
          <SendButton onClick={() => handleMessageSend()}>
            <BsFillSendArrowUpFill />
          </SendButton>
        </InputContainer>
        <ChatFooter>
          <span className="text-black dark:text-white text-xs text-center">
            Our AI Powered Assistant doesn't save your Chat History. Please
            avoid sharing sensitive personal information. AI Assistant may make
            mistakes. <br /> Please verify the information before taking any
            action.
          </span>
        </ChatFooter>
      </ChatContainer>
    </div>
  );
};

// Styled Components for UI

const ChatContainer = styled.div`
  @import url("https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;700&display=swap");
  font-family: "Poppins", sans-serif !important;
  display: flex;
  flex-direction: column;
  height: 80vh;
  justify-content: space-between;
  margin: 15px !important;
`;

const MessagesContainer = styled.div`
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  border-radius: 20px 20px 0px 0px;
  display: flex;
  flex-direction: column;
  background: rgba(255, 255, 255, 0.05);
  box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
  backdrop-filter: blur(5px);
  -webkit-backdrop-filter: blur(5px);
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.18);
`;

const MessageBubble = styled.div<{ $isUser?: boolean }>`
  margin-bottom: 12px;
  padding: 10px 15px;
  background-color: ${(props) =>
    props.$isUser ? "#3f3f46" : "rgba( 255, 255, 255, 0.7)"};
  align-self: ${(props) => (props.$isUser ? "flex-end" : "flex-start")};
  border-bottom-right-radius: ${(props) => (props.$isUser ? "2px !important" : "18px")};
  border-top-left-radius: ${(props) => (props.$isUser ? "18px" : "1px !important")};
  border-radius: 18px;
  color: ${(props) => (props.$isUser ? "white" : "black")};
  max-width: 80%;
  display: block;
  word-break: break-word;
  h5 {
    margin: 0 0 5px 0;
  }
  ul {
    padding-left: 20px;
    list-style-type: disc;
  }
  ul li {
    margin-bottom: 5px;
  }
`;

const InputContainer = styled.div`
  display: flex;
  padding: 10px;
  border: 1px solid #c7c7c7;
  border-top: 1px solid #ccc;
  border-radius: 0px 0px 20px 20px;
  background: rgba(255, 255, 255, 0.05);
  box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
  backdrop-filter: blur(5px);
  -webkit-backdrop-filter: blur(5px);
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.18);
`;

const ChatInput = styled.input`
  flex: 1;
  flex-grow: 1;
  width: 100%;
  padding: 10px 15px;
  border: 0.5px solid #71717a !important;
  border-radius: 15px;
  margin-right: 10px;
  font-family: "Poppins" !important;
  background: rgba(8, 51, 68, 0.05);
  box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.18);
`;

const SendButton = styled.button`
  background-color: #334155 !important;
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
  border: none !important;
  padding: 10px 10px !important;
  border-radius: 999px !important;
  color: white !important;
  font-family: sans-serif !important;
  cursor: pointer !important;
  width: 50px !important;
  transition: 0.1s ease;
  &:hover {
    background-color: #0f172a !important;
  }
`;

const LoadingIndicator = styled.div`
  align-self: center;
  margin: 10px;
  color: #ffffff;
`;

const ChatFooter = styled.div`
  padding: 10px;
  font-size: 12px;
  color: #ffffff;
  text-align: center;
`;

export default Model;
