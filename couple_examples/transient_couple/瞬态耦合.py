# Written by Yihu WANG
import math
import pandas as pd
# dx/dt = -2*x + y
# dy/dy = x - 2*y
# x(0) = 2, y(0) = 1
# We have the theory solution.
Delta_t = 0.1
x = [2]; y = [1]
num_t_step = 100

####################################### Fully couple  ###################################
# (x[n+1] - x[n])/Delta_t = -2*x[n+1] + y[n+1]
# (y[n+1] - y[n])/Delta_t =  x[n+1] - 2*y[n+1]
# Combine them, we can have:
# x[n+1] = ( (1 + 2*Delta_t)/Delta_t * x[n] + y[n] ) / ( ((1+2*Delta_t)**2/Delta_t - Delta_t) )
# y[n+1] = (  -(1 + 2*Delta_t)/Delta_t * y[n] - x[n]  )/(  (-2*Delta_t-1)*(1+2*Delta_t)/Delta_t + Delta_t  )
for i in range(0, num_t_step):
    x.append( ( (1 + 2*Delta_t)/Delta_t * x[i] + y[i] ) / ( ((1+2*Delta_t)**2/Delta_t - Delta_t) ) )
    y.append((  -(1 + 2*Delta_t)/Delta_t * y[i] - x[i]  )/(  (-2*Delta_t-1)*(1+2*Delta_t)/Delta_t + Delta_t  ))

print("x = ",end = ' ');print(x)
print("y = ",end = ' ');print(y)

####################################### Theory Solution  ###################################

def x_th_f(t):
    return 3 / 2 * math.exp((-1) * t) + 1 / 2 * math.exp((-3)*t)

def y_th_f(t):
    return 3 / 2 * math.exp((-1) * t) - 1 / 2 * math.exp((-3)*t)

x_th = [x[0]]; y_th = [y[0]]

for i in range(0, num_t_step):
    x_th.append(  x_th_f(Delta_t*(i+1))   )
    y_th.append(  y_th_f(Delta_t*(i+1))   )

print("x_th = ",end = ' ');print(x_th)
print("y_th = ",end = ' ');print(y_th)

####################################### Loose Couple  ###################################
# Data is exchanged only once per time step
# For the iteration can continue,
# the y in the first equation is from the previous time step, not y in the current time step
# error appears

# For every time step

# Solve the first equation
# (x[n+1] - x[n])/Delta_t = -2*x[n+1] + y[n]
# The solution is
# x[n+1] = (1/Delta_t*x[n] + y[n])/(1/Delta_t + 2)

# Solve the second equation
# (y[n+1] - y[n])/Delta_t = x[n+1] - 2*y[n+1]
# The solution is
# y[n+1] = (x[n+1] + 1/Delta_t*y[n])/(1/Delta_t + 2)
x_loose = [x[0]]; y_loose = [y[0]]
for i in range(0, num_t_step):
    x_loose.append( (1/Delta_t*x_loose[i] + y_loose[i])/(1/Delta_t + 2) )
    y_loose.append( (x_loose[i+1] + 1/Delta_t*y_loose[i])/(1/Delta_t + 2)  )

print("x_loose = ",end = ' ');print(x_loose)
print("y_loose = ",end = ' ');print(y_loose)

