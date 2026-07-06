import torch
import pandas as pd


def prepare_input(data, scaler_x, features):
    """
    Prépare les données pour le modèle en conservant
    les noms des colonnes attendus par le scaler.
    """

    values = {feature: getattr(data, feature) for feature in features}

    df = pd.DataFrame([values], columns=features)

    return scaler_x.transform(df)


def predict_risk(model, scaler_x, scaler_y, data, features):
    x = prepare_input(data, scaler_x, features)

    x = torch.tensor(x, dtype=torch.float32).unsqueeze(0)

    with torch.no_grad():
        pred = model(x).numpy()

    pred = scaler_y.inverse_transform(pred)

    return {
        "risk_today": float(pred[0][0]),
        "risk_7d": float(pred[0][1]),
        "risk_14d": float(pred[0][2]),
        "risk_21d": float(pred[0][3]),
    }