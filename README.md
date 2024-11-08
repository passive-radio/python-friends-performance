## CPython とPythonライクの事前コンパイラう言語のパフォーマンスを比較した

### 検証対象の言語
#### システム
- OS: WSL2 64bit
- CPU: Ryzen 7 7730U (8cores, 16threads)
- GPU: none (後でGPGPU並列計算の比較もする)

1. Pure Python (CPython) ver. 3.11.9
1. Cython
1. Codon
1. Native C++
1. Numpy (Python)
1. Cupy (Python)

### 検証プログラム
2~n の間の素数の個数を数えるプログラムをそれぞれ10回実行して、その実行に要した時間の平均を比較した。

#### 検証した n
- 100,000
- 1,000,000

### 結果

単位: 秒

| n | Pure Python | Cython | Codon | Native C++ | Numpy | Cupy |
| --- | --- | --- | --- | --- | --- | --- |
| 100,000 | 0.0789 | - | - | - | 0.0812 | - |
| 1,000,000 | 0.8123 | - | - | - | 0.8234 | - |
