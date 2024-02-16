

using DataFrames
using CSV
using CairoMakie
import Images
using ColorTypes
using Colors
using Dates


#https://blog.csdn.net/hfy1237/article/details/124663893 繪圖介紹
#畫圖參數
struct PlotConfig
    #axis 常用參數
    #標題
    title::String
    titlealign::Symbol 
    titlecolor::Symbol
    titlefont::Symbol
    titlegap::Float64
    titlesize::Float64

    subtitle::String
    subtitlefont::Symbol
    subtitlecolor::Symbol
    subtitlegap::Int
    subtitlelineheight::Int
    subtitlesize::Float64
    subvisible::Bool

    spinewidth::Float64
    rightspinevisible::Bool
    rightspinecolor::Symbol
    leftspinevisible::Bool
    leftspinecolor::Symbol
    bottomspinecolor::Symbol
    bottomspinevisible::Bool
    flip_ylable::Bool

    resolution::Tuple{Int64, Int64}
    figure_padding::Tuple{Int64, Int64,Int64, Int64}
    backgroundcolor::ColorTypes.RGB{Float64}
    font::Symbol
    fontsize::Float64


    cycle::Vector{Symbol}  #line
    color::Symbol
    linestyle::Symbol
    linewidth::Float64
    visible::Bool
    overdraw::Bool
    transparency::Bool



     xticks::UnitRange{Int64}
     yticks::UnitRange{Int64}
     xticksmirrored::Bool
     yticksmirrored::Bool
     xminorticksvisible::Bool
     yminorticksvisible::Bool
     xminortickalign::Int
     yminortickalign::Int
     xtickalign::Int
     ytickalign::Int
end
# instantiate   PlotConfig
default_config = PlotConfig(
    "房子\n統計",                #title::String  
    :center,                             #titlealign
    :black,                              #titlecolor
    :blod,                               #titlefont  :italic,:bold ,:bold_italic,:italic,:regular
    4.0,                                 #titlegap
    20.0,                                  #titlesize

    "count/年度",                          #subtitle::String
    :regular   ,                           #subtitlefont::Symbol
    :black     ,                           #subtitlecolor::Symbol
    1         ,                           #subtitlegap
    1         ,                           #subtitlelineheight
    10.0       ,                           #subtitlesize::Float64
    true       ,                           # subvisible::Bool

    1.5,                                    #spinewidth::Float64
    true       ,                            #rightspinevisible::Bool
    :black     ,                            #rightspinecolor::Symbol
    true       ,                            #leftspinevisible::Bool
    :black     ,                            #leftspinecolor::Symbol
    :black     ,                            #bottomspinecolor::Symbol
    true       ,                            #bottomspinevisible::Bool
    true       ,                            #flip_ylable::Bool

    (800,600)  ,                            #resolution
    (5,5,5,5)  ,                            #figure_padding
    Images.RGB(0.9, 0.9, 0.9) ,                       # backgroundcolor
    :regular   ,                                         #font::Symbol
    20.0       ,                                         #fontsize::Float64

    [:solid, :dash, :dot]  ,                             #cycle::Vector{Symbol}
    :dark  ,                                              #color::Symbol
    :dot  ,                                               #linestyle::Symbol
    1.5   ,                                               #linewidth::Float64
    true  ,                                                #visible::Bool
    false  ,                                #overdraw::Bool
    true    ,                               #transparency::Bool
     0:10   ,                                    #xticks::UnitRange{Int64}
     0:10   ,                                       #yticks::UnitRange{Int64}
     true,                                       #xticksmirrored::Bool
      true,                                      #yticksmirrored::Bool
      true,                                      #xminorticksvisible::Bool
      true,                                      #yminorticksvisible::Bool
      1,                                      #xminortickalign::Int
      1,                                      #yminortickalign::Int
      2,                                      #xtickalign::Int
      5                                      #ytickalign::Int
)

joinpath(@__DIR__,"air_pollution.csv")
# 指定CSV檔案的路
path=@__DIR__
file_path = joinpath(@__DIR__,"air_pollution.csv")

# 使用CSV.File()函數讀取CSV檔案並轉換為DataFrame
df = DataFrame(CSV.File(file_path))

