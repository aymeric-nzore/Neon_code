from datetime import datetime
from pydantic import BaseModel, Field


class SensorInput(BaseModel):
    """
    Données envoyées par une plantation ou un capteur.
    """

    plantation_id: int = Field(
        ...,
        ge=1,
        description="Identifiant unique de la plantation"
    )

    timestamp: datetime = Field(
        ...,
        description="Date et heure de la mesure"
    )

    temperature_air: float = Field(
        ...,
        ge=0,
        le=60,
        description="Température de l'air (°C)"
    )

    humidity_air: float = Field(
        ...,
        ge=0,
        le=100,
        description="Humidité de l'air (%)"
    )

    rainfall: float = Field(
        ...,
        ge=0,
        description="Précipitations (mm)"
    )

    light_intensity: float = Field(
        ...,
        ge=0,
        description="Intensité lumineuse (klux)"
    )

    soil_moisture: float = Field(
        ...,
        ge=0,
        le=100,
        description="Humidité du sol (%)"
    )

    soil_ph: float = Field(
        ...,
        ge=0,
        le=14,
        description="pH du sol"
    )