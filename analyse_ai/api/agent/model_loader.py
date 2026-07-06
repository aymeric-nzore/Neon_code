from pathlib import Path
import torch
import joblib
import json

# =====================================================
# Chemins
# =====================================================

ROOT_DIR = Path(__file__).resolve().parents[2]

MODELS_DIR = ROOT_DIR / "models"

MODEL_PATH = MODELS_DIR / "cacao_lstm.pth"
SCALER_X_PATH = MODELS_DIR / "scaler_x.pkl"
SCALER_Y_PATH = MODELS_DIR / "scaler_y.pkl"
CONFIG_PATH = MODELS_DIR / "model_config.json"

class LSTMModel(torch.nn.Module):
    def __init__(self, input_size, hidden_size=64, num_layers=2):
        super().__init__()
        self.lstm = torch.nn.LSTM(
            input_size=input_size,
            hidden_size=hidden_size,
            num_layers=num_layers,
            batch_first=True
        )
        self.fc = torch.nn.Linear(hidden_size, 4)

    def forward(self, x):
        out, _ = self.lstm(x)
        out = out[:, -1, :]
        return self.fc(out)


def load_artifacts():
    with open(CONFIG_PATH, "r") as f:
        config = json.load(f)

    scaler_x = joblib.load(SCALER_X_PATH)
    scaler_y = joblib.load(SCALER_Y_PATH)

    model = LSTMModel(input_size=len(config["features"]))
    model.load_state_dict(torch.load(MODEL_PATH, map_location="cpu"))
    model.eval()

    return model, scaler_x, scaler_y, config