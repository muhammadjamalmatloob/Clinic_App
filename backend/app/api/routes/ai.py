import os
from fastapi import APIRouter, HTTPException, status
from app.schemas.ai import ChatRequest, ChatResponse
import google.generativeai as genai

router = APIRouter()

# Initialize Gemini if key is available
api_key = os.getenv("GEMINI_API_KEY")
if api_key:
    genai.configure(api_key=api_key)
else:
    print("WARNING: GEMINI_API_KEY is not set. AI Symptom Checker will fail.")

SYSTEM_PROMPT = """
You are the Clinic AI Assistant, a helpful symptom triage bot. 
Analyze the user's symptoms and suggest potential departments or services (e.g. General Consultation, Child Care, Ultrasound).
CRITICAL: You MUST include a disclaimer stating "This is not medical advice. Please consult a doctor." in your response.
Keep your responses concise, empathetic, and professional.
"""

@router.post("/chat", response_model=ChatResponse, tags=["ai"])
async def chat_with_ai(request: ChatRequest):
    if not api_key:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="GEMINI_API_KEY is not configured on the server."
        )

    try:
        # The user specifically requested 'gemini 3.1 flash lite'. 
        model_name = "gemini-3.1-flash-lite"
        model = genai.GenerativeModel(
            model_name=model_name,
            system_instruction=SYSTEM_PROMPT
        )
        
        # Convert our messages to Gemini format
        formatted_messages = []
        for msg in request.messages:
            formatted_messages.append({
                "role": msg.role,
                "parts": [msg.content]
            })
            
        # Call model
        response = model.generate_content(formatted_messages)
        return ChatResponse(reply=response.text)
        
    except Exception as e:
        print(f"Gemini API Error: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail=f"Failed to generate response: {str(e)}"
        )
