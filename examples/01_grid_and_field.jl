using Oceananigans

grid = RectilinearGrid(size=(4, 4, 4),
                       extent=(1, 1, 1),
                       topology=(Bounded, Periodic, Bounded))

println(grid)

# 温度分布の設定
T = CenterField(grid)
set!(T, (x, y, z) -> x^2)

println(interior(T)[:, 1, 1])

# x方向の一階微分
dTdx = ∂x(T)
dTdx_field = Field(dTdx)
compute!(dTdx_field)

# 微分結果の表示
println(dTdx_field)
println(interior(dTdx_field)[2:4, 1, 1])

# x方向の二階微分
d2Tdx2 = ∂x(∂x(T))
d2Tdx2_field = Field(d2Tdx2)
compute!(d2Tdx2_field)

# 二階微分の結果を表示
println(d2Tdx2_field)
println(interior(d2Tdx2_field)[2:3, 1, 1])

# x方向の積分
I = Integral(T, dims=1)
I_field = Field(I)
compute!(I_field)

# 積分結果の表示
println(I_field)
println(interior(I_field))