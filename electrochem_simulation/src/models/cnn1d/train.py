import sys
from pathlib import Path
import pandas as pd
import numpy as np
import torch
import torch.nn as nn
from torch.utils.data import TensorDataset, DataLoader

# PROJECT PATH
PROJECT_ROOT = Path(__file__).resolve().parents[3]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))
from src.models.cnn1d.model import ElectrochemicalCNN1D

# CONFIGURATION
METHOD = "CV"
DATA_DIR = (PROJECT_ROOT / "data" / "cnn_ready" / METHOD)
MODEL_DIR = (PROJECT_ROOT / "models" / "cnn1d")
MODEL_DIR.mkdir(parents=True, exist_ok=True)
BATCH_SIZE = 32
EPOCHS = 50
LEARNING_RATE = 1e-3
NUM_CLASSES = 6
SEED = 42
SUBSTANCES = ["dopamine", "uric_acid", "ascorbic_acid", "glucose", "copper", "aluminum",]

# REPRODUCIBILITY
torch.manual_seed(SEED)
np.random.seed(SEED)

# DEVICE
DEVICE = torch.device(
    "cuda"
    if torch.cuda.is_available()
    else "cpu"
)

# LOAD DATASET
def load_dataset():
    print()
    print("LOADING CNN DATASET")
    print()
    print("Method :", METHOD)
    print("Data   :", DATA_DIR)
    X_train = np.load(DATA_DIR / "X_train.npy")
    X_val = np.load(DATA_DIR / "X_val.npy")
    y_train = np.load(DATA_DIR / "y_train.npy")
    y_val = np.load(DATA_DIR / "y_val.npy")
    print()
    print("X_train:", X_train.shape)
    print("y_train:", y_train.shape)
    print("X_val  :", X_val.shape)
    print("y_val  :", y_val.shape)
    return (X_train, y_train, X_val, y_val,)

# PREPARE TENSOR
def prepare_tensor(X, y):
    
    # Original:
    # (samples, signal_length)
    # CNN 1D:
    # (samples, channels, signal_length)
    X = torch.tensor(X, dtype=torch.float32)
    X = X.unsqueeze(1)
    y = torch.tensor(y, dtype=torch.long)
    return X, y
# CREATE DATALOADER
def create_dataloaders(X_train, y_train, X_val, y_val):
    X_train, y_train = prepare_tensor(X_train, y_train)
    X_val, y_val = prepare_tensor(X_val, y_val)
    train_dataset = TensorDataset(X_train, y_train)
    val_dataset = TensorDataset(X_val, y_val)
    train_loader = DataLoader(train_dataset, batch_size=BATCH_SIZE, shuffle=True)
    val_loader = DataLoader(val_dataset, batch_size=BATCH_SIZE, shuffle=False)
    return (train_loader, val_loader)
# TRAIN ONE EPOCH
def train_one_epoch(model, loader, criterion, optimizer):
    model.train()
    total_loss = 0.0
    correct = 0
    total = 0
    for X, y in loader:
        X = X.to(DEVICE)
        y = y.to(DEVICE)
        optimizer.zero_grad()
        output = model(X)
        loss = criterion(output, y)
        loss.backward()
        optimizer.step()
        total_loss += (loss.item()* X.size(0))
        predictions = output.argmax(dim=1)
        correct += (predictions == y).sum().item()
        total += X.size(0)
    average_loss = (total_loss / total)
    accuracy = (correct / total)
    return (average_loss, accuracy)
# VALIDATION
def validate(model, loader, criterion):
    model.eval()
    total_loss = 0.0
    correct = 0
    total = 0
    with torch.no_grad():
        for X, y in loader:
            X = X.to(DEVICE)
            y = y.to(DEVICE)
            output = model(X)
            loss = criterion(output, y)
            total_loss += (loss.item()* X.size(0))
            predictions = output.argmax(dim=1)
            correct += (predictions == y).sum().item()
            total += X.size(0)
    average_loss = (total_loss / total)
    accuracy = (correct / total)
    return (average_loss, accuracy)
# MAIN
def main():
    print()
    print("CNN 1D BASELINE TRAINING")
    print()
    print("Device:", DEVICE)
    # Load dataset
    X_train, y_train, X_val, y_val = (load_dataset())
    # DataLoader
    train_loader, val_loader = (
        create_dataloaders(X_train, y_train, X_val, y_val))
    print()
    print("CNN input:")
    sample_batch = next(iter(train_loader))
    print("Train batch:", sample_batch[0].shape)
    # Model
    model = ElectrochemicalCNN1D(num_classes=NUM_CLASSES)
    model = model.to(DEVICE)
    print()
    print("Model:")
    print(model)
    # Loss
    criterion = nn.CrossEntropyLoss()
    # Optimizer
    optimizer = torch.optim.Adam(model.parameters(), lr=LEARNING_RATE)
    # Best model
    best_val_accuracy = -1.0
    best_model_path = (MODEL_DIR / "cnn1d_cv_best.pth")
    # Training history
    history = []
    # TRAINING
    print()
    print("TRAINING")
    for epoch in range(1,EPOCHS + 1):
        
        # Train
        train_loss, train_accuracy = (train_one_epoch(model, train_loader, criterion, optimizer))
        
        # Validation
        val_loss, val_accuracy = (validate(model, val_loader, criterion))
        
        # Save history
        history.append(
            {
                "epoch": epoch,
                "train_loss": train_loss,
                "train_accuracy": train_accuracy,
                "val_loss": val_loss,
                "val_accuracy": val_accuracy,
            }
        )
        # Print
        print(
            f"Epoch [{epoch:02d}/{EPOCHS}] "
            f"| Train Loss: {train_loss:.4f} "
            f"| Train Acc: {train_accuracy:.4f} "
            f"| Val Loss: {val_loss:.4f} "
            f"| Val Acc: {val_accuracy:.4f}"
        )
        # SAVE BEST MODEL
        if val_accuracy > best_val_accuracy:
            best_val_accuracy = val_accuracy
            torch.save(
                {
                    "model_state_dict":
                        model.state_dict(),
                    "val_accuracy":
                        val_accuracy,
                    "epoch":
                        epoch,
                    "method":
                        METHOD,
                    "substances":
                        SUBSTANCES,
                    "num_classes":
                        NUM_CLASSES,
                },best_model_path)
            print(f"  -> Saved best model " f"(val_acc={val_accuracy:.4f})")
    # SAVE TRAINING HISTORY
    history_file = (MODEL_DIR/ "cnn1d_cv_history.csv")
    history_df = pd.DataFrame(history)
    history_df.to_csv(history_file, index=False)
    # COMPLETE
    print()
    print("=" * 70)
    print("TRAINING COMPLETE")
    print("=" * 70)
    print()
    print(f"Best validation accuracy: " f"{best_val_accuracy:.4f}")
    print()
    print(f"Best model saved at:\n" f"{best_model_path}")
    print()
    print(f"Training history saved at:\n" f"{history_file}")

# ENTRY POINT
if __name__ == "__main__":
    main()