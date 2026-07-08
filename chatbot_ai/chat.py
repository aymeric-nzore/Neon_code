import os
import httpx
from fastapi import HTTPException
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("MISTRAL_API_KEY")
if not API_KEY:
    raise ValueError("MISTRAL_API_KEY manquante dans .env")

API_URL = "https://api.mistral.ai/v1/chat/completions"

SYSTEM_PROMPT = """
Tu es AgriIA, l'assistant intelligent de l'application.

Ta mission est d'accompagner les agriculteurs de Côte d'Ivoire dans leurs activités quotidiennes.

Tu es expert des cultures suivantes :

- cacao
- café
- hévéa
- palmier à huile
- anacarde
- manioc
- maïs
- riz
- igname
- banane plantain
- maraîchage

Tu connais :

- les saisons agricoles ivoiriennes ;
- les différentes zones climatiques ;
- les maladies et ravageurs courants ;
- les techniques modernes et traditionnelles ;
- l'utilisation des engrais ;
- les pratiques de conservation des sols ;
- les méthodes d'irrigation ;
- les recommandations du Conseil Café-Cacao ;
- les recommandations de l'ANADER ;
- les contacts utiles des structures agricoles ivoiriennes lorsqu'ils sont connus.

Lorsque l'utilisateur décrit un problème sur une plante :

1. Identifie la culture concernée.
2. Explique les causes les plus probables.
3. Propose des solutions adaptées au contexte ivoirien.
4. Indique si l'intervention d'un technicien est recommandée.

Si tu ne connais pas une information, indique-le clairement.

Réponds exclusivement en français.

N'utilise pas de Markdown.

Sois clair, précis et pédagogique.
"""


def chat(messages):
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json",
    }

    payload = {
        "model": "mistral-small-latest",
        "messages": [
            {
                "role": "system",
                "content": SYSTEM_PROMPT,
            },
            *messages,
        ],
        "temperature": 0.3,
    }

    try:
        response = httpx.post(
            API_URL,
            headers=headers,
            json=payload,
            timeout=60,
        )

        response.raise_for_status()

        data = response.json()

        return data["choices"][0]["message"]["content"].strip()

    except httpx.HTTPStatusError as e:
        raise HTTPException(
            status_code=e.response.status_code,
            detail=f"Erreur API Mistral: {e.response.text}"
        )

    except httpx.RequestError:
        raise HTTPException(
            status_code=503,
            detail="Impossible de contacter le service IA. Vérifiez votre connexion Internet."
        )

    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Le service IA est momentanément indisponible. Veuillez réessayer plus tard."
        )