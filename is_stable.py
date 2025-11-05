import numpy as np


def is_stable(nose_history, box_history, tol_px=5, tol_size=0.05):
    """최근 프레임들의 코좌표/박스 변화가 안정적인지 판단"""
    if len(nose_history) < 5:
        return False
    xs, ys = zip(*nose_history)
    ws, hs = zip(*box_history)

    dx = max(xs) - min(xs)
    dy = max(ys) - min(ys)
    dw = (max(ws) - min(ws)) / np.mean(ws)
    dh = (max(hs) - min(hs)) / np.mean(hs)

    return dx < tol_px and dy < tol_px and dw < tol_size and dh < tol_size