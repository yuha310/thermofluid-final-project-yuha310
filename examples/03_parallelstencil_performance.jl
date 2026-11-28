using ParallelStencil
using ParallelStencil.FiniteDifferences2D
using Statistics

@init_parallel_stencil(Threads, Float64, 2)

## 通常のJuliaの実装(for文による逐次計算)
# 計算領域の設定
Nx = 1000
Ny = 1000

Lx = 1.0
Ly = 1.0

# 格子幅
dx = Lx / Nx
dy = Ly / Ny

# 温度の配列を作成
T = zeros(Float64, Nx, Ny)

# 温度分布の設定
for j in 1:Ny
    for i in 1:Nx
        x = (i - 0.5) * dx
        y = (j - 0.5) * dy
        T[i, j] = x^2 + y^2
    end
end

# 温度勾配を格納する配列
dTdx_serial = zeros(Float64, Nx - 1, Ny)

# x方向の一階微分（逐次計算）
function derivative_x_serial!(dTdx, T, dx)

    Nx, Ny = size(T)

    for j in 1:Ny
        for i in 1:(Nx-1)
            dTdx[i, j] = (T[i+1, j] - T[i, j]) / dx
        end
    end

    return
end

# 関数の実行
# ここを自分で書く
derivative_x_serial!(dTdx_serial, T, dx)

# 計算結果の表示
println(dTdx_serial[1:5, 1])
println(size(dTdx_serial))

## ParallelStencilの実装(マクロによる並列計算)
# 並列計算用の温度勾配を格納する配列
dTdx_parallel = @zeros(Nx - 1, Ny)

# x方向の一階微分（並列計算）
@parallel function derivative_x_parallel!(dTdx, T, dx)

    # ここに差分計算を書く
    @all(dTdx) = @d_xa(T) /dx

    return
end

# 並列計算の実行
# ここを自分で書く
@parallel derivative_x_parallel!(dTdx_parallel, T, dx)

# 計算結果の表示
println(dTdx_parallel[1:5, 1])
println(size(dTdx_parallel))
## 逐次計算と並列計算の結果の比較

# 二つの計算結果の差を求める
# ここを自分で書く
error = dTdx_serial - dTdx_parallel

# 最大誤差を求める
# ここを自分で書く
max_error = maximum(abs.(error))

# 最大誤差の表示
println("Maximum error: ", max_error)

println("Results match: ",
    isapprox(dTdx_serial, dTdx_parallel))

## 計算時間の測定

# 測定回数
Ntrial = 100

# 測定結果を格納する配列
times_serial = zeros(Float64, Ntrial)
times_parallel = zeros(Float64, Ntrial)

# 繰り返し測定
for n in 1:Ntrial

    # 逐次計算の時間を測定して配列に格納
    # ここを自分で書く
    times_serial[n] = @elapsed derivative_x_serial!(dTdx_serial, T, dx)

    # ParallelStencilの計算時間を測定して配列に格納
    # ここを自分で書く
    times_parallel[n] = @elapsed @parallel derivative_x_parallel!(dTdx_parallel, T, dx)

end

# 逐次計算の中央値
# ここを自分で書く
t_serial = median(times_serial)

# ParallelStencilの中央値
# ここを自分で書く
t_parallel = median(times_parallel)

# 中央値を用いた高速化率
# ここを自分で書く
speedup = t_serial / t_parallel

# 結果の表示
println("Julia threads: ", Threads.nthreads())

println("Serial minimum: ", minimum(times_serial), " s")
println("Serial mean: ", mean(times_serial), " s")
println("Serial median: ", t_serial, " s")

println("Parallel minimum: ", minimum(times_parallel), " s")
println("Parallel mean: ", mean(times_parallel), " s")
println("Parallel median: ", t_parallel, " s")

println("Speedup: ", speedup)