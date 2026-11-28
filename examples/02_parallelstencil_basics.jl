using ParallelStencil
using ParallelStencil.FiniteDifferences2D

@init_parallel_stencil(Threads, Float64, 2)

# 計算領域の設定
Nx = 4
Ny = 4

# 温度の配列を作成
T = @zeros(Nx, Ny)

# 配列の表示
println(T)
println(size(T))

println("Logical CPUs: ", Sys.CPU_THREADS)
println("Julia threads: ", Threads.nthreads())

# 計算領域の長さ
Lx = 1.0
Ly = 1.0

# 格子幅
dx = Lx / Nx
dy = Ly / Ny

# 温度分布の設定
for j in 1:Ny
    for i in 1:Nx
        x = (i - 0.5) * dx
        y = (j - 0.5) * dy
        T[i, j] = x^2 + y^2
    end
end

# 結果の表示
println(T[:, 1])

# x方向の温度勾配を格納する配列
dTdx = @zeros(Nx - 1, Ny)
# y方向の温度勾配を格納する配列
dTdy = @zeros(Nx, Ny - 1)

# x方向の一階微分を計算する関数
@parallel function derivative_x!(dTdx, T, dx)
    @all(dTdx) = @d_xa(T) / dx
    return
end
# y方向の一階微分を計算する関数
@parallel function derivative_y!(dTdy, T, dy)
    @all(dTdy) = @d_ya(T) / dy
    return
end

# x方向関数の実行
@parallel derivative_x!(dTdx, T, dx)
# y方向関数の実行
@parallel derivative_y!(dTdy, T, dy)

# x方向結果の表示
println(dTdx[:, 1])
println(size(dTdx))
# y方向結果の表示
println(dTdy[1, :])
println(size(dTdy))

# x方向の二階微分を格納する配列
d2Tdx2 = @zeros(Nx - 2, Ny)
# y方向の二階微分を格納する配列
d2Tdy2 = @zeros(Nx, Ny - 2)

# x方向二階微分の計算
@parallel (1:Nx-2, 1:Ny) derivative_x!(d2Tdx2, dTdx, dx)
# y方向二階微分の計算
@parallel (1:Nx, 1:Ny-2) derivative_y!(d2Tdy2, dTdy, dy)

# x方向結果の表示
println(d2Tdx2[:, 1])
println(size(d2Tdx2))
# y方向結果の表示
println(d2Tdy2[1, :])
println(size(d2Tdy2))

# ラプラシアンの計算
lapT = d2Tdx2[:,2:3] + d2Tdy2[2:3,:]

# 結果の表示
println(lapT)
println(size(lapT))