#可畫圖片 1. 各國家城市數量
#2.各國家平均PM2.5 對年度
#3.預測2024 各城市的PM2.5  和各國家的PM2.5

#1. 各國家城市數量

# 使用groupby和combine函數進行組合和計數
result = combine(groupby(df, :country), nrow)
sorted_result = sort(result, :nrow, rev=true)

total_nrow = sum(sorted_result.nrow)
#篩選出>100的 依序排序
filtered_result = filter(row -> row.nrow > 100, result)

# 使用eachrow迭代DataFrame的行，並根據條件收集索引
filtered_indexes = Int[]
for (index, row) in enumerate(eachrow(result))
    if row.nrow > 100
        push!(filtered_indexes, index)
    end
end

df_100=filter(:country => x -> x in collect(filtered_result.country)  ,df)

#畫圖
f=Figure(resolution=(1000,800),figure_padding = (5, 50, 5, 5),backgroundcolor=default_config.backgroundcolor,font=20)
ax=Axis(f[1,1],title=default_config.title,titlecolor=Images.RGB(0.2, 0.1, 0.1),titlefont=:bold_italic,titlegap=8.0,titlesize=20,titlelineheight=1
,subtitle=default_config.subtitle,aspect= DataAspect())


lines!(ax, parse.(Int,names(df_100[1,3:end])),collect(df_100[1,3:end]),transparency=true)
#test
# collect(df_100[1,3:end])
######
# 按国家对数据进行分组，并计算每个国家出现的次数
country_counts = combine(groupby(df_100, :country), nrow => :count)

# 提取国家名称和对应的计数
countries = country_counts.country
counts = country_counts.count
# 绘制折线图

# ax=Axis(f[1,1], 
# xticks=0:10,
# yticks=0:10,
# xticksmirrored=true,
# yticksmirrored=true,
# xminorticksvisible=true,
# yminorticksvisible=true,
# xminortickalign=1,
# yminortickalign=1,

# )

#ax = Axis(f[1, 1], xlabel = "Country", ylabel = "Count")
# 使用 barplot! 函数绘制柱状图

label_vector = collect(countries)

colors_length=length(countries)

#各城市出現次數+-------------------------------------------------
fig = Figure(backgroundcolor=Images.RGB(1.0, 1.0, 0.94))

#算出顏色~
color_length=round(0.5/colors_length,digits=3)
colors = collect(map(i -> RGB(i * color_length, i * color_length, 0.5 + i * color_length), 1:colors_length))
#訂定y軸~
maximum(counts)


# 确定输入整数的位数
num_digits_upper = floor(log10(maximum(counts))) + 1
num_digits_down = floor(log10(minimum(counts))) + 1

# 将输入的整数除以 10 的 (位数 - 1) 次方，并向上取整，然后再乘以 10 的 (位数 - 1) 次方
output_integer_upper = Int(ceil(maximum(counts) / 10^(num_digits_upper - 1)) * 10^(num_digits_upper- 1))
output_integer_down = Int(floor(minimum(counts) / 10^(num_digits_down  - 1)) * 10^(num_digits_down  - 1))


#先不要取下限y 

yticks=0:Int(output_integer_upper/10 ):output_integer_upper 

country_index = 1:length(countries)
# 使用 barplot! 函数绘制柱状图
#barplot!(ax, country_index, counts, xticks = (country_index, countries),color=colors)

# 根据 counts 的值对 countries 进行排序
sorted_indices = sortperm(counts, rev=true)
sorted_countries = countries[sorted_indices]
sorted_counts = counts[sorted_indices]
# 绘制柱形图 #AXIS
ax = Axis(fig[1, 1],xticks=(1:colors_length,sorted_countries  ),title="城市數量",titlecolor=Images.RGB(0.2, 0.1, 0.1),titlesize=30,xticklabelsize=16,xticklabelfont=:bold,xtickcolor= Images.RGB(0.504,0.504,1.004),
yticksmirrored=true,
 yminorticksvisible=true,
 yticks=yticks,xticklabelrotation=45
)

barplot!(ax,sorted_counts, xticks=(1:length(sorted_countries), sorted_countries), color=colors)
today_date = today()

CairoMakie.save(joinpath(@__DIR__,"$(today_date)_count&country.png"), fig)

# 创建一个 Figure 对象
#----------------------------------------

using Statistics