####################################### Tight Couple  ###################################
# 只对从子程序回传的y做松弛；x和子程序求出的原始y不直接松弛。
rf_y = 0.3  # 回传值中保留30%的新y、70%的上一轮传递值。
'''
带回传值松弛的Picard紧耦合，对应下方实际执行的循环。

记号：
  n = 时间步编号；j = 当前时间步内的Picard迭代下标，从0开始。
  K = picard_iter_num，当前K=3；最后一轮下标k = K - 1 = 2。
  x[n]、y[n] = 当前时间步最终保存的原始解。
  x[n,j]、y[n,j] = 第n个时间步、第j轮求出的原始解，分别对应
                  x_tight_iter[n][j]、y_tight_iter[n][j]。
  yr[n,j] = 松弛后传回父程序的y，对应y_transfer_iter[n][j]。
  rf = rf_y，当前取0.3。

在同一时间步内，上一时间步的x[n-1]、y[n-1]始终固定。
首轮父程序使用上一时间步保存的原始y；后续轮次使用上一轮的yr。
子程序始终计算原始y，然后单独构造松弛后的yr供下一轮父程序使用。
下面先展开当前K=3时的三轮（j=0、1、2），再给出一般轮次的公式。

time step 1
# 首轮：先求x，再求原始y，最后构造松弛后的传递值。
x[1,0] = (x[0] + Delta_t*y[0]) / (1 + 2*Delta_t)
y[1,0] = (Delta_t*x[1,0] + y[0]) / (1 + 2*Delta_t)
yr[1,0] = rf*y[1,0] + (1-rf)*y[0]

# 第二轮：父程序使用松弛后的yr[1,0]。
x[1,1] = (x[0] + Delta_t*yr[1,0]) / (1 + 2*Delta_t)
y[1,1] = (Delta_t*x[1,1] + y[0]) / (1 + 2*Delta_t)
yr[1,1] = rf*y[1,1] + (1-rf)*yr[1,0]

# 第三轮：父程序使用第二轮松弛后的yr[1,1]。
x[1,2] = (x[0] + Delta_t*yr[1,1]) / (1 + 2*Delta_t)
y[1,2] = (Delta_t*x[1,2] + y[0]) / (1 + 2*Delta_t)
yr[1,2] = rf*y[1,2] + (1-rf)*yr[1,1]

# 当前K=3，到此接受第三轮（j=2）的原始解。
x[1] = x[1,2]
y[1] = y[1,2]

time step 2
# 开始新的时间步，首轮重新使用已保存的原始y[1]。
x[2,0] = (x[1] + Delta_t*y[1]) / (1 + 2*Delta_t)
y[2,0] = (Delta_t*x[2,0] + y[1]) / (1 + 2*Delta_t)
yr[2,0] = rf*y[2,0] + (1-rf)*y[1]

# 第二轮使用首轮松弛后的传递值。
x[2,1] = (x[1] + Delta_t*yr[2,0]) / (1 + 2*Delta_t)
y[2,1] = (Delta_t*x[2,1] + y[1]) / (1 + 2*Delta_t)
yr[2,1] = rf*y[2,1] + (1-rf)*yr[2,0]

# 第三轮使用第二轮松弛后的传递值。
x[2,2] = (x[1] + Delta_t*yr[2,1]) / (1 + 2*Delta_t)
y[2,2] = (Delta_t*x[2,2] + y[1]) / (1 + 2*Delta_t)
yr[2,2] = rf*y[2,2] + (1-rf)*yr[2,1]

# 保存第三轮原始解，下一时间步首轮使用这里保存的y[2]。
x[2] = x[2,2]
y[2] = y[2,2]

time step n（任意K>=1）
# 首轮j=0；此时y[n]尚未求出，应使用y[n-1]。
x[n,0] = (x[n-1] + Delta_t*y[n-1]) / (1 + 2*Delta_t)
y[n,0] = (Delta_t*x[n,0] + y[n-1]) / (1 + 2*Delta_t)
yr[n,0] = rf*y[n,0] + (1-rf)*y[n-1]

# 后续j=1,...,K-1；旧时间步解不变，只更新当前时间步的迭代值。
x[n,j] = (x[n-1] + Delta_t*yr[n,j-1]) / (1 + 2*Delta_t)
y[n,j] = (Delta_t*x[n,j] + y[n-1]) / (1 + 2*Delta_t)
yr[n,j] = rf*y[n,j] + (1-rf)*yr[n,j-1]

# 固定K轮后保存原始解，k=K-1；当前K=3，因此k=2。
x[n] = x[n,k]
y[n] = y[n,k]

当前程序没有残差收敛判断，而是固定执行K=3轮后推进时间。
最终yr会被记录，但不作为y[n]保存；下一时间步首轮使用原始y[n]。
如果增加K且迭代收敛，结果会趋近同一隐式欧拉离散方程的联立解。
'''
picard_iter_num = 3  # 每步三轮，下标为0、1、2；不表示已经达到耦合收敛。
x_tight = [x[0]]; y_tight = [y[0]]
x_tight_iter = [x[0]]; y_tight_iter = [y[0]]
y_transfer_iter = [y[0]]

for i in range(0, num_t_step):
    x_tight.append(0)
    y_tight.append(0)
    x_tight_iter.append([])
    y_tight_iter.append([])
    y_transfer_iter.append([])


for i in range(1, num_t_step+1):
    for j in range(0, picard_iter_num):
        x_tight_iter[i].append(0)
        y_tight_iter[i].append(0)
        y_transfer_iter[i].append(0)


for i in range(1, num_t_step+1):
    for j in range(0, picard_iter_num):
        if j == 0:
            # 首轮：旧时间步解固定，父程序使用上一时间步保存的原始y。
            x_tight_iter[i][j] = (x_tight[i-1] + Delta_t*y_tight[i-1]) / (1 + 2*Delta_t)
            y_tight_iter[i][j] = (Delta_t*x_tight_iter[i][j] + y_tight[i-1]) / (1 + 2*Delta_t)
            # 首次松弛以旧时间步的原始y作为传递值初猜。
            y_transfer_iter[i][j] = (rf_y * y_tight_iter[i][j]+ (1 - rf_y) * y_tight[i - 1])

        else:
            # 后续轮次：父程序使用上一轮松弛后的传递值，x_tight[i-1]不变。
            x_tight_iter[i][j] = (x_tight[i - 1]+ Delta_t * y_transfer_iter[i][j - 1]) / (1 + 2 * Delta_t)

            # 子程序用新的x求原始y；y_tight[i-1]仍为固定的旧时间步解。
            y_tight_iter[i][j] = (Delta_t * x_tight_iter[i][j]+ y_tight[i - 1]) / (1 + 2 * Delta_t)

            # 用原始新y和上一轮传递值构造新的松弛值；原始y本身不被覆盖。
            y_transfer_iter[i][j] = (rf_y * y_tight_iter[i][j]+ (1 - rf_y) * y_transfer_iter[i][j - 1])

    # 接受最后一轮（当前为第三轮，j=2）的原始x、y，作为下一时间步的旧解。
    x_tight[i] = x_tight_iter[i][-1]
    y_tight[i] = y_tight_iter[i][-1]

print("x_tight = ", end='');print(x_tight)
print("y_tight = ", end='');print(y_tight)

print("x_tight_iter = ", end='');print(x_tight_iter)
print("y_tight_iter = ", end='');print(y_tight_iter)

# ================= Export Excel =================
# 1. time column
time_list = [i * Delta_t for i in range(num_t_step + 1)]

# 2. Construct a DataFrame (tabular structure)
df = pd.DataFrame({
    'time(t)': time_list,
    'theory solution x': x_th,
    'theory solution y': y_th,
    'fully couple x': x,
    'fully couple y': y,
    'loose couple x': x_loose,
    'loose couple y': y_loose,
    'tight couple x': x_tight,
    'tight couple y': y_tight
})

# 3. Round to 6 decimal places
# (to avoid excessively long floating-point numbers in Excel)
# and export.
df = df.round(10)
output_file = 'ThreeCoupleSchemeForPDE.xlsx'
df.to_excel(output_file, index=False)

print(f" we have got the excel file: {output_file}")
