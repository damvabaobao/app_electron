import torch
import torch.nn as nn

class ElectrochemicalCNN1D(nn.Module):
        def __init__(self, num_classes=6):
                super().__init__()
                self.features = nn.Sequential(

                        # Block 1
                        nn.Conv1d(in_channels=1, out_channels=32, kernel_size=7, padding=3),
                        nn.BatchNorm1d(32),
                        nn.ReLU(),
                        nn.MaxPool1d(kernel_size=2),

                        # Block 2
                        nn.Conv1d(in_channels=32, out_channels=64, kernel_size=5, padding=2),
                        nn.BatchNorm1d(64),
                        nn.ReLU(),
                        nn.MaxPool1d(kernel_size=2),

                        # Block 3
                        nn.Conv1d(in_channels=64, out_channels=128, kernel_size=5, padding=2),
                        nn.BatchNorm1d(128),
                        nn.ReLU(),

                        # Global average pooling
                        nn.AdaptiveAvgPool1d(1)
                )
                self.classifier = nn.Sequential(nn.Flatten(), nn.Linear(128, 64), nn.Dropout(0.30), nn.Linear(64, num_classes))
        def forward(self, x):
                x = self.features(x)
                x = self.classifier(x)
                return x

if __name__ == "__main__":
        model = ElectrochemicalCNN1D(num_classes = 6)
        print("CNN 1D MODEL")
        print(model)
        dummy_input = torch.randn(8, 1, 1000)
        output = model(dummy_input)
        print()
        print("Input shape :", dummy_input.shape)
        print("Output shape :", output.shape)
        print()
        print("Expected output:")
        print("(batch_size, 6)")