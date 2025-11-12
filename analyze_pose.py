import pandas as pd
import matplotlib.pyplot as plt
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import seaborn as sns


def analyze_pose_log(csv_path="pose_log.csv"):
    df = pd.read_csv(csv_path, parse_dates=["timestamp"])
    df = pd.read_csv(csv_path, parse_dates=["timestamp"])
    # -----------------------------
    # 정확도(Accuracy) 계산
    # -----------------------------
    if "true_pose" in df.columns and df["true_pose"].notna().any():
        # (1) None, NaN, "none" 값 제외
        df_valid = df[df["true_pose"].notna() & (df["true_pose"].astype(str).str.lower() != "none")]

        # (2) 문자열 정리 (공백 제거)
        df_valid["true_pose"] = df_valid["true_pose"].astype(str).str.strip()
        df_valid["pose"] = df_valid["pose"].astype(str).str.strip()

        # (3) 정확도 계산
        acc = accuracy_score(df_valid["true_pose"], df_valid["pose"])
        print(f"\n Model Accuracy (excluding unlabeled frames): {acc*100:.2f}%")

        # 자세별 정밀도/재현율
        print("\nClassification Report:")
        print(classification_report(df_valid["true_pose"], df_valid["pose"], digits=3))

        # 혼동행렬 시각화
        labels = ["normal", "turtle", "L", "left", "right"]
        cm = confusion_matrix(df_valid["true_pose"], df_valid["pose"], labels=labels)
        sns.heatmap(cm, annot=True, fmt="d", cmap="Purples",
                    xticklabels=labels, yticklabels=labels)
        plt.title("Confusion Matrix (Predicted vs True)")
        plt.xlabel("Predicted")
        plt.ylabel("True")
        plt.show()

    # ─────────────────────────────
    # 1. 포즈 비율
    pose_counts = df["pose"].value_counts(normalize=True) * 100
    plt.figure(figsize=(6, 4))
    plt.bar(pose_counts.index, pose_counts.values, color=["skyblue","orange","lightcoral","lightgreen"])
    plt.title("Posture Ratio (%)")
    plt.ylabel("Ratio (%)")
    plt.xlabel("Posture Type")
    plt.grid(axis="y", alpha=0.3)
    plt.tight_layout()
    plt.show()

    # ─────────────────────────────
    # 2 시간 흐름에 따른 자세 변화
    fig, ax1 = plt.subplots(figsize=(10, 6), constrained_layout=True)
    pose_map = {"normal": 0, "turtle": 1, "L": 2,  "left": 3,"right": 4}

    # ─ Face Scale (왼쪽 y축)
    ax1.plot(df["timestamp"], df["scale"], color="purple", linewidth=1.5, label="Face Scale")
    ax1.set_ylabel("Face Scale", color="purple")
    ax1.tick_params(axis="y", labelcolor="purple")
    ax1.set_ylim(-0.3, len(pose_map) - 0.7)   # y축 살짝 확장 (-0.3~3.3)

    # ─ Nose movement (오른쪽 y축)
    ax2 = ax1.twinx()
    ax2.plot(df["timestamp"], df["dx"], color="teal", linestyle="--", label="Nose dx (Horizontal)")
    ax2.plot(df["timestamp"], df["dy"], color="orange", linestyle="--", label="Nose dy (Vertical)")
    ax2.set_ylabel("Nose Offset (pixels)", color="gray")
    ax2.tick_params(axis="y", labelcolor="gray")

    # ─ Pose index
    ax1.scatter(df["timestamp"], df["pose"].map(pose_map), c="red", s=10, label="Pose Index")
    ax1.set_yticks(list(pose_map.values()))
    ax1.set_yticklabels(list(pose_map.keys()), fontsize=10)

    # ─ Title / grid / legend
    ax1.set_title("Face Scale & Nose Movement Over Time", fontsize=13)
    ax1.set_xlabel("Time")
    ax1.grid(True, alpha=0.3)
    lines_1, labels_1 = ax1.get_legend_handles_labels()
    lines_2, labels_2 = ax2.get_legend_handles_labels()
    ax1.legend(lines_1 + lines_2, labels_1 + labels_2, loc="upper right", fontsize=9)

    plt.show()

    # ─────────────────────────────
    # 3. dx/dy 분포 히트맵
    plt.figure(figsize=(5, 5))
    plt.hist2d(df["dx"], df["dy"], bins=30, cmap="coolwarm")
    plt.colorbar(label="frequency")
    plt.title("Nose Position Distribution (dx vs dy)")
    plt.xlabel("dx (Horizontal Movement)")
    plt.ylabel("dy (Vertical Movement)")
    plt.tight_layout()
    plt.show()


analyze_pose_log()