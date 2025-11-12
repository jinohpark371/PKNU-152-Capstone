"""
파이프라인 데이터 모델.
모든 모듈이 공유하는 데이터 구조 정의.
"""
from dataclasses import dataclass, field
from typing import Optional, List, Tuple
import numpy as np
import time


@dataclass
class PipelineData:
    """
    파이프라인의 모든 모듈이 공유하는 데이터 컨테이너.
    각 모듈은 이 객체를 받아 자신의 데이터를 채워넣고 다음으로 넘깁니다.
    """
    # 1. 웹캠 모듈이 채우는 데이터
    frame: Optional[np.ndarray] = None  # ML 처리용 원본 프레임 (BGR)
    frame_jpeg: Optional[bytes] = None  # 플러터 전송용 JPEG
    timestamp: float = field(default_factory=time.time)  # 프레임 캡처 시각

    # 2. 특징 추출 모듈이 채우는 데이터
    face_vectors: List[List[float]] = field(default_factory=list)
    bbox_coords: List[Tuple[int, int, int, int]] = field(default_factory=list)

    # 3. 사용자 인증 모듈이 채우는 데이터
    current_user_id: Optional[int] = None
    is_calibration_needed: bool = False

    # 4. 규칙 엔진 모듈이 채우는 데이터
    current_posture_status: str = "unknown"

