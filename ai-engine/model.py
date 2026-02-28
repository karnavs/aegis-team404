import pandas as pd
import numpy as np
import yfinance as yf
from ta.momentum import RSIIndicator, StochasticOscillator
from ta.trend import MACD, EMAIndicator
from ta.volatility import BollingerBands
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, classification_report
from xgboost import XGBClassifier

# 1. Download MORE Data
df = yf.download("BTC-USD", interval="1h", period="365d")

# Fix MultiIndex
if isinstance(df.columns, pd.MultiIndex):
    df.columns = df.columns.get_level_values(0)

# 2. Feature Engineering
df['returns'] = df['Close'].pct_change()

# RSI
df['rsi'] = RSIIndicator(df['Close'], window=14).rsi()

# MACD
macd = MACD(df['Close'])
df['macd'] = macd.macd()
df['macd_signal'] = macd.macd_signal()

# EMA
df['ema_20'] = EMAIndicator(df['Close'], window=20).ema_indicator()
df['ema_50'] = EMAIndicator(df['Close'], window=50).ema_indicator()

# Bollinger Bands
bb = BollingerBands(df['Close'], window=20)
df['bb_high'] = bb.bollinger_hband()
df['bb_low'] = bb.bollinger_lband()

# Stochastic
stoch = StochasticOscillator(df['High'], df['Low'], df['Close'])
df['stoch'] = stoch.stoch()

# Target
df['target'] = np.where(df['Close'].shift(-1) > df['Close'], 1, 0)

df = df.dropna()

features = [
    'returns','rsi','macd','macd_signal',
    'ema_20','ema_50',
    'bb_high','bb_low',
    'stoch'
]

X = df[features]
y = df['target']

# 3. Split (Time Series Safe)
split_index = int(len(df) * 0.8)

X_train = X.iloc[:split_index]
X_test = X.iloc[split_index:]
y_train = y.iloc[:split_index]
y_test = y.iloc[split_index:]

# 4. Stronger Model
model = XGBClassifier(
    n_estimators=300,
    max_depth=6,
    learning_rate=0.03,
    subsample=0.8,
    colsample_bytree=0.8,
    eval_metric='logloss'
)

model.fit(X_train, y_train)

# 5. Probability-Based Strict Filtering
probs = model.predict_proba(X_test)[:,1]

threshold = 0.6  # strict confidence
predictions = (probs > threshold).astype(int)

print("Accuracy:", accuracy_score(y_test, predictions))
print(classification_report(y_test, predictions))