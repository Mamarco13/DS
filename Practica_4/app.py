import io

from flask import Flask, jsonify, request
import numpy as np
import soundfile as sf
import librosa
from sklearn.metrics.pairwise import cosine_similarity as sklearn_cosine
from scipy.signal import resample, stft

app = Flask(__name__)


def read_audio(file_storage):
    data = file_storage.read()
    if not data:
        raise ValueError("empty file")
    samples, sample_rate = sf.read(io.BytesIO(data), dtype='float32')

    if samples.ndim > 1:
        samples = np.mean(samples, axis=1)

    return sample_rate, samples


def compute_spectrogram(samples, sample_rate, nperseg=1024, noverlap=512):
    if len(samples) < nperseg:
        pad = np.zeros(nperseg - len(samples), dtype=samples.dtype)
        samples = np.concatenate([samples, pad])

    _, _, zxx = stft(
        samples,
        fs=sample_rate,
        nperseg=nperseg,
        noverlap=noverlap,
        boundary=None,
    )

    magnitude = np.abs(zxx)
    return np.log1p(magnitude)


def cosine_similarity(spec_a, spec_b):
    a = np.mean(spec_a, axis=1)
    b = np.mean(spec_b, axis=1)

    denom = np.linalg.norm(a) * np.linalg.norm(b)
    if denom == 0:
        return 0.0

    return float(np.dot(a, b) / denom)

def compute_mfcc_similarity(y1, sr1, y2, sr2):
    # Extraer los MFCC (usualmente 13 o 20 coeficientes)
    # n_mfcc=13 es el estándar para reconocimiento de voz
    mfcc1 = librosa.feature.mfcc(y=y1, sr=sr1, n_mfcc=13)
    mfcc2 = librosa.feature.mfcc(y=y2, sr=sr2, n_mfcc=13)

    # Promedio temporal (para que los vectores tengan el mismo tamaño)
    # Si quieres que el orden importe, deberías usar DTW en lugar de promediar.
    mfcc1_mean = np.mean(mfcc1, axis=1).reshape(1, -1)
    mfcc2_mean = np.mean(mfcc2, axis=1).reshape(1, -1)

    # Calcular similitud coseno sobre los vectores de características
    similarity = sklearn_cosine(mfcc1_mean, mfcc2_mean)[0][0]
    
    return float(similarity)


@app.get("/health")
def health():
    return jsonify({"status": "ok"})


@app.post("/compare")
def compare():
    if "audio1" not in request.files or "audio2" not in request.files:
        return jsonify({"error": "missing audio1 or audio2"}), 400

    try:
        sr1, y1 = read_audio(request.files["audio1"])
        sr2, y2 = read_audio(request.files["audio2"])
    except Exception as exc:
        return jsonify({"error": str(exc)}), 400

    if sr1 != sr2:
        target_len = int(len(y2) * sr1 / sr2)
        if target_len <= 0:
            return jsonify({"error": "invalid audio length"}), 400
        y2 = resample(y2, target_len)
        sr2 = sr1

    spec1 = compute_spectrogram(y1, sr1)
    spec2 = compute_spectrogram(y2, sr2)
    similarity = cosine_similarity(spec1, spec2)

    threshold_raw = request.form.get("threshold", "0.9")
    try:
        threshold = float(threshold_raw)
    except ValueError:
        return jsonify({"error": "invalid threshold"}), 400

    return jsonify(
        {
            "similarity": similarity,
            "threshold": threshold,
            "equal": similarity >= threshold,
        }
    )

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)