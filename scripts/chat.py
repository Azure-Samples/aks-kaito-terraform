# Import packages
import os
import sys
import requests
import json
from openai import AsyncAzureOpenAI
import logging
import chainlit as cl
from azure.identity import DefaultAzureCredential, get_bearer_token_provider
from dotenv import load_dotenv
from dotenv import dotenv_values

# Load environment variables from .env file
if os.path.exists(".env"):
    load_dotenv(override=True)
    config = dotenv_values(".env")

# Read environment variables
temperature = float(os.environ.get("TEMPERATURE", 0.9))
top_p = float(os.environ.get("TOP_P", 1))
top_k = float(os.environ.get("TOP_K", 10))
max_length = int(os.environ.get("MAX_LENGTH", 4096))
api_base = os.getenv("AZURE_OPENAI_BASE")
api_key = os.getenv("AZURE_OPENAI_KEY")
api_type = os.environ.get("AZURE_OPENAI_TYPE", "azure")
api_version = os.environ.get("AZURE_OPENAI_VERSION", "2023-12-01-preview")
engine = os.getenv("AZURE_OPENAI_DEPLOYMENT")
model = os.getenv("AZURE_OPENAI_MODEL")
system_content = os.getenv("AZURE_OPENAI_SYSTEM_MESSAGE", "You are a helpful assistant.")
max_retries = int(os.getenv("MAX_RETRIES", 5))
timeout = int(os.getenv("TIMEOUT", 30))
debug = os.getenv("DEBUG", "False").lower() in ("true", "1", "t")
useLocalLLM = os.getenv("USE_LOCAL_LLM", "False").lower() in ("true", "1", "t")
aiEndpoint = os.getenv("AI_ENDPOINT", "")

if not useLocalLLM:
    # Create Token Provider
    token_provider = get_bearer_token_provider(
        DefaultAzureCredential(),
        "https://cognitiveservices.azure.com/.default",
    )

    # Configure OpenAI
    if api_type == "azure":
        openai = AsyncAzureOpenAI(
            api_version=api_version,
            api_key=api_key,
            azure_endpoint=api_base,
            max_retries=max_retries,
            timeout=timeout,
        )
    else:
        openai = AsyncAzureOpenAI(
            api_version=api_version,
            azure_endpoint=api_base,
            azure_ad_token_provider=token_provider,
            max_retries=max_retries,
            timeout=timeout,
        )

# Configure a logger
logging.basicConfig(
    stream=sys.stdout,
    format="[%(asctime)s] {%(filename)s:%(lineno)d} %(levelname)s - %(message)s",
    level=logging.INFO,
)
logger = logging.getLogger(__name__)


@cl.on_chat_start
async def start_chat():
    await cl.Avatar(
        name="Chatbot",
        url="https://cdn-icons-png.flaticon.com/512/8649/8649595.png",
    ).send()
    await cl.Avatar(
        name="Error",
        url="https://cdn-icons-png.flaticon.com/512/8649/8649595.png",
    ).send()
    await cl.Avatar(
        name="You",
        url="https://media.architecturaldigest.com/photos/5f241de2c850b2a36b415024/master/w_1600%2Cc_limit/Luke-logo.png",
    ).send()

    if not useLocalLLM:
        cl.user_session.set(
            "message_history",
            [{"role": "system", "content": system_content}],
        )

@cl.on_message
async def on_message(message: cl.Message):

    # Create the Chainlit response message
    msg = cl.Message(content="")

    if useLocalLLM:
        payload = {
            "prompt": f"{message.content} answer:",
            "return_full_text": False,
            "clean_up_tokenization_spaces": False, 
            "prefix": None,
            "handle_long_generation": None,
            "generate_kwargs": {
                "max_length": max_length,
                "min_length": 0,
                "do_sample": True,
                "early_stopping": False,
                "num_beams":1,
                "num_beam_groups":1,
                "diversity_penalty":0.0,
                "temperature": temperature,
                "top_k": top_k,
                "top_p": top_p,
                "typical_p": 1,
                "repetition_penalty": 1,
                "length_penalty": 1,
                "no_repeat_ngram_size":0,
                "encoder_no_repeat_ngram_size":0,
                "bad_words_ids": None,
                "num_return_sequences":1,
                "output_scores": False,
                "return_dict_in_generate": False,
                "forced_bos_token_id": None,
                "forced_eos_token_id": None,
                "remove_invalid_values": True
            }
        }

        headers = {"Content-Type": "application/json", "accept": "application/json"}
        response = requests.request(
            method="POST", 
            url=aiEndpoint, 
            headers=headers, 
            json=payload
        )

        # convert response.text to json
        result = json.loads(response.text)
        result = result["Result"]

        # remove all double quotes
        if '"' in result:
            result = result.replace('"', "")

        msg.content = result

    else:
        message_history = cl.user_session.get("message_history")
        message_history.append({"role": "user", "content": message.content})
        logger.info("Question: [%s]", message.content)

        async for stream_resp in await openai.chat.completions.create(
            model=model,
            messages=message_history,
            temperature=temperature,
            stream=True,
        ):
            if stream_resp and len(stream_resp.choices) > 0:
                token = stream_resp.choices[0].delta.content or ""
                await msg.stream_token(token)

        if debug:
            logger.info("Answer: [%s]", msg.content)

        message_history.append({"role": "assistant", "content": msg.content})

    await msg.send()
