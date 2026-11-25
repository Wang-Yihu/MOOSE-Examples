# Eq 1: x = 0.5*y + 1
# Eq 2: y = 0.25*x + 1
# In theory, y = 10/7 = 1.4285714285714285714285714285714, x = 12/7 = 1.7142857142857142857142857142857
import math

num_step = 6

rf_y = 0.7
x = [1]
y = [1]
y_transfer = [1.0]

for i in range(0, num_step):
  # MOOSE does not relax before the first Picard iteration.
  # Starting from i = 1, relax the y transferred from sub to parent.
  if i > 0:
    y_transfer.append(
      rf_y * y[i] + (1.0 - rf_y) * y_transfer[i - 1]
    )

  # Parent application: x = 0.5*y_transfer + 1
  x.append(0.5 * y_transfer[i] + 1.0)

  # Sub application: y = 0.25*x + 1
  y.append(0.25 * x[i + 1] + 1.0)

print(x)
print(y)
