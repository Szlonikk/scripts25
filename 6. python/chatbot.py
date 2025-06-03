from __future__ import annotations  
import discord
import requests
import json
import logging
from dotenv import load_dotenv
import os

load_dotenv()
DISCORD_TOKEN = os.getenv("DISCORD_TOKEN")
OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL_NAME = "llama3"  


intents = discord.Intents.default()
intents.message_content = True
client = discord.Client(intents=intents)

games: dict[str, list[str]] = {
    "Counter Strike": [],
    "League of legends": [],
    "Valorant": [],
}

PATHS_TEXT = (
    "Dostępne ścieżki:\n"
    "1. Rejestracja\n"
    "2. Zasady\n"
    "3. Zgłoś wynik"
)
HELP_TEXT = (
    "Możesz po prostu zapytać o: listę gier, stan rozgrywek, dołączyć do gry, "
    "poznać ścieżki e‑sportowe lub pogadać. Nie musisz znać żadnych komend."
)

logging.basicConfig(format="[%(levelname)s] %(message)s", level=logging.INFO)



def call_ollama(model_prompt: str, system_prompt: str | None = None) -> str | None:
    payload: dict[str, object] = {
        "model": MODEL_NAME,
        "prompt": model_prompt,
        "stream": False,
    }
    if system_prompt:
        payload["system"] = system_prompt

    try:
        resp = requests.post(OLLAMA_URL, json=payload, timeout=60)
        resp.raise_for_status()
        return resp.json().get("response", "").strip()
    except Exception as exc:
        logging.error("Ollama connection error: %s", exc)
    return None


def determine_action(user_msg: str) -> dict[str, str]:
    dynamic_games = ", ".join(games.keys())
    system_prompt = (
        "Jesteś asystentem Discordowego bota do obsługi turnieju e‑sportowego.\n"
        f"Dostępne gry to: {dynamic_games}.\n\n"
        "Na podstawie wypowiedzi użytkownika zwróć WYŁĄCZNIE czysty obiekt JSON.\n"
        "Dopuszczalne wartości pola 'action':\n"
        "- list_paths  — użytkownik chce poznać ścieżki\n"
        "- list_games  — użytkownik pyta o listę gier\n"
        "- join_game   — użytkownik chce dołączyć do gry (wymagane 'game' i 'nick')\n"
        "- show_status — użytkownik pyta o stan rozgrywek/drużyn\n"
        "- help        — użytkownik prosi o pomoc\n"
        "- chat        — wszystko inne (small‑talk, pytania otwarte)\n\n"
        "Jeśli action == 'join_game', dodaj klucze 'game' i 'nick'.\n"
        "Nick może pochodzić z wypowiedzi lub pozostać pusty (bot użyje display_name).\n"
        "Przykład poprawnego JSON: {\"action\": \"join_game\", \"game\": \"Valorant\", \"nick\": \"KillerFox\"}"
    )

    assistant_resp = call_ollama(user_msg, system_prompt)
    if not assistant_resp:
        return {"action": "chat"}

    try:
        start, end = assistant_resp.find("{"), assistant_resp.rfind("}") + 1
        data = json.loads(assistant_resp[start:end])
        if isinstance(data, dict) and data.get("action"):
            return data
    except Exception as exc:
        logging.warning("Parsowanie JSON z LLM nieudane: %s; Otrzymano: %s", exc, assistant_resp)
    return {"action": "chat"}


def add_player(game: str, nick: str) -> str:
    canonical_game = next((g for g in games if g.lower() == game.lower()), None)
    if not canonical_game:
        return "Nie znaleziono takiej gry."

    games[canonical_game].append(nick)
    return (
        f"Dodano zawodnika **{nick}** do gry **{canonical_game}**. "
        f"Numer zawodnika: {len(games[canonical_game])}"
    )


def get_status() -> str:
    return "\n".join(
        f"{game} ({len(players)} zawodników): " + (", ".join(players) if players else "Brak")
        for game, players in games.items()
    )



@client.event
async def on_ready():
    logging.info("Bot zalogowany jako %s (ID: %s)", client.user, client.user.id)


@client.event
async def on_message(message: discord.Message):
   
    if message.author == client.user:
        return

    intent = determine_action(message.content)
    action = intent.get("action", "chat")

    if action == "list_paths":
        await message.channel.send(PATHS_TEXT)

    elif action == "list_games":
        await message.channel.send("Dostępne rozgrywki:\n" + "\n".join(games.keys()))

    elif action == "join_game":
        game = intent.get("game", "")
        nick = intent.get("nick") or message.author.display_name
        await message.channel.send(add_player(game, nick))

    elif action == "show_status":
        await message.channel.send(get_status())

    elif action == "help":
        await message.channel.send(HELP_TEXT)

    else:  
        response = call_ollama(message.content) or (
            "Ollama error spróbój ponownie"
        )
        
        if len(response) > 2000:
            response = response[:1997] + "..."
        await message.channel.send(response)


if __name__ == "__main__":
    if os.name == "nt":
        import asyncio
        asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

    client.run(DISCORD_TOKEN)