year_array=[]
for i in ["2017","2018","2019","2020","2021","2022","2023"]
    average_without_missing = mean(skipmissing(df_100[!,Symbol(i)]))
    push!(year_array,average_without_missing )
end
fig = Figure(backgroundcolor=Images.RGB(1.0, 1.0, 0.94))

#算出顏色~
year_xtick=["2017","2018","2019","2020","2021","2022","2023"]
colors_length=length(["2017","2018","2019","2020","2021","2022","2023"])
color_length=round(0.5/colors_length,digits=3)
colors = collect(map(i -> Images.RGB(i * color_length, i * color_length, 0.5 + i * color_length), 1:colors_length))

#訂定y軸~


# 确定输入整数的位数
num_digits_upper = floor(log10(maximum(year_array))) + 1
num_digits_down = floor(log10(minimum(year_array))) + 1

# 将输入的整数除以 10 的 (位数 - 1) 次方，并向上取整，然后再乘以 10 的 (位数 - 1) 次方
output_integer_upper = Int(ceil(maximum(year_array) / 10^(num_digits_upper - 1)) * 10^(num_digits_upper- 1))
output_integer_down = Int(floor(minimum(year_array) / 10^(num_digits_down  - 1)) * 10^(num_digits_down  - 1))


#先不要取下限y 

yticks=0:Int(output_integer_upper/10 ):output_integer_upper 

years_int = parse.(Int, year_xtick)
ax = Axis(fig[1, 1],xticks=(years_int ),title="PM2.5",titlecolor=Images.RGB(0.2, 0.1, 0.1),titlesize=30,xticklabelsize=16,xticklabelfont=:bold,xtickcolor= Images.RGB(0.504,0.504,1.004)

)

#箭頭座標

arrow_path = BezierPath([
    MoveTo(Point(0, 0)),
    LineTo(Point(0.3, -0.3)),
    LineTo(Point(0.15, -0.3)),
    LineTo(Point(0.15, -1)),
    LineTo(Point(0, -0.98)),
    LineTo(Point(-0.15, -1)),
    LineTo(Point(-0.15, -0.3)),
    LineTo(Point(-0.3, -0.3)),
    ClosePath()
])

for (index, i) in enumerate(year_array)
    if index ==1 

       scatter!(ax,years_int[index],i, markersize=30,color=colors[index],marker = arrow_path,rotations=3/2*pi)
    else

        y=(i-year_array[index-1])
        x=1.8*(output_integer_upper/ output_integer_down)/length(years_int)
        angle_radians = atan(y / x)
        scatter!(ax,years_int[index],i, markersize=30,color=colors[index],marker = arrow_path,rotations=3/2*pi+angle_radians)
    end
end

today_date = today()

CairoMakie.save(joinpath(@__DIR__,"$(today_date)_PM&year.png"), fig)


#-------------------------------------------

#畫標示  確認角度~ done
#   前三多的國家  分成兩邊   預測國家標籤

#dropmiss 

df=dropmissing(df_100)

counts = sort(combine(groupby(df, :country), nrow => :count),:count,rev=true)

df_country=collect(counts[1:3,1])

#篩選前三個國家
# 使用filter函数筛选出"country"列的值为指定国家的行
filtered_df = filter(row -> row.country in df_country, df)
using Random
# 获取DataFrame的行数
n_rows = nrow(filtered_df )
random_indices = shuffle(MersenneTwister(1234),1:n_rows)

shuffled_df = filtered_df[random_indices, :]

# 将DataFrame分成训练集和测试集的比例（这里假设为7:3）
train_ratio = 0.7
test_ratio = 1.0 - train_ratio

split_index = Int(floor(train_ratio * n_rows))

# 分割DataFrame为训练集和测试集
train_df = shuffled_df[1:split_index, :]
test_df = shuffled_df[(split_index + 1):end, :]

println("训练集大小：", nrow(train_df))
println("测试集大小：", nrow(test_df))

using Flux: onehotbatch, onecold, crossentropy, throttle
using Base.Iterators: repeated
using Statistics: mean
 #准备数据

 println("準備數據")

X_train =train_df[!,3:end]
X_test  =train_df[!,2]
Y_train = test_df[!,3:end]
Y_test  = test_df[!,2]


#分類任務  用 onehotbatch